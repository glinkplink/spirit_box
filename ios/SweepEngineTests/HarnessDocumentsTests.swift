import XCTest
@testable import SpiritBoxAudioHarness

final class HarnessDocumentsTests: XCTestCase {
    private var scratchDirectory: URL!

    override func setUpWithError() throws {
        scratchDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBoxHarnessDocs-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratchDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let scratchDirectory {
            try? FileManager.default.removeItem(at: scratchDirectory)
        }
        scratchDirectory = nil
    }

    func testResolveUsesDocumentDirectoryNotTemporaryFallback() throws {
        let documents = try HarnessDocuments.resolve()
        XCTAssertFalse(documents.path.contains("tmp"))
        XCTAssertFalse(documents.path.contains("Caches"))
        XCTAssertFalse(documents.path.contains("Application Support"))
    }

    func testBootstrapCreatesExpectedFoldersAndSentinel() throws {
        let documents = scratchDirectory.appendingPathComponent("Documents", isDirectory: true)
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)

        let result = try HarnessDocuments.bootstrap(documentsURL: documents)

        XCTAssertTrue(result.engineOutputCapturesExists)
        XCTAssertTrue(result.harnessFilesTxtExists)
        XCTAssertTrue(result.corpusFolder.directoryExists)

        let captureDirectory = EngineOutputCaptureLocator.directory(in: documents)
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: captureDirectory.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertTrue(captureDirectory.path.hasSuffix(EngineOutputCaptureLocator.directoryName))

        let sentinelURL = documents.appendingPathComponent(HarnessDocuments.sentinelFileName)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sentinelURL.path))
        let sentinel = try String(contentsOf: sentinelURL, encoding: .utf8)
        XCTAssertTrue(sentinel.contains(CorpusLoader.documentsDirectoryName))
        XCTAssertTrue(sentinel.contains(EngineOutputCaptureLocator.directoryName))
    }

    func testRepeatedBootstrapIsIdempotent() throws {
        let documents = scratchDirectory.appendingPathComponent("Documents", isDirectory: true)
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)

        let first = try HarnessDocuments.bootstrap(documentsURL: documents)
        let sentinelBefore = try Data(contentsOf: documents.appendingPathComponent(HarnessDocuments.sentinelFileName))
        let second = try HarnessDocuments.bootstrap(documentsURL: documents)

        XCTAssertTrue(first.createdEngineOutputCaptures || second.createdEngineOutputCaptures)
        XCTAssertFalse(second.createdHarnessFilesTxt)
        let sentinelAfter = try Data(contentsOf: documents.appendingPathComponent(HarnessDocuments.sentinelFileName))
        XCTAssertEqual(sentinelBefore, sentinelAfter)
    }

    func testCaptureLocatorPathIsDirectlyUnderDocuments() throws {
        let documents = scratchDirectory.appendingPathComponent("Documents", isDirectory: true)
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        _ = try EngineOutputCaptureLocator.ensureCaptureDirectory(in: documents)

        let captureURL = EngineOutputCaptureLocator.makeFileURL(
            in: documents,
            now: Date(timeIntervalSince1970: 1_700_000_000)
        )
        XCTAssertEqual(
            captureURL.deletingLastPathComponent().lastPathComponent,
            EngineOutputCaptureLocator.directoryName
        )
        XCTAssertEqual(captureURL.deletingLastPathComponent().deletingLastPathComponent(), documents)
    }

    func testCapturePersistenceVerifierRequiresNonEmptyWavAndAdjacentEventLog() throws {
        let documents = scratchDirectory.appendingPathComponent("Documents", isDirectory: true)
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        _ = try EngineOutputCaptureLocator.ensureCaptureDirectory(in: documents)

        let wavURL = EngineOutputCaptureLocator.makeFileURL(in: documents)
        XCTAssertNotNil(CapturePersistenceVerifier.verify(wavURL: wavURL))

        try Data().write(to: wavURL)
        XCTAssertNotNil(CapturePersistenceVerifier.verify(wavURL: wavURL))

        try Data([0x01]).write(to: wavURL)
        XCTAssertNotNil(CapturePersistenceVerifier.verify(wavURL: wavURL))

        let eventsURL = EngineOutputCaptureLocator.makeEventLogURL(forCaptureURL: wavURL)
        try Data("{}".utf8).write(to: eventsURL)
        XCTAssertNil(CapturePersistenceVerifier.verify(wavURL: wavURL))
    }

    func testCapturePersistenceVerifierRejectsPathsOutsideEngineOutputCaptures() throws {
        let wavURL = scratchDirectory.appendingPathComponent("engine-output-capture-test.wav")
        try Data([0x01]).write(to: wavURL)
        let eventsURL = wavURL.deletingPathExtension().appendingPathExtension("events.jsonl")
        try Data("{}".utf8).write(to: eventsURL)

        XCTAssertNotNil(CapturePersistenceVerifier.verify(wavURL: wavURL))
    }

    func testPublishedCaptureVerifierAcceptsAudioGateRunMix() throws {
        let documents = scratchDirectory.appendingPathComponent("Documents", isDirectory: true)
        let runDirectory = AudioGateRunLocator.directory(in: documents)
            .appendingPathComponent("20260903-170000-abcd", isDirectory: true)
        try FileManager.default.createDirectory(at: runDirectory, withIntermediateDirectories: true)

        let wavURL = runDirectory.appendingPathComponent(AudioGateRunLocator.wavFileName)
        try Data([0x01]).write(to: wavURL)

        XCTAssertNotNil(CapturePersistenceVerifier.verify(wavURL: wavURL))
        XCTAssertNil(CapturePersistenceVerifier.verifyPublishedCapture(wavURL: wavURL))
    }

    func testFilesSharingConfiguredInHostedHarnessBundle() {
        XCTAssertTrue(HarnessDocuments.filesSharingConfigured())
    }
}
