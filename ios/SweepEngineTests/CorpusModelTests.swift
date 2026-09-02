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
