import XCTest
@testable import SpiritBoxAudioHarness

final class SweepSchedulerTests: XCTestCase {
    func testImmediateRepeatIsPreventedWhenAlternativesExist() {
        let scheduler = SweepScheduler(
            assets: [
                .stub("A", performer: "P1", family: "fa"),
                .stub("B", performer: "P2", family: "fb"),
            ],
            configuration: .unconstrained
        )

        var previous = id(scheduler.next(direction: .forward))
        XCTAssertEqual(previous, "A")

        for _ in 0..<20 {
            guard case .picked(let pick) = scheduler.next(direction: .forward) else {
                return XCTFail("Expected a pick")
            }
            XCTAssertNotEqual(
                pick.asset.assetID,
                previous,
                "Must not schedule the same asset consecutively when an alternative exists"
            )
            previous = pick.asset.assetID
        }
    }

    func testRollingExclusionWindowIsHonoredThenRelaxed() {
        let scheduler = SweepScheduler(
            assets: [
                .stub("A", performer: "P1", family: "fa"),
                .stub("B", performer: "P2", family: "fb"),
            ],
            configuration: SchedulerConfiguration(
                recentExclusionWindow: 2,
                avoidConsecutiveSamePerformerOrVoiceFamily: false,
                avoidConsecutiveSamePhoneticOrSourceFamily: false
            )
        )

        XCTAssertEqual(id(scheduler.next(direction: .forward)), "A")
        XCTAssertEqual(id(scheduler.next(direction: .forward)), "B")

        guard case .picked(let third) = scheduler.next(direction: .forward) else {
            return XCTFail("Expected a relaxed pick")
        }
        XCTAssertEqual(third.asset.assetID, "A")
        XCTAssertTrue(
            third.relaxedConstraints.contains(.recentWindow),
            "A 2-asset bank with window=2 must relax the window rather than deadlock"
        )
    }

    func testTinyBankRelaxesFamilyConstraintsInsteadOfDeadlocking() {
        let scheduler = SweepScheduler(
            assets: [
                .stub("A", performer: "P1", family: "same"),
                .stub("B", performer: "P1", family: "same"),
            ],
            configuration: SchedulerConfiguration(
                recentExclusionWindow: 8,
                avoidConsecutiveSamePerformerOrVoiceFamily: true,
                avoidConsecutiveSamePhoneticOrSourceFamily: true
            )
        )

        var picks: [SchedulePick] = []
        for _ in 0..<6 {
            guard case .picked(let pick) = scheduler.next(direction: .forward) else {
                return XCTFail("Tiny bank must keep producing audio")
            }
            picks.append(pick)
        }

        XCTAssertEqual(picks.map(\.asset.assetID), ["A", "B", "A", "B", "A", "B"])
        XCTAssertTrue(picks.dropFirst(2).contains { !$0.relaxedConstraints.isEmpty })
    }

    func testForwardAndReverseAreDeterministicOppositeTraversals() {
        let assets = [
            SourceAsset.stub("A", performer: "P1", family: "fa"),
            SourceAsset.stub("B", performer: "P2", family: "fb"),
            SourceAsset.stub("C", performer: "P3", family: "fc"),
        ]

        let forward = SweepScheduler(assets: assets, configuration: .unconstrained)
        let reverse = SweepScheduler(assets: assets, configuration: .unconstrained)

        let forwardIDs = ids(fromRepeating: forward, direction: .forward, count: 6)
        let reverseIDs = ids(fromRepeating: reverse, direction: .reverse, count: 6)

        XCTAssertEqual(forwardIDs, ["A", "B", "C", "A", "B", "C"])
        XCTAssertEqual(reverseIDs, ["C", "B", "A", "C", "B", "A"])
        XCTAssertNotEqual(forwardIDs, reverseIDs)
    }

    func testZeroAssetsFailGracefully() {
        let scheduler = SweepScheduler(assets: [])
        XCTAssertEqual(scheduler.acceptedAssetCount, 0)
        XCTAssertEqual(scheduler.orderedEligibleAssets(for: .forward).count, 0)
        XCTAssertEqual(scheduler.next(direction: .forward), .emptyCorpus)
        XCTAssertEqual(scheduler.next(direction: .reverse), .emptyCorpus)
    }

    func testOneAssetNeverRetriesInfinitelyAndMayRepeat() {
        let scheduler = SweepScheduler(
            assets: [.stub("ONLY", performer: "P1", family: "fa")],
            configuration: SchedulerConfiguration(recentExclusionWindow: 8)
        )

        var picks: [SchedulePick] = []
        for _ in 0..<4 {
            guard case .picked(let pick) = scheduler.next(direction: .forward) else {
                return XCTFail("One-asset bank must keep producing")
            }
            picks.append(pick)
        }

        XCTAssertEqual(picks.map(\.asset.assetID), ["ONLY", "ONLY", "ONLY", "ONLY"])
        XCTAssertNil(picks[0].eventsSincePreviousUse)
        XCTAssertEqual(picks[1].eventsSincePreviousUse, 1)
        XCTAssertTrue(picks[1].relaxedConstraints.contains(.recentWindow) || picks[1].relaxedConstraints.contains(.consecutiveAsset))
    }

    func testSmallBankPrefersDifferentPerformerWhenAvailable() {
        let scheduler = SweepScheduler(
            assets: [
                .stub("A", performer: "P1", family: "fa"),
                .stub("B", performer: "P1", family: "fb"),
                .stub("C", performer: "P2", family: "fc"),
            ],
            configuration: SchedulerConfiguration(
                recentExclusionWindow: 0,
                avoidConsecutiveSamePerformerOrVoiceFamily: true,
                avoidConsecutiveSamePhoneticOrSourceFamily: false
            )
        )

        XCTAssertEqual(id(scheduler.next(direction: .forward)), "A")
        XCTAssertEqual(id(scheduler.next(direction: .forward)), "C")
    }

    func testMissingOptionalMetadataIsNotTreatedAsASharedFamily() {
        let scheduler = SweepScheduler(
            assets: [
                SourceAsset(assetID: "A", relativePath: "a.wav"),
                SourceAsset(assetID: "B", relativePath: "b.wav"),
                SourceAsset(assetID: "C", relativePath: "c.wav"),
            ],
            configuration: SchedulerConfiguration(
                recentExclusionWindow: 0,
                avoidConsecutiveSamePerformerOrVoiceFamily: true,
                avoidConsecutiveSamePhoneticOrSourceFamily: true
            )
        )

        XCTAssertEqual(
            ids(fromRepeating: scheduler, direction: .forward, count: 3),
            ["A", "B", "C"]
        )
    }

    func testDirectionEligibilityFiltersAssets() {
        let assets = [
            SourceAsset.stub("FWD_ONLY", performer: "P1", family: "fa", forward: true, reverse: false),
            SourceAsset.stub("REV_ONLY", performer: "P2", family: "fb", forward: false, reverse: true),
        ]
        let scheduler = SweepScheduler(assets: assets, configuration: .unconstrained)

        XCTAssertEqual(scheduler.orderedEligibleAssets(for: .forward).map(\.assetID), ["FWD_ONLY"])
        XCTAssertEqual(scheduler.orderedEligibleAssets(for: .reverse).map(\.assetID), ["REV_ONLY"])
        XCTAssertEqual(id(scheduler.next(direction: .forward)), "FWD_ONLY")
    }

    func testIneligibleBothDirectionsNeverScheduled() {
        let scheduler = SweepScheduler(
            assets: [
                SourceAsset(
                    assetID: "DEAD",
                    performerID: "P1",
                    phoneticFamily: "x",
                    forwardAllowed: false,
                    reverseAllowed: false,
                    relativePath: "dead.wav"
                ),
            ]
        )
        XCTAssertEqual(scheduler.next(direction: .forward), .emptyCorpus)
    }

    func testEventIncludesRequiredDiagnosticFields() {
        let scheduler = SweepScheduler(
            assets: [
                .stub("A", performer: "P1", family: "fa", voice: "low_dry"),
                .stub("B", performer: "P2", family: "fb", voice: "mid_neutral"),
            ],
            configuration: .unconstrained
        )
        _ = scheduler.next(direction: .forward)
        guard case .picked(let second) = scheduler.next(direction: .forward) else {
            return XCTFail("Expected second pick")
        }

        let event = SweepEvent(pick: second, rate: .ms125, direction: .forward, timestamp: Date(timeIntervalSince1970: 1))
        XCTAssertEqual(event.assetID, "B")
        XCTAssertEqual(event.performerID, "P2")
        XCTAssertEqual(event.voiceFamily, "mid_neutral")
        XCTAssertEqual(event.phoneticFamily, "fb")
        XCTAssertEqual(event.sweepRate, .ms125)
        XCTAssertEqual(event.direction, .forward)
        XCTAssertEqual(event.eventsSincePreviousUse, nil)
        XCTAssertFalse(event.debugLine.contains("answer"))
        XCTAssertFalse(event.debugLine.contains("ghost"))
    }
}

private extension SweepSchedulerTests {
    func id(_ outcome: ScheduleOutcome) -> String? {
        if case .picked(let pick) = outcome {
            return pick.asset.assetID
        }
        return nil
    }

    func ids(fromRepeating scheduler: SweepScheduler, direction: SweepDirection, count: Int) -> [String] {
        (0..<count).compactMap { _ in id(scheduler.next(direction: direction)) }
    }
}

private extension SchedulerConfiguration {
    static let unconstrained = SchedulerConfiguration(
        recentExclusionWindow: 0,
        avoidConsecutiveSamePerformerOrVoiceFamily: false,
        avoidConsecutiveSamePhoneticOrSourceFamily: false
    )
}

private extension SourceAsset {
    static func stub(
        _ id: String,
        performer: String? = nil,
        family: String? = nil,
        voice: String? = nil,
        forward: Bool = true,
        reverse: Bool = true
    ) -> SourceAsset {
        SourceAsset(
            assetID: id,
            performerID: performer,
            voiceFamily: voice,
            phoneticFamily: family,
            forwardAllowed: forward,
            reverseAllowed: reverse,
            relativePath: "\(id).wav"
        )
    }
}
