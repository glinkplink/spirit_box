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

    func testHighRecognitionRiskIsAvoidedWhenSaferAlternativesExist() {
        let scheduler = SweepScheduler(
            assets: [
                SourceAsset(assetID: "A", recognitionRisk: "high", relativePath: "a.wav"),
                SourceAsset(assetID: "B", recognitionRisk: "low", relativePath: "b.wav"),
            ],
            configuration: .unconstrained
        )

        XCTAssertEqual(id(scheduler.next(direction: .forward)), "B")
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
        XCTAssertTrue(event.containsVocal)
        XCTAssertFalse(event.debugLine.contains("answer"))
        XCTAssertFalse(event.debugLine.contains("ghost"))
    }
    func testVCTKCooldownsAndNeighborWindowsCannotReconstructUtterances() {
        // Two neighboring windows per source sentence, deliberately grouped by
        // speaker/utterance in input order. Runtime must break that ordering.
        let assets = (0..<480).map { index in
            SourceAsset(assetID: "window-\(index)", utteranceID: "sentence-\(index / 2)",
                        sourceStartFrame: (index % 2) * 9600, sourceFrameCount: 9600,
                        performerID: "speaker-\(index / 80)")
        }
        let scheduler = SweepScheduler(assets: assets, seed: 1234)
        var ids: [String] = [], sentences: [String] = [], speakers: [String] = []
        for index in 0..<5000 {
            let direction: SweepDirection = index % 77 < 38 ? .forward : .reverse
            guard case .picked(let pick) = scheduler.next(direction: direction) else {
                return XCTFail("A full bank must keep scheduling")
            }
            XCTAssertFalse(ids.suffix(64).contains(pick.asset.assetID))
            XCTAssertFalse(sentences.suffix(32).contains(pick.asset.utteranceID!))
            XCTAssertFalse(speakers.suffix(2).contains(pick.asset.performerID!))
            XCTAssertTrue(pick.relaxedConstraints.isEmpty)
            if let distance = pick.eventsSinceSpeakerUse { XCTAssertGreaterThan(distance, 2) }
            ids.append(pick.asset.assetID)
            sentences.append(pick.asset.utteranceID!)
            speakers.append(pick.asset.performerID!)
        }
        XCTAssertEqual(Set(speakers).count, 6)
        XCTAssertGreaterThan(Set(ids).count, 450)
    }

    func testVCTKSeedReplayAndOppositeRingTraversal() {
        let assets = (0..<120).map { index in
            SourceAsset(assetID: "\(index)", utteranceID: "u\(index)", performerID: "p\(index % 6)")
        }
        let a = SweepScheduler(assets: assets, seed: 88)
        let b = SweepScheduler(assets: assets, seed: 88)
        let c = SweepScheduler(assets: assets, seed: 89)
        XCTAssertEqual(a.orderedEligibleAssets(for: .forward).map(\.assetID),
                       a.orderedEligibleAssets(for: .reverse).reversed().map(\.assetID))
        let first = ids(fromRepeating: a, direction: .forward, count: 300)
        XCTAssertEqual(first, ids(fromRepeating: b, direction: .forward, count: 300))
        XCTAssertNotEqual(first, ids(fromRepeating: c, direction: .forward, count: 300))
        b.resetHistory()
        XCTAssertNotEqual(first, ids(fromRepeating: b, direction: .reverse, count: 300))
        a.resetHistory()
        XCTAssertEqual(first, ids(fromRepeating: a, direction: .forward, count: 300))
    }

    func testProvenanceCoverageAcrossSeedsAndDirectionChanges() {
        let assets = (0..<480).map { index in
            SourceAsset(assetID: "window-\(index)", utteranceID: "sentence-\(index / 2)",
                        performerID: "speaker-\(index / 80)")
        }
        // Include zero, extrema, related seeds and the original failing seed.
        for seed in Array(UInt64(0)...UInt64(15)) + [1234, 0xC0FFEE, UInt64.max] {
            for mode in 0..<3 {
                let scheduler = SweepScheduler(assets: assets, seed: seed)
                var seen = Set<String>()
                for index in 0..<5000 {
                    let direction: SweepDirection = mode == 0 ? .forward :
                        mode == 1 ? .reverse : (index % 77 < 38 ? .forward : .reverse)
                    guard case .picked(let pick) = scheduler.next(direction: direction) else {
                        return XCTFail("Full corpus exhausted: seed \(seed)")
                    }
                    seen.insert(pick.asset.assetID)
                }
                XCTAssertEqual(seen.count, 480, "seed \(seed), mode \(mode)")
            }
        }
    }

    func testBundledVCTKCoverageOverTwentyMinutesWithCooldowns() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "Phase1"))
        let assets = try JSONDecoder().decode(CorpusManifest.self, from: Data(contentsOf: url)).assets
        XCTAssertEqual(assets.count, 1200)
        for seed in [UInt64(0), 1234, 0xC0FFEE, UInt64.max] {
            let scheduler = SweepScheduler(assets: assets, seed: seed)
            var seen = Set<String>(), fragments: [String] = [], utterances: [String] = [], speakers: [String] = []
            // 4,000 slots = 20 minutes at the slowest 300 ms dwell.
            for index in 0..<4000 {
                let direction: SweepDirection = index % 77 < 38 ? .forward : .reverse
                guard case .picked(let pick) = scheduler.next(direction: direction) else {
                    return XCTFail("Bundled corpus exhausted")
                }
                let utterance = try XCTUnwrap(pick.asset.utteranceID)
                let speaker = try XCTUnwrap(pick.asset.performerID)
                XCTAssertFalse(fragments.suffix(64).contains(pick.asset.assetID))
                XCTAssertFalse(utterances.suffix(32).contains(utterance))
                XCTAssertFalse(speakers.suffix(2).contains(speaker))
                XCTAssertTrue(pick.relaxedConstraints.isEmpty)
                fragments.append(pick.asset.assetID); utterances.append(utterance); speakers.append(speaker)
                seen.insert(pick.asset.assetID)
                // Two corpus-sized event budgets allow protection-driven deferrals.
                // Full coverage is required, not a fitted percentage.
                if index == 2399 { XCTAssertEqual(seen.count, 1200, "seed \(seed)") }
            }
            XCTAssertEqual(seen.count, 1200)
        }
    }

    func testProvenanceDirectionChoosesOppositeNextAdmissibleRingNeighbor() {
        let assets = (0..<120).map { index in
            SourceAsset(assetID: "a\(index)", utteranceID: "u\(index)", performerID: "p\(index % 6)")
        }
        let scheduler = SweepScheduler(assets: assets, seed: 1234)
        let ring = scheduler.orderedEligibleAssets(for: .forward)
        guard case .picked(let first) = scheduler.next(direction: .forward) else { return XCTFail("First") }
        XCTAssertEqual(first.asset, ring[0])
        let expected = ring.reversed().first { $0.performerID != first.asset.performerID }
        XCTAssertEqual(id(scheduler.next(direction: .reverse)), expected?.assetID)
    }

    func testSentenceConstraintsNeverRelaxEvenForSingleSource() {
        let scheduler = SweepScheduler(assets: [
            SourceAsset(assetID: "a", utteranceID: "same-sentence", performerID: "p1"),
            SourceAsset(assetID: "b", utteranceID: "same-sentence", performerID: "p2")
        ])
        guard case .picked = scheduler.next(direction: .forward) else { return XCTFail("First pick") }
        XCTAssertEqual(scheduler.next(direction: .forward), .emptyCorpus)
        XCTAssertEqual(scheduler.next(direction: .reverse), .emptyCorpus)
    }

    func testLegacyVCTKManifestCannotBypassMissingProvenance() {
        let scheduler = SweepScheduler(assets: [SourceAsset(assetID: "old-vctk", performerID: "p225",
            rightsRecordID: "VCTK-0.92-CCBY4")])
        XCTAssertEqual(scheduler.next(direction: .forward), .emptyCorpus)
    }

    func testProvenanceSurvivesJSONAndEventLogging() throws {
        let original = SourceAsset(assetID: "a", utteranceID: "p225_001", sourceFile: "p225_001_mic1.flac",
                                   sourceStartFrame: 4800, sourceFrameCount: 9600, performerID: "p225")
        let asset = try JSONDecoder().decode(SourceAsset.self, from: JSONEncoder().encode(original))
        XCTAssertEqual(original, asset)
        let scheduler = SweepScheduler(assets: [asset])
        guard case .picked(let pick) = scheduler.next(direction: .forward) else { return XCTFail("Pick") }
        let event = SweepEvent(pick: pick, rate: .ms75, direction: .reverse)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(event.diagnosticJSONLine().utf8)) as? [String: Any])
        XCTAssertEqual(payload["utterance_id"] as? String, "p225_001")
        XCTAssertEqual(payload["source_start_frame"] as? Int, 4800)
        XCTAssertEqual(payload["source_frame_count"] as? Int, 9600)
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
