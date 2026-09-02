import Foundation

/// Discovers and loads a corpus without changing scheduler/engine APIs.
///
/// Search order:
/// 1. Documents/SpiritBoxPhase1Corpus/manifest.json  (drop-in Phase 1, no rebuild)
/// 2. Bundle Phase1/manifest.json
/// 3. Bundle DevFixtures/manifest.json  (DEV / TEST ONLY)
public enum CorpusLoader {
    public static let documentsDirectoryName = "SpiritBoxPhase1Corpus"
    public static let manifestFileName = "manifest.json"
    public static let bundlePhase1Directory = "Phase1"
    public static let bundleDevFixturesDirectory = "DevFixtures"

    public static func documentsCorpusURL(fileManager: FileManager = .default) -> URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return documents.appendingPathComponent(documentsDirectoryName, isDirectory: true)
    }

    public static func load(
        fileManager: FileManager = .default,
        bundle: Bundle = .main,
        documentsDirectory: URL? = nil
    ) -> LoadedCorpus {
        let documentsRoot = documentsDirectory ?? documentsCorpusURL(fileManager: fileManager)

        if let loaded = loadManifest(
            root: documentsRoot,
            fileManager: fileManager,
            source: .documentsPhase1,
            fallbackLabel: "Phase 1 corpus (Documents)",
            forceDevFixture: false
        ) {
            return loaded
        }

        if let phase1Root = bundleDirectory(bundle, named: bundlePhase1Directory),
           let loaded = loadManifest(
               root: phase1Root,
               fileManager: fileManager,
               source: .bundlePhase1,
               fallbackLabel: "Phase 1 corpus (bundle)",
               forceDevFixture: false
           ) {
            return loaded
        }

        if let fixtureRoot = bundleDirectory(bundle, named: bundleDevFixturesDirectory),
           let loaded = loadManifest(
               root: fixtureRoot,
               fileManager: fileManager,
               source: .bundleDevFixtures,
               fallbackLabel: "DEV fixtures — TEST ONLY",
               forceDevFixture: true
           ) {
            return loaded
        }

        return .empty
    }

    public static func loadManifest(
        root: URL,
        fileManager: FileManager = .default,
        source: CorpusSource,
        fallbackLabel: String,
        forceDevFixture: Bool
    ) -> LoadedCorpus? {
        let manifestURL = root.appendingPathComponent(manifestFileName)
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: manifestURL)
            return try decodeManifest(
                data: data,
                root: root,
                source: source,
                fallbackLabel: fallbackLabel,
                forceDevFixture: forceDevFixture
            )
        } catch {
            return LoadedCorpus(
                assets: [],
                skippedMalformedCount: 0,
                source: source,
                label: "Failed to read manifest at \(manifestURL.lastPathComponent)",
                isDevFixture: forceDevFixture || source == .bundleDevFixtures,
                rootURL: root
            )
        }
    }

    public static func decodeManifest(
        data: Data,
        root: URL?,
        source: CorpusSource,
        fallbackLabel: String,
        forceDevFixture: Bool
    ) throws -> LoadedCorpus {
        let decoder = JSONDecoder()
        let manifest = try decoder.decode(CorpusManifest.self, from: data)

        var accepted: [SourceAsset] = []
        var skipped = 0
        var seenIDs = Set<String>()

        for asset in manifest.assets {
            let id = asset.assetID.trimmingCharacters(in: .whitespacesAndNewlines)
            if id.isEmpty || asset.relativePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                skipped += 1
                continue
            }
            if seenIDs.contains(id) {
                skipped += 1
                continue
            }
            if !asset.forwardAllowed && !asset.reverseAllowed {
                skipped += 1
                continue
            }
            seenIDs.insert(id)
            accepted.append(asset)
        }

        let kind = manifest.kind?.lowercased()
        let isDev = forceDevFixture
            || source == .bundleDevFixtures
            || kind == "dev_fixture"
            || kind == "dev"
            || kind == "test"

        return LoadedCorpus(
            assets: accepted,
            skippedMalformedCount: skipped,
            source: source,
            label: manifest.label ?? fallbackLabel,
            isDevFixture: isDev,
            rootURL: root
        )
    }

    private static func bundleDirectory(_ bundle: Bundle, named name: String) -> URL? {
        if let manifest = bundle.url(forResource: "manifest", withExtension: "json", subdirectory: name) {
            return manifest.deletingLastPathComponent()
        }
        if let resourceURL = bundle.resourceURL {
            return resourceURL.appendingPathComponent(name, isDirectory: true)
        }
        return bundle.bundleURL.appendingPathComponent(name, isDirectory: true)
    }

    public static func fileURL(for asset: SourceAsset, root: URL?) -> URL? {
        guard let root else { return nil }
        let path = asset.relativePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else { return nil }
        return root.appendingPathComponent(path)
    }
}
