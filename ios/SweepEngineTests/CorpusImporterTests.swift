import XCTest
@testable import SpiritBoxAudioHarness

final class CorpusImporterTests: XCTestCase {
    private var scratch: URL!

    override func setUpWithError() throws {
        scratch = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBoxCorpusImport-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let scratch {
            try? FileManager.default.removeItem(at: scratch)
        }
        scratch = nil
    }

    func testImportCopiesSelectedManifestAndWavsIntoDestination() throws {
        let source = scratch.appendingPathComponent("picked", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        let manifest = source.appendingPathComponent("manifest.json")
        let wav = source.appendingPathComponent("me_test_001.wav")
        try writeManifest(at: manifest, id: "me_test_001")
        try Data([0x01, 0x02]).write(to: wav)
        try Data("skip-me".utf8).write(to: source.appendingPathComponent("notes.txt"))

        let destination = scratch.appendingPathComponent("SpiritBoxPhase1Corpus", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let result = try CorpusImporter.importItems(
            urls: [manifest, wav, source.appendingPathComponent("notes.txt")],
            into: destination
        )

        XCTAssertEqual(result.wavCount, 1)
        XCTAssertEqual(result.copiedFileCount, 2)
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("manifest.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("me_test_001.wav").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.appendingPathComponent("notes.txt").path))
    }

    func testImportFromFolderUsesNestedSpiritBoxPhase1CorpusWhenPresent() throws {
        let picked = scratch.appendingPathComponent("me_test", isDirectory: true)
        let nested = picked.appendingPathComponent("SpiritBoxPhase1Corpus", isDirectory: true)
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        try writeManifest(at: nested.appendingPathComponent("manifest.json"), id: "me_test_002")
        try Data([0x03]).write(to: nested.appendingPathComponent("me_test_002.wav"))
        try Data("not-corpus".utf8).write(to: picked.appendingPathComponent("intake-qa-report.md"))

        let destination = scratch.appendingPathComponent("dest", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let result = try CorpusImporter.importItems(urls: [picked], into: destination)

        XCTAssertEqual(result.wavCount, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("me_test_002.wav").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.appendingPathComponent("intake-qa-report.md").path))
    }

    func testImportReplacesPreviousCorpusFiles() throws {
        let destination = scratch.appendingPathComponent("dest", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try writeManifest(at: destination.appendingPathComponent("manifest.json"), id: "OLD")
        try Data([0xAA]).write(to: destination.appendingPathComponent("old.wav"))

        let source = scratch.appendingPathComponent("new", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        try writeManifest(at: source.appendingPathComponent("manifest.json"), id: "NEW")
        try Data([0xBB]).write(to: source.appendingPathComponent("new.wav"))

        _ = try CorpusImporter.importItems(urls: [source], into: destination)

        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.appendingPathComponent("old.wav").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("new.wav").path))
        let loaded = try String(contentsOf: destination.appendingPathComponent("manifest.json"), encoding: .utf8)
        XCTAssertTrue(loaded.contains("NEW"))
        XCTAssertFalse(loaded.contains("\"OLD\""))
    }

    func testImportCanSafelySelectTheExistingDestinationFolder() throws {
        let destination = scratch.appendingPathComponent("SpiritBoxPhase1Corpus", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try writeManifest(at: destination.appendingPathComponent("manifest.json"), id: "CURRENT")
        try Data([0xAA]).write(to: destination.appendingPathComponent("CURRENT.wav"))

        let result = try CorpusImporter.importItems(urls: [destination], into: destination)

        XCTAssertEqual(result.wavCount, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("manifest.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("CURRENT.wav").path))
    }

    func testInvalidReplacementPreservesThePreviousCorpus() throws {
        let destination = scratch.appendingPathComponent("dest", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try writeManifest(at: destination.appendingPathComponent("manifest.json"), id: "OLD")
        try Data([0xAA]).write(to: destination.appendingPathComponent("OLD.wav"))

        let source = scratch.appendingPathComponent("invalid", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        try writeManifest(at: source.appendingPathComponent("manifest.json"), id: "MISSING")
        try Data([0xBB]).write(to: source.appendingPathComponent("unreferenced.wav"))

        XCTAssertThrowsError(try CorpusImporter.importItems(urls: [source], into: destination)) { error in
            guard case CorpusImporter.Error.missingReferencedAudio("MISSING.wav") = error else {
                return XCTFail("expected missingReferencedAudio, got \(error)")
            }
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.appendingPathComponent("OLD.wav").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.appendingPathComponent("unreferenced.wav").path))
    }

    func testImportRejectsMissingManifest() throws {
        let source = scratch.appendingPathComponent("wavs", isDirectory: true)
        let destination = scratch.appendingPathComponent("dest", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try Data([0x01]).write(to: source.appendingPathComponent("only.wav"))

        XCTAssertThrowsError(try CorpusImporter.importItems(urls: [source], into: destination)) { error in
            guard case CorpusImporter.Error.missingManifest = error else {
                return XCTFail("expected missingManifest, got \(error)")
            }
        }
    }

    func testImportRejectsManifestWithoutWavs() throws {
        let source = scratch.appendingPathComponent("json-only", isDirectory: true)
        let destination = scratch.appendingPathComponent("dest", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try writeManifest(at: source.appendingPathComponent("manifest.json"), id: "NO_AUDIO")

        XCTAssertThrowsError(try CorpusImporter.importItems(urls: [source], into: destination)) { error in
            guard case CorpusImporter.Error.missingAudio = error else {
                return XCTFail("expected missingAudio, got \(error)")
            }
        }
    }

    private func writeManifest(at url: URL, id: String) throws {
        let json = """
        {
          "schema_version": 1,
          "kind": "phase1",
          "assets": [
            { "asset_id": "\(id)", "relative_path": "\(id).wav", "forward_allowed": true, "reverse_allowed": true }
          ]
        }
        """
        try json.write(to: url, atomically: true, encoding: .utf8)
    }
}
