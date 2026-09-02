import XCTest
@testable import SpiritBoxAudioHarness

final class SweepEventLogTests: XCTestCase {
    func testLogKeepsRequiredFieldsAndCapacity() {
        let log = SweepEventLog(capacity: 3)
        for index in 1...5 {
            log.append(
                SweepEvent(
                    timestamp: Date(timeIntervalSince1970: TimeInterval(index)),
                    assetID: "A\(index)",
                    performerID: "P1",
                    voiceFamily: "low_dry",
                    phoneticFamily: "front_vowel",
                    sourceType: "vowel",
                    sweepRate: .ms200,
                    direction: .reverse,
                    eventsSincePreviousUse: index == 1 ? nil : 2,
                    relaxedConstraints: [],
                    decisionSummary: "all constraints satisfied"
                )
            )
        }

        XCTAssertEqual(log.count, 3)
        let recent = log.recent(limit: 10)
        XCTAssertEqual(recent.map(\.assetID), ["A5", "A4", "A3"])
        XCTAssertEqual(recent[0].sweepRate, .ms200)
        XCTAssertEqual(recent[0].direction, .reverse)
        XCTAssertEqual(recent[0].voiceFamily, "low_dry")
        XCTAssertEqual(recent[0].phoneticFamily, "front_vowel")
        XCTAssertEqual(recent[0].eventsSincePreviousUse, 2)
    }

    func testCaptureLocatorUsesDiagnosticEngineMixName() {
        let docs = URL(fileURLWithPath: "/tmp/docs")
        let url = EngineOutputCaptureLocator.makeFileURL(
            in: docs,
            now: Date(timeIntervalSince1970: 1_700_000_000)
        )
        XCTAssertTrue(url.path.contains(EngineOutputCaptureLocator.directoryName))
        XCTAssertTrue(url.lastPathComponent.hasPrefix("engine-output-capture-"))
        XCTAssertTrue(url.pathExtension == "wav")
        XCTAssertFalse(url.lastPathComponent.contains("session"))
        XCTAssertFalse(url.path.contains("microphone"))
        XCTAssertEqual(EngineOutputCaptureLocator.defaultDurationSeconds, 120)
        XCTAssertGreaterThanOrEqual(EngineOutputCaptureLocator.manualEvaluationDurationSeconds, 1200)
        let events = EngineOutputCaptureLocator.makeEventLogURL(forCaptureURL: url)
        XCTAssertEqual(events.pathExtension, "jsonl")
        XCTAssertTrue(events.lastPathComponent.contains("engine-output-capture-"))
        XCTAssertFalse(events.lastPathComponent.contains("session"))
    }

    func testDefaultLogCapacityCoversATwentyMinuteFastSweep() {
        XCTAssertGreaterThanOrEqual(SweepEventLog().capacity, 16_000)
    }
}
