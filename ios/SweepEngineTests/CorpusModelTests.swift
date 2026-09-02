import XCTest
@testable import SpiritBoxAudioHarness

final class CorpusModelTests: XCTestCase {
    func testDecodesProductionFieldNamesAndMissingOptionals() throws {
        let json = """
        {
          "schema_version": 1,
          "label": "phase 1 drop-in",
          "kind": "phase1",
          "assets": [
            {
              "asset_id": "SBX_V1_P01_VOW_AE_001",
              "final_filename": "SBX_V1_P01_VOW_AE_001.wav",
              "forward_allowed": true
            }
          ]
        }
        """.data(using: .utf8)!

        let loaded = try CorpusLoader.decodeManifest(
            data: json,
            root: URL(fileURLWithPath: "/tmp/phase1"),
            source: .documentsPhase1,
            fallbackLabel: "fallback",
            forceDevFixture: false
        )

        XCTAssertEqual(loaded.assetCount, 1)
        XCTAssertEqual(loaded.assets[0].assetID, "SBX_V1_P01_VOW_AE_001")
        XCTAssertEqual(loaded.assets[0].relativePath, "SBX_V1_P01_VOW_AE_001.wav")
        XCTAssertNil(loaded.assets[0].performerID)
        XCTAssertNil(loaded.assets[0].voiceFamily)
        XCTAssertNil(loaded.assets[0].phoneticFamily)
        XCTAssertTrue(loaded.assets[0].forwardAllowed)
        XCTAssertTrue(loaded.assets[0].reverseAllowed)
        XCTAssertFalse(loaded.isDevFixture)
    }

    func testSkipsMalformedAndDirectionlessAssets() throws {
        let json = """
        {
          "schema_version": 1,
          "kind": "dev_fixture",
          "assets": [
            { "asset_id": "", "relative_path": "x.wav" },
            { "asset_id": "NO_PATH" },
            {
              "asset_id": "DEAD",
              "relative_path": "dead.wav",
              "forward_allowed": false,
              "reverse_allowed": false
            },
            {
              "asset_id": "OK",
              "relative_path": "ok.wav"
            },
            {
              "asset_id": "OK",
              "relative_path": "ok-dup.wav"
            }
          ]
        }
        """.data(using: .utf8)!

        let loaded = try CorpusLoader.decodeManifest(
            data: json,
            root: nil,
            source: .bundleDevFixtures,
            fallbackLabel: "dev",
            forceDevFixture: true
        )

        XCTAssertEqual(loaded.assets.map(\.assetID), ["OK"])
        XCTAssertEqual(loaded.skippedMalformedCount, 4)
        XCTAssertTrue(loaded.isDevFixture)
    }

    func testZeroAssetManifestIsEmptyButValid() throws {
        let json = """
        { "schema_version": 1, "assets": [] }
        """.data(using: .utf8)!

        let loaded = try CorpusLoader.decodeManifest(
            data: json,
            root: nil,
            source: .empty,
            fallbackLabel: "empty",
            forceDevFixture: false
        )
        XCTAssertEqual(loaded.assetCount, 0)
        XCTAssertEqual(loaded.skippedMalformedCount, 0)
    }

    func testDocumentsPhase1LoadsWhenPresent() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBoxCorpusTests-\(UUID().uuidString)", isDirectory: true)
        let documents = temp.appendingPathComponent("SpiritBoxPhase1Corpus", isDirectory: true)
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        try writeManifest(
            at: documents.appendingPathComponent("manifest.json"),
            id: "PHASE1_A",
            kind: "phase1"
        )

        let loaded = CorpusLoader.load(
            fileManager: .default,
            bundle: .main,
            documentsDirectory: documents
        )

        XCTAssertEqual(loaded.assets.first?.assetID, "PHASE1_A")
        XCTAssertEqual(loaded.source, .documentsPhase1)
        XCTAssertFalse(loaded.isDevFixture)

        try? FileManager.default.removeItem(at: temp)
    }

    func testMissingManifestReturnsNilThenEmptyFallback() {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBox-missing-\(UUID().uuidString)", isDirectory: true)
        XCTAssertNil(
            CorpusLoader.loadManifest(
                root: missing,
                source: .documentsPhase1,
                fallbackLabel: "x",
                forceDevFixture: false
            )
        )
        XCTAssertEqual(LoadedCorpus.empty.assetCount, 0)
        XCTAssertEqual(LoadedCorpus.empty.source, .empty)
    }

    func testAppBundleDevFixturesLoadWhenHosted() {
        let loaded = CorpusLoader.load()
        guard loaded.source == .bundleDevFixtures else {
            // Simulator/host should include DevFixtures. If a Phase 1 drop-in is present, that is also valid.
            XCTAssertGreaterThan(loaded.assetCount, 0)
            return
        }
        XCTAssertGreaterThanOrEqual(loaded.assetCount, 8)
        XCTAssertTrue(loaded.isDevFixture)
        XCTAssertTrue(loaded.assets.allSatisfy { $0.assetID.hasPrefix("DEV_TEST_ONLY_") })
    }

    func testEnsureCreatesDocumentsCorpusDirectoryWhenMissing() throws {
        let temp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: temp) }
        let corpus = temp.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: true)
        XCTAssertFalse(FileManager.default.fileExists(atPath: corpus.path))

        let status = CorpusLoader.ensureDocumentsCorpusDirectory(at: corpus)

        XCTAssertTrue(status.directoryExists)
        XCTAssertTrue(status.createdDirectory)
        XCTAssertFalse(status.manifestExists)
        XCTAssertNil(status.diagnostic)
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: corpus.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: corpus.appendingPathComponent(CorpusLoader.manifestFileName).path)
        )
    }

    func testEnsureLeavesExistingDirectoryAndFilesUntouched() throws {
        let temp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: temp) }
        let corpus = temp.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: corpus, withIntermediateDirectories: true)
        let manifestURL = corpus.appendingPathComponent(CorpusLoader.manifestFileName)
        let wavURL = corpus.appendingPathComponent("KEEP.wav")
        try writeManifest(at: manifestURL, id: "KEEP_ME", kind: "phase1")
        try Data("wav-bytes".utf8).write(to: wavURL)
        let manifestBefore = try Data(contentsOf: manifestURL)
        let wavBefore = try Data(contentsOf: wavURL)

        let status = CorpusLoader.ensureDocumentsCorpusDirectory(at: corpus)

        XCTAssertTrue(status.directoryExists)
        XCTAssertFalse(status.createdDirectory)
        XCTAssertTrue(status.manifestExists)
        XCTAssertNil(status.diagnostic)
        XCTAssertEqual(try Data(contentsOf: manifestURL), manifestBefore)
        XCTAssertEqual(try Data(contentsOf: wavURL), wavBefore)
    }

    func testEmptyDocumentsFolderDoesNotOverrideBundleFixtures() throws {
        let temp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: temp) }
        let corpus = temp.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: true)
        let status = CorpusLoader.ensureDocumentsCorpusDirectory(at: corpus)
        XCTAssertTrue(status.directoryExists)
        XCTAssertFalse(status.manifestExists)

        let loaded = CorpusLoader.load(
            fileManager: .default,
            bundle: .main,
            documentsDirectory: corpus
        )

        XCTAssertNotEqual(loaded.source, .documentsPhase1)
        if loaded.source == .bundleDevFixtures {
            XCTAssertTrue(loaded.isDevFixture)
        }
    }

    func testDocumentsCorpusTakesPrecedenceOverBundleAfterManifestIsCopied() throws {
        let temp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: temp) }
        let corpus = temp.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: true)
        _ = CorpusLoader.ensureDocumentsCorpusDirectory(at: corpus)
        try writeManifest(
            at: corpus.appendingPathComponent(CorpusLoader.manifestFileName),
            id: "DOCS_WINS",
            kind: "phase1"
        )

        let loaded = CorpusLoader.load(
            fileManager: .default,
            bundle: .main,
            documentsDirectory: corpus
        )

        XCTAssertEqual(loaded.source, .documentsPhase1)
        XCTAssertEqual(loaded.assets.first?.assetID, "DOCS_WINS")
        XCTAssertFalse(loaded.isDevFixture)
        XCTAssertEqual(loaded.skippedMalformedCount, 0)
    }

    func testEnsureReportsUsefulDiagnosticWhenPathIsAFile() throws {
        let temp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: temp) }
        let blocker = temp.appendingPathComponent(CorpusLoader.documentsDirectoryName, isDirectory: false)
        try Data("not-a-folder".utf8).write(to: blocker)

        let status = CorpusLoader.ensureDocumentsCorpusDirectory(at: blocker)

        XCTAssertFalse(status.directoryExists)
        XCTAssertFalse(status.createdDirectory)
        XCTAssertFalse(status.manifestExists)
        XCTAssertNotNil(status.diagnostic)
        XCTAssertTrue(status.diagnostic?.contains(CorpusLoader.documentsDirectoryName) == true)
        let leftover = try String(contentsOf: blocker, encoding: .utf8)
        XCTAssertEqual(leftover, "not-a-folder")
    }

    func testFilesAppInstructionUsesDisplayNameNotContainerPath() {
        let instruction = CorpusLoader.filesAppCorpusInstruction(appDisplayName: "Audio Harness")
        XCTAssertEqual(
            instruction,
            "Files → On My iPhone → Audio Harness → SpiritBoxPhase1Corpus"
        )
        XCTAssertFalse(instruction.contains("/var/mobile"))
        XCTAssertFalse(instruction.contains("Containers"))
        XCTAssertFalse(instruction.contains("Application"))
    }

    private func makeTempRoot() throws -> URL {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBoxCorpusTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        return temp
    }

    private func writeManifest(at url: URL, id: String, kind: String) throws {
        let json = """
        {
          "schema_version": 1,
          "kind": "\(kind)",
          "assets": [
            { "asset_id": "\(id)", "relative_path": "\(id).wav", "forward_allowed": true, "reverse_allowed": true }
          ]
        }
        """
        try json.write(to: url, atomically: true, encoding: .utf8)
    }
}
