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
        case copyFailed(String)

        public var errorDescription: String? {
            switch self {
            case .missingManifest:
                return "Select a corpus folder or files that include manifest.json."
            case .missingAudio:
                return "The selected corpus has no WAV files."
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

        do {
            try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
            try clearPreviousCorpus(at: destination, fileManager: fileManager)
            for source in sources {
                let destFile = destination.appendingPathComponent(source.lastPathComponent)
                if fileManager.fileExists(atPath: destFile.path) {
                    try fileManager.removeItem(at: destFile)
                }
                try fileManager.copyItem(at: source, to: destFile)
            }
        } catch {
            throw Error.copyFailed(error.localizedDescription)
        }

        return Result(copiedFileCount: sources.count, wavCount: wavCount)
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

    private static func clearPreviousCorpus(at destination: URL, fileManager: FileManager) throws {
        let existing = (try? fileManager.contentsOfDirectory(
            at: destination,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []
        for file in existing where isCorpusFile(file) {
            try fileManager.removeItem(at: file)
        }
    }
}
