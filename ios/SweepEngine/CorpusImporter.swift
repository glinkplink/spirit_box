import Foundation

/// Copies a human Phase 1 corpus (manifest.json + WAV files) into Documents.
public enum CorpusImporter {
    public struct Result: Equatable, Sendable {
        public let copiedFileCount: Int
        public let wavCount: Int
    }

    public enum Error: Swift.Error, Equatable, LocalizedError {
        case missingManifest
        case missingAudio
        case invalidManifest(String)
        case missingReferencedAudio(String)
        case copyFailed(String)

        public var errorDescription: String? {
            switch self {
            case .missingManifest:
                return "Select a corpus folder or files that include manifest.json."
            case .missingAudio:
                return "The selected corpus has no WAV files."
            case .invalidManifest(let detail):
                return "The selected manifest is invalid: \(detail)"
            case .missingReferencedAudio(let filename):
                return "The selected corpus is missing a WAV referenced by manifest.json: \(filename)"
            case .copyFailed(let detail):
                return "Could not copy corpus files: \(detail)"
            }
        }
    }

    public static func importItems(
        urls: [URL],
        into destination: URL,
        fileManager: FileManager = .default
    ) throws -> Result {
        let sources = collectPayload(urls: urls, fileManager: fileManager)
        let hasManifest = sources.contains { $0.lastPathComponent == CorpusLoader.manifestFileName }
        let wavCount = sources.filter { $0.pathExtension.lowercased() == "wav" }.count
        guard hasManifest else { throw Error.missingManifest }
        guard wavCount > 0 else { throw Error.missingAudio }

        let parent = destination.deletingLastPathComponent()
        let suffix = UUID().uuidString
        let staging = parent.appendingPathComponent(".\(CorpusLoader.documentsDirectoryName)-import-\(suffix)", isDirectory: true)
        let backup = parent.appendingPathComponent(".\(CorpusLoader.documentsDirectoryName)-backup-\(suffix)", isDirectory: true)
        var removeBackupOnExit = false

        defer {
            try? fileManager.removeItem(at: staging)
            if removeBackupOnExit {
                try? fileManager.removeItem(at: backup)
            }
        }

        do {
            try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: staging, withIntermediateDirectories: true)
            for source in sources {
                let destFile = staging.appendingPathComponent(source.lastPathComponent)
                try fileManager.copyItem(at: source, to: destFile)
            }
            try validateStagedCorpus(at: staging, fileManager: fileManager)

            var isDirectory: ObjCBool = false
            let destinationExists = fileManager.fileExists(atPath: destination.path, isDirectory: &isDirectory)
            if destinationExists && !isDirectory.boolValue {
                throw Error.copyFailed("Documents/\(CorpusLoader.documentsDirectoryName) is not a folder.")
            }

            if destinationExists {
                try fileManager.moveItem(at: destination, to: backup)
            }

            do {
                try fileManager.moveItem(at: staging, to: destination)
                removeBackupOnExit = destinationExists
            } catch {
                if destinationExists && !fileManager.fileExists(atPath: destination.path) {
                    try? fileManager.moveItem(at: backup, to: destination)
                }
                throw error
            }
        } catch let error as Error {
            throw error
        } catch {
            throw Error.copyFailed(error.localizedDescription)
        }

        return Result(copiedFileCount: sources.count, wavCount: wavCount)
    }

    private static func validateStagedCorpus(at root: URL, fileManager: FileManager) throws {
        let manifestURL = root.appendingPathComponent(CorpusLoader.manifestFileName)
        let manifest: CorpusManifest
        do {
            manifest = try JSONDecoder().decode(CorpusManifest.self, from: Data(contentsOf: manifestURL))
        } catch {
            throw Error.invalidManifest(error.localizedDescription)
        }

        guard !manifest.assets.isEmpty else {
            throw Error.invalidManifest("it does not declare any assets")
        }

        for asset in manifest.assets {
            let path = asset.relativePath.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                throw Error.invalidManifest("asset \(asset.assetID) has no WAV path")
            }
            guard fileManager.fileExists(atPath: root.appendingPathComponent(path).path) else {
                throw Error.missingReferencedAudio(path)
            }
        }
    }

    private static func collectPayload(urls: [URL], fileManager: FileManager) -> [URL] {
        var unique: [String: URL] = [:]
        for url in urls {
            for file in expand(url, fileManager: fileManager) where isCorpusFile(file) {
                unique[file.lastPathComponent.lowercased()] = file
            }
        }
        return Array(unique.values)
    }

    private static func expand(_ url: URL, fileManager: FileManager) -> [URL] {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if (exists && isDirectory.boolValue) || url.hasDirectoryPath {
            return filesInCorpusDirectory(url, fileManager: fileManager)
        }
        return [url]
    }

    private static func filesInCorpusDirectory(_ url: URL, fileManager: FileManager) -> [URL] {
        let nested = url.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: true)
        let nestedManifest = nested.appendingPathComponent(CorpusLoader.manifestFileName)
        let root = fileManager.fileExists(atPath: nestedManifest.path) ? nested : url
        let contents = (try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        return contents.filter { file in
            let values = try? file.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey])
            if values?.isDirectory == true { return false }
            return isCorpusFile(file)
        }
    }

    private static func isCorpusFile(_ url: URL) -> Bool {
        if url.lastPathComponent == CorpusLoader.manifestFileName { return true }
        return url.pathExtension.lowercased() == "wav"
    }

}
