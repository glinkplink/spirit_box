import Foundation

/// Resolves and bootstraps the private harness Documents layout.
/// Never falls back to Caches, tmp, or Application Support.
public enum HarnessDocuments {
    public static let sentinelFileName = "HARNESS_FILES.txt"

    public enum Error: Swift.Error, LocalizedError, Equatable {
        case documentsUnavailable
        case captureDirectoryCreationFailed(String)
        case sentinelWriteFailed(String)

        public var errorDescription: String? {
            switch self {
            case .documentsUnavailable:
                return "Documents directory is unavailable. Cannot store harness files."
            case .captureDirectoryCreationFailed(let detail):
                return "Could not create Documents/EngineOutputCaptures: \(detail)"
            case .sentinelWriteFailed(let detail):
                return "Could not create Documents/\(sentinelFileName): \(detail)"
            }
        }
    }

    public struct BootstrapResult: Equatable, Sendable {
        public let documentsURL: URL
        public let corpusFolder: DocumentsCorpusFolderStatus
        public let engineOutputCapturesExists: Bool
        public let createdEngineOutputCaptures: Bool
        public let harnessFilesTxtExists: Bool
        public let createdHarnessFilesTxt: Bool
    }

    public static func resolve(fileManager: FileManager = .default) throws -> URL {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw Error.documentsUnavailable
        }
        return url
    }

    /// Creates harness folders and the visibility sentinel on launch. Idempotent.
    @discardableResult
    public static func bootstrap(
        documentsURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> BootstrapResult {
        let documents = try documentsURL ?? resolve(fileManager: fileManager)
        let corpusFolder = try CorpusLoader.ensureDocumentsCorpusDirectory(
            fileManager: fileManager,
            at: documents.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: true)
        )

        let captureDirectory = EngineOutputCaptureLocator.directory(in: documents)
        let createdCaptureDirectory = try ensureDirectory(
            at: captureDirectory,
            fileManager: fileManager,
            failure: { detail in .captureDirectoryCreationFailed(detail) }
        )

        let sentinelURL = documents.appendingPathComponent(sentinelFileName)
        let sentinelStatus = try ensureSentinel(at: sentinelURL, fileManager: fileManager)

        return BootstrapResult(
            documentsURL: documents,
            corpusFolder: corpusFolder,
            engineOutputCapturesExists: true,
            createdEngineOutputCaptures: createdCaptureDirectory,
            harnessFilesTxtExists: sentinelStatus.exists,
            createdHarnessFilesTxt: sentinelStatus.created
        )
    }

    public static func engineOutputCapturesDirectory(fileManager: FileManager = .default) throws -> URL {
        let documents = try resolve(fileManager: fileManager)
        return EngineOutputCaptureLocator.directory(in: documents)
    }

    public static func harnessFilesTxtURL(fileManager: FileManager = .default) throws -> URL {
        try resolve(fileManager: fileManager).appendingPathComponent(sentinelFileName)
    }

    public static func filesSharingConfigured(in bundle: Bundle = .main) -> Bool {
        let sharing = bundle.object(forInfoDictionaryKey: "UIFileSharingEnabled") as? Bool ?? false
        let inPlace = bundle.object(forInfoDictionaryKey: "LSSupportsOpeningDocumentsInPlace") as? Bool ?? false
        return sharing && inPlace
    }

    public static func filesAppCaptureInstruction(appDisplayName: String) -> String {
        "On My iPhone → \(appDisplayName) → \(EngineOutputCaptureLocator.directoryName)"
    }

    public static let sentinelTemplate = """
        Spirit Box Audio Harness developer files.

        Phase-1 corpus:
        \(CorpusLoader.documentsDirectoryName)/

        Engine captures:
        \(EngineOutputCaptureLocator.directoryName)/
        """

    private static func ensureDirectory(
        at url: URL,
        fileManager: FileManager,
        failure: (String) -> Error
    ) throws -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue {
            return false
        }
        if exists && !isDirectory.boolValue {
            throw failure("a file already exists at that path")
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            return true
        } catch {
            throw failure(error.localizedDescription)
        }
    }

    private static func ensureSentinel(
        at url: URL,
        fileManager: FileManager
    ) throws -> (exists: Bool, created: Bool) {
        if fileManager.fileExists(atPath: url.path) {
            return (true, false)
        }
        do {
            try sentinelTemplate.write(to: url, atomically: true, encoding: .utf8)
            return (true, true)
        } catch {
            throw Error.sentinelWriteFailed(error.localizedDescription)
        }
    }
}

/// Verifies standalone engine-output captures landed in Documents/EngineOutputCaptures.
public enum CapturePersistenceVerifier {
    public static func verify(
        wavURL: URL,
        fileManager: FileManager = .default
    ) -> String? {
        guard fileManager.fileExists(atPath: wavURL.path) else {
            return "Capture WAV was not written to disk."
        }

        let attributes: [FileAttributeKey: Any]
        do {
            attributes = try fileManager.attributesOfItem(atPath: wavURL.path)
        } catch {
            return "Could not read capture WAV attributes: \(error.localizedDescription)"
        }

        let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
        if size <= 0 {
            return "Capture WAV is empty."
        }

        guard wavURL.pathExtension.lowercased() == "wav" else {
            return "Capture file is not a WAV."
        }

        guard wavURL.deletingLastPathComponent().lastPathComponent == EngineOutputCaptureLocator.directoryName else {
            return "Capture is not under Documents/\(EngineOutputCaptureLocator.directoryName)."
        }

        let eventsURL = EngineOutputCaptureLocator.makeEventLogURL(forCaptureURL: wavURL)
        guard fileManager.fileExists(atPath: eventsURL.path) else {
            return "Capture event log is missing beside the WAV."
        }

        return nil
    }

    /// Same disk checks as `verify` for standalone captures. Audio-gate run mixes live under
    /// `Documents/AudioGateRuns/<run>/engine-output.wav` and must not be judged by the
    /// EngineOutputCaptures folder rule.
    public static func verifyPublishedCapture(
        wavURL: URL,
        fileManager: FileManager = .default
    ) -> String? {
        let runDirectory = wavURL.deletingLastPathComponent()
        if runDirectory.deletingLastPathComponent().lastPathComponent == AudioGateRunLocator.directoryName {
            return verifyAudioGateRunMix(wavURL: wavURL, fileManager: fileManager)
        }
        return verify(wavURL: wavURL, fileManager: fileManager)
    }

    private static func verifyAudioGateRunMix(
        wavURL: URL,
        fileManager: FileManager
    ) -> String? {
        guard fileManager.fileExists(atPath: wavURL.path) else {
            return "Capture WAV was not written to disk."
        }
        let attributes: [FileAttributeKey: Any]
        do {
            attributes = try fileManager.attributesOfItem(atPath: wavURL.path)
        } catch {
            return "Could not read capture WAV attributes: \(error.localizedDescription)"
        }
        let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
        if size <= 0 {
            return "Capture WAV is empty."
        }
        guard wavURL.pathExtension.lowercased() == "wav" else {
            return "Capture file is not a WAV."
        }
        return nil
    }
}
