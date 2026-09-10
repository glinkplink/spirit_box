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

    func testNoiseOnlyEventsAreLoggedWithoutAssetIdentity() {
        let event = SweepEvent.noiseOnlySlot(
            rate: .ms300, direction: .forward, timestamp: Date(timeIntervalSince1970: 1)
        )
        XCTAssertFalse(event.containsVocal)
        XCTAssertTrue(event.assetID.isEmpty)
        XCTAssertTrue(event.debugLine.contains("noise"))
        XCTAssertTrue(event.debugLine.contains("300ms"))
        XCTAssertTrue(event.debugLine.contains("FWD"))
        XCTAssertFalse(event.debugLine.contains("answer"))
        let payload = try? JSONSerialization.jsonObject(with: Data(event.diagnosticJSONLine().utf8)) as? [String: Any]
        XCTAssertEqual(payload?["contains_vocal"] as? Bool, false)
        XCTAssertEqual(payload?["sweep_rate_ms"] as? Int, 300)
        XCTAssertNil(payload?["capture_time_seconds"])
    }

    func testCaptureRelativeTimestampIsExportedWhenPresent() {
        var event = SweepEvent.noiseOnlySlot(
            rate: .ms300, direction: .forward, timestamp: Date(timeIntervalSince1970: 1)
        )
        event.renderTimeSeconds = 136.9
        event.captureTimeSeconds = 0.3
        let payload = try? JSONSerialization.jsonObject(with: Data(event.diagnosticJSONLine().utf8)) as? [String: Any]
        XCTAssertEqual(payload?["render_time_seconds"] as? Double, 136.9)
        XCTAssertEqual(payload?["capture_time_seconds"] as? Double, 0.3)
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
