import XCTest
@testable import SpiritBoxAudioHarness

final class AudioGateRunTests: XCTestCase {
    private var scratchDirectory: URL!

    override func setUpWithError() throws {
        scratchDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBoxAudioGateRunTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratchDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let scratchDirectory {
            try? FileManager.default.removeItem(at: scratchDirectory)
        }
        scratchDirectory = nil
    }

    func testRunDirectoriesAreUniqueAndDoNotOverwriteExistingRuns() throws {
        let now = Date(timeIntervalSince1970: 1_725_280_000)
        let first = try AudioGateRunLocator.createUniqueRunDirectory(
            in: scratchDirectory,
            now: now,
            shortID: "aaaaaaaa"
        )
        try Data("keep-me".utf8).write(to: first.summaryJSONURL)

        let secondSameID = try AudioGateRunLocator.createUniqueRunDirectory(
            in: scratchDirectory,
            now: now,
            shortID: "aaaaaaaa"
        )
        XCTAssertNotEqual(first.runID, secondSameID.runID)
        XCTAssertNotEqual(first.directoryURL.path, secondSameID.directoryURL.path)
        XCTAssertEqual(try String(contentsOf: first.summaryJSONURL, encoding: .utf8), "keep-me")

        let third = try AudioGateRunLocator.createUniqueRunDirectory(
            in: scratchDirectory,
            now: now,
            shortID: "bbbbbbbb"
        )
        XCTAssertNotEqual(Set([first.runID, secondSameID.runID, third.runID]).count, 1)
        XCTAssertEqual(first.runID, "\(AudioGateRunLocator.timestampFormatter.string(from: now))-aaaaaaaa")
        XCTAssertTrue(first.wavURL.lastPathComponent == "engine-output.wav")
        XCTAssertEqual(first.eventsURL.lastPathComponent, "events.jsonl")
        XCTAssertEqual(first.listeningNotesURL.lastPathComponent, "LISTENING_NOTES.md")
    }

    func testFilesAppInstructionUsesDisplayNameNotContainerUUID() {
        let instruction = AudioGateRunLocator.filesAppInstruction(appDisplayName: "Audio Harness")
        XCTAssertEqual(instruction, "Files → On My iPhone → Audio Harness → AudioGateRuns")
        XCTAssertFalse(instruction.contains("UUID"))
        XCTAssertFalse(instruction.contains("/var/mobile"))
        XCTAssertFalse(instruction.contains("Application/"))
    }

    func testSummaryMetricsFromDeterministicEvents() throws {
        let events = [
            makeEvent(asset: "A", performer: "P01", family: "low", since: nil, relaxed: [], rate: .ms200, direction: .forward),
            makeEvent(asset: "B", performer: "P02", family: "high", since: nil, relaxed: [], rate: .ms200, direction: .forward),
            makeEvent(asset: "C", performer: "P01", family: "low", since: nil, relaxed: [.phoneticFamily], rate: .ms125, direction: .reverse),
            makeEvent(asset: "A", performer: "P01", family: "low", since: 3, relaxed: [.recentWindow], rate: .ms125, direction: .reverse),
            makeEvent(asset: "B", performer: "P02", family: "high", since: 7, relaxed: [], rate: .ms75, direction: .forward),
            makeEvent(asset: "A", performer: "P01", family: "low", since: 12, relaxed: [], rate: .ms75, direction: .forward),
            makeEvent(asset: "D", performer: "P03", family: "mid", since: nil, relaxed: [], rate: .ms300, direction: .forward),
            makeEvent(asset: "B", performer: "P02", family: "high", since: 22, relaxed: [.highRecognitionRisk], rate: .ms300, direction: .forward),
        ]
        let corpus = LoadedCorpus(
            assets: (1...10).map { SourceAsset(assetID: "asset-\($0)", relativePath: "\($0).wav") },
            skippedMalformedCount: 2,
            source: .documentsPhase1,
            label: "Phase 1 fixture",
            isDevFixture: false,
            rootURL: nil
        )
        let summary = AudioGateRunSummary.make(
            runID: "run-1",
            startedAt: Date(timeIntervalSince1970: 10),
            endedAt: Date(timeIntervalSince1970: 130),
            requestedDurationSeconds: 120,
            capturedDurationSeconds: 120,
            completion: .completed,
            failureMessage: nil,
            corpus: corpus,
            startingSweepRate: .ms200,
            startingDirection: .forward,
            events: events
        )

        XCTAssertEqual(summary.totalEvents, 8)
        XCTAssertEqual(summary.uniqueAssetIDs, 4)
        XCTAssertEqual(try XCTUnwrap(summary.corpusCoverage), 0.4, accuracy: 0.000_1)
        XCTAssertEqual(summary.firstUseEventCount, 4)
        XCTAssertEqual(summary.repeatUseEventCount, 4)
        XCTAssertEqual(summary.minimumRepeatDistance, 3)
        XCTAssertEqual(try XCTUnwrap(summary.medianRepeatDistance), 9.5, accuracy: 0.000_1)
        XCTAssertEqual(summary.repeatDistanceBuckets["0-4"], 1)
        XCTAssertEqual(summary.repeatDistanceBuckets["5-9"], 1)
        XCTAssertEqual(summary.repeatDistanceBuckets["10-19"], 1)
        XCTAssertEqual(summary.repeatDistanceBuckets["20+"], 1)
        XCTAssertEqual(summary.performerCounts["P01"], 4)
        XCTAssertEqual(summary.performerCounts["P02"], 3)
        XCTAssertEqual(summary.performerCounts["P03"], 1)
        XCTAssertEqual(summary.voiceFamilyCounts["low"], 4)
        XCTAssertEqual(summary.voiceFamilyCounts["high"], 3)
        XCTAssertEqual(summary.maxConsecutiveSamePerformer, 2)
        XCTAssertEqual(summary.maxConsecutiveSameVoiceFamily, 2)
        XCTAssertEqual(summary.relaxedConstraintCounts[RelaxedConstraint.phoneticFamily.rawValue], 1)
        XCTAssertEqual(summary.relaxedConstraintCounts[RelaxedConstraint.recentWindow.rawValue], 1)
        XCTAssertEqual(summary.relaxedConstraintCounts[RelaxedConstraint.highRecognitionRisk.rawValue], 1)
        XCTAssertEqual(summary.eventsRequiringRelaxation, 3)
        XCTAssertEqual(summary.relaxationPercent ?? -1, 37.5, accuracy: 0.01)
        XCTAssertEqual(summary.observedSweepRateMs, [75, 125, 200, 300])
        XCTAssertEqual(summary.observedDirections, ["FWD", "REV"])
        XCTAssertTrue(summary.isDocumentsPhase1)
        XCTAssertFalse(summary.isDevFixture)
        XCTAssertEqual(summary.performerPercents["P01"] ?? 0, 50.0, accuracy: 0.01)
    }

    func testSummaryIgnoresEventsOutsideTheProvidedRunSet() {
        let before = makeEvent(asset: "OLD", performer: "PX", family: "x", since: nil, relaxed: [])
        let during = makeEvent(asset: "NEW", performer: "PY", family: "y", since: nil, relaxed: [])
        let summary = AudioGateRunSummary.make(
            runID: "bounded",
            startedAt: Date(),
            endedAt: Date(),
            requestedDurationSeconds: 120,
            capturedDurationSeconds: 10,
            completion: .stoppedEarly,
            failureMessage: nil,
            corpus: .empty,
            startingSweepRate: .ms200,
            startingDirection: .forward,
            events: [during]
        )
        XCTAssertEqual(summary.totalEvents, 1)
        XCTAssertEqual(summary.uniqueAssetIDs, 1)
        XCTAssertFalse(summary.jsonObject().description.contains("OLD"))
        _ = before
    }

    func testEmptyEventSetIsGraceful() throws {
        let summary = AudioGateRunSummary.make(
            runID: "empty",
            startedAt: Date(timeIntervalSince1970: 1),
            endedAt: Date(timeIntervalSince1970: 2),
            requestedDurationSeconds: 120,
            capturedDurationSeconds: 0,
            completion: .stoppedEarly,
            failureMessage: nil,
            corpus: LoadedCorpus(
                assets: [SourceAsset(assetID: "A", relativePath: "a.wav")],
                skippedMalformedCount: 0,
                source: .bundlePhase1,
                label: "bundled",
                isDevFixture: false,
                rootURL: nil
            ),
            startingSweepRate: .ms200,
            startingDirection: .reverse,
            events: []
        )
        XCTAssertEqual(summary.totalEvents, 0)
        XCTAssertEqual(summary.uniqueAssetIDs, 0)
        XCTAssertEqual(summary.corpusCoverage, 0)
        XCTAssertNil(summary.minimumRepeatDistance)
        XCTAssertNil(summary.medianRepeatDistance)
        XCTAssertEqual(summary.repeatDistanceBuckets["0-4"], 0)
        XCTAssertEqual(summary.maxConsecutiveSamePerformer, 0)
        XCTAssertEqual(summary.maxConsecutiveSameVoiceFamily, 0)
        XCTAssertTrue(summary.performerCounts.isEmpty)
        XCTAssertNil(summary.relaxationPercent)
        let json = try summary.jsonData()
        XCTAssertFalse(json.isEmpty)
    }

    func testMissingPerformerAndFamilyMetadataIsGraceful() {
        let events = [
            makeEvent(asset: "A", performer: nil, family: nil, since: nil, relaxed: []),
            makeEvent(asset: "B", performer: nil, family: nil, since: 4, relaxed: []),
            makeEvent(asset: "A", performer: "P01", family: "low", since: 1, relaxed: []),
        ]
        let summary = AudioGateRunSummary.make(
            runID: "meta",
            startedAt: Date(),
            endedAt: Date(),
            requestedDurationSeconds: 120,
            capturedDurationSeconds: 5,
            completion: .completed,
            failureMessage: nil,
            corpus: LoadedCorpus(
                assets: [
                    SourceAsset(assetID: "A", relativePath: "a.wav"),
                    SourceAsset(assetID: "B", relativePath: "b.wav"),
                ],
                skippedMalformedCount: 0,
                source: .bundleDevFixtures,
                label: "DEV",
                isDevFixture: true,
                rootURL: nil
            ),
            startingSweepRate: .ms200,
            startingDirection: .forward,
            events: events
        )
        XCTAssertEqual(summary.performerCounts["P01"], 1)
        XCTAssertEqual(summary.performerCounts.count, 1)
        XCTAssertEqual(summary.voiceFamilyCounts["low"], 1)
        XCTAssertEqual(summary.maxConsecutiveSamePerformer, 1)
        XCTAssertTrue(summary.isDevFixture)
    }

    func testZeroAssetCorpusDoesNotDivideByZero() throws {
        let summary = AudioGateRunSummary.make(
            runID: "zero",
            startedAt: Date(),
            endedAt: Date(),
            requestedDurationSeconds: 120,
            capturedDurationSeconds: 1,
            completion: .completed,
            failureMessage: nil,
            corpus: .empty,
            startingSweepRate: .ms200,
            startingDirection: .forward,
            events: [makeEvent(asset: "ghost", performer: nil, family: nil, since: nil, relaxed: [])]
        )
        XCTAssertNil(summary.corpusCoverage)
        let object = summary.jsonObject()
        XCTAssertTrue(object["corpus_coverage"] is NSNull)
        XCTAssertTrue(summary.markdown().contains("NOT YET PASSED BY THIS RUN"))
        XCTAssertTrue(summary.markdown().contains("n/a (zero-asset corpus)"))
        XCTAssertFalse(summary.markdown().contains("believable"))
        XCTAssertFalse(summary.markdown().contains("paranormal score"))
    }

    func testCompletionResolver() {
        XCTAssertEqual(
            AudioGateRunCompletionResolver.resolve(reason: .durationReached, reportingError: nil),
            .completed
        )
        XCTAssertEqual(
            AudioGateRunCompletionResolver.resolve(reason: .userStopped, reportingError: nil),
            .stoppedEarly
        )
        XCTAssertEqual(
            AudioGateRunCompletionResolver.resolve(reason: .userStopped, reportingError: "summary write issue"),
            .stoppedEarly
        )
        XCTAssertEqual(
            AudioGateRunCompletionResolver.resolve(reason: .durationReached, reportingError: "summary write issue"),
            .failed
        )
        XCTAssertEqual(
            AudioGateRunCompletionResolver.resolve(reason: .failed("disk"), reportingError: nil),
            .failed
        )
    }

    func testBundleWriterWritesRequiredFilesAndRefusesOverwrite() throws {
        let location = try AudioGateRunLocator.createUniqueRunDirectory(in: scratchDirectory, shortID: "cccccccc")
        try AudioGateRunBundleWriter.writeListeningNotes(to: location.listeningNotesURL, runID: location.runID)

        let notes = try String(contentsOf: location.listeningNotesURL, encoding: .utf8)
        XCTAssertTrue(notes.contains("Run ID: \(location.runID)"))
        XCTAssertTrue(notes.contains("What, if anything, made the audio feel artificial?"))
        XCTAssertTrue(notes.contains("Did you notice repeated sounds or voices?"))
        XCTAssertTrue(notes.contains("Did anything seem timed as a response to what was said?"))
        XCTAssertTrue(notes.contains("continuous instrument"))
        XCTAssertFalse(notes.lowercased().contains("ghost"))
        XCTAssertFalse(notes.lowercased().contains("paranormal"))

        let summary = AudioGateRunSummary.make(
            runID: location.runID,
            startedAt: Date(timeIntervalSince1970: 50),
            endedAt: Date(timeIntervalSince1970: 80),
            requestedDurationSeconds: 120,
            capturedDurationSeconds: 30,
            completion: .stoppedEarly,
            failureMessage: nil,
            corpus: LoadedCorpus(
                assets: [],
                skippedMalformedCount: 0,
                source: .bundleDevFixtures,
                label: "DEV fixtures",
                isDevFixture: true,
                rootURL: nil
            ),
            startingSweepRate: .ms200,
            startingDirection: .forward,
            events: []
        )
        try AudioGateRunBundleWriter.writeSummaries(summary, location: location)
        XCTAssertTrue(FileManager.default.fileExists(atPath: location.summaryJSONURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: location.summaryMarkdownURL.path))

        let markdown = try String(contentsOf: location.summaryMarkdownURL, encoding: .utf8)
        XCTAssertTrue(markdown.hasPrefix("AUDIO GATE STATUS:"))
        XCTAssertTrue(markdown.contains("NOT YET PASSED BY THIS RUN"))
        XCTAssertTrue(markdown.contains("DEV FIXTURES CANNOT PASS THE CANONICAL AUDIO GATE."))
        XCTAssertTrue(markdown.contains("INCOMPLETE / STOPPED EARLY"))
        XCTAssertFalse(markdown.contains("believable"))
        XCTAssertFalse(markdown.contains("authentic"))

        XCTAssertThrowsError(
            try AudioGateRunBundleWriter.writeListeningNotes(to: location.listeningNotesURL, runID: "other")
        )
        XCTAssertEqual(try String(contentsOf: location.listeningNotesURL, encoding: .utf8), notes)
        XCTAssertThrowsError(try AudioGateRunBundleWriter.writeSummaries(summary, location: location))
    }

    func testWriterCanTargetARunDirectoryWAVPath() throws {
        let location = try AudioGateRunLocator.createUniqueRunDirectory(in: scratchDirectory, shortID: "dddddddd")
        XCTAssertEqual(location.wavURL.deletingLastPathComponent().path, location.directoryURL.path)
        XCTAssertEqual(EngineOutputCaptureLocator.makeEventLogURL(forCaptureURL: location.wavURL).pathExtension, "jsonl")
    }

    private func makeEvent(
        asset: String,
        performer: String?,
        family: String?,
        since: Int?,
        relaxed: [RelaxedConstraint],
        rate: SweepRate = .ms200,
        direction: SweepDirection = .forward
    ) -> SweepEvent {
        SweepEvent(
            timestamp: Date(timeIntervalSince1970: 100),
            assetID: asset,
            performerID: performer,
            voiceFamily: family,
            phoneticFamily: nil,
            sourceType: nil,
            sweepRate: rate,
            direction: direction,
            eventsSincePreviousUse: since,
            relaxedConstraints: relaxed,
            decisionSummary: relaxed.isEmpty ? "all constraints satisfied" : "relaxed"
        )
    }
}
