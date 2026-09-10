import XCTest
@testable import SpiritBoxAudioHarness

final class VocalDensitySchedulerTests: XCTestCase {
    func testListeningTestDensityIsIntermittentNotEverySlot() {
        let scheduler = VocalDensityScheduler(settings: .listeningTest, seed: 1_264_8430)
        var vocals = 0
        var maxNoise = 0
        var maxVocal = 0
        var noiseRun = 0
        var vocalRun = 0
        var flips = 0
        var previous: Bool?
        // Long enough that a 60 s clip's statistical scatter is not the contract.
        let slots = 8_000
        for _ in 0..<slots {
            let vocal = scheduler.nextContainsVocal()
            if let previous, previous != vocal { flips += 1 }
            previous = vocal
            if vocal {
                vocals += 1
                vocalRun += 1
                maxVocal = max(maxVocal, vocalRun)
                noiseRun = 0
            } else {
                noiseRun += 1
                maxNoise = max(maxNoise, noiseRun)
                vocalRun = 0
            }
        }
        let density = Double(vocals) / Double(slots)
        XCTAssertEqual(SweepRendererSettings.listeningTest.vocalEventProbability, 0.07, accuracy: 0.000_1)
        XCTAssertGreaterThan(density, 0.03)
        XCTAssertLessThan(density, 0.12)
        XCTAssertGreaterThan(maxNoise, 5, "Need consecutive noise-only slots")
        XCTAssertEqual(maxVocal, 2, "Occasional pairs, never longer bursts")
        XCTAssertLessThan(Double(flips) / Double(slots - 1), 0.30, "Must not be a metronomic alternate")
    }

    func testZeroProbabilityNeverSchedulesVocals() {
        let scheduler = VocalDensityScheduler(
            settings: SweepRendererSettings(vocalEventProbability: 0, clusteriness: 0.45),
            seed: 99
        )
        XCTAssertFalse((0..<400).contains { _ in scheduler.nextContainsVocal() })
    }

    func testFullProbabilityStillForcesEveryThirdSlotToNoise() {
        let scheduler = VocalDensityScheduler(
            settings: SweepRendererSettings(vocalEventProbability: 1, clusteriness: 0),
            seed: 99
        )
        let expected = (0..<200).map { $0 % 3 != 2 }
        XCTAssertEqual((0..<200).map { _ in scheduler.nextContainsVocal() }, expected)
        scheduler.reset(seed: 99)
        XCTAssertEqual((0..<200).map { _ in scheduler.nextContainsVocal() }, expected)
    }

    func testSameSeedReplaysAndDifferentSeedDiverges() {
        let a = VocalDensityScheduler(settings: .listeningTest, seed: 88)
        let b = VocalDensityScheduler(settings: .listeningTest, seed: 88)
        let c = VocalDensityScheduler(settings: .listeningTest, seed: 89)
        let first = (0..<300).map { _ in a.nextContainsVocal() }
        XCTAssertEqual(first, (0..<300).map { _ in b.nextContainsVocal() })
        XCTAssertNotEqual(first, (0..<300).map { _ in c.nextContainsVocal() })
    }

    func testListeningTestMixUsesAudibleBed() {
        XCTAssertEqual(SweepRendererSettings.listeningTest.staticGain, 0.047, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTest.vocalGain, 0.60, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTest.outputGain, 4.28, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTestGainRebalance.staticGain, 0.047, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTestGainRebalance.vocalGain, 0.60, accuracy: 0.001)
        XCTAssertFalse(SweepRendererSettings.listeningTestGainRebalance.usesDecoupledBedShape)
        XCTAssertFalse(SweepRendererSettings.listeningTest.usesDecoupledBedShape)
        XCTAssertEqual(SweepRendererSettings.listeningTest.clusteriness, 0.0, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTest.minVocalExposureSeconds, 0.100, accuracy: 0.000_1)
        XCTAssertEqual(SweepRendererSettings.listeningTest.maxVocalExposureSeconds, 0.180, accuracy: 0.000_1)
        XCTAssertEqual(SweepRendererSettings.listeningTest.minExposureFractionOfDwell, 0.40, accuracy: 0.000_1)
        XCTAssertEqual(SweepRendererSettings.listeningTest.maxExposureFractionOfDwell, 0.65, accuracy: 0.000_1)
        XCTAssertEqual(SweepRendererSettings.listeningTest.fadeSeconds, 0.015, accuracy: 0.000_1)
        XCTAssertEqual(SweepRendererSettings.listeningTest.recentExclusionWindow, 8)
        XCTAssertEqual(SweepRate.default, .ms300)
    }

    func testSharedPresetReachesAFreshEngineUnchanged() {
        let engine = SweepAudioEngine()
        XCTAssertEqual(engine.currentRendererSettings, .listeningTest)
        XCTAssertEqual(engine.currentRendererSettings.namedPreset.identifier, "listening-test")
        XCTAssertEqual(
            engine.currentRendererSettings.namedPreset.version,
            SweepRendererSettings.listeningTestIdentity.version
        )
    }

    func testZeroClusterinessStillCapsTwoVocalRuns() {
        let scheduler = VocalDensityScheduler(
            settings: SweepRendererSettings(vocalEventProbability: 1, clusteriness: 0),
            seed: 1
        )
        var maxVocal = 0
        var run = 0
        for _ in 0..<300 {
            if scheduler.nextContainsVocal() {
                run += 1
                maxVocal = max(maxVocal, run)
            } else {
                run = 0
            }
        }
        XCTAssertEqual(maxVocal, 2)
    }

    func testReadOnlyDiagnosticsMatchAppliedSettingsAndOmitForbiddenClaims() {
        let settings = SweepRendererSettings.listeningTest
        let lines = settings.harnessDiagnosticLines(
            sweepRate: .ms300,
            sampleRate: 48_000,
            buildLines: CaptureProvenance.harnessBuildLines()
        )
        let blob = lines.joined(separator: "\n")
        XCTAssertTrue(blob.contains("listening-test"))
        XCTAssertTrue(blob.contains(SweepRendererSettings.listeningTestIdentity.version))
        XCTAssertEqual(SweepRendererSettings.listeningTestIdentity.version, "2026-09-10.gain-rebalance-v3")
        XCTAssertTrue(blob.contains("Configured vocal-event probability: 7.0%"))
        XCTAssertTrue(blob.contains("scheduler target, not measured density"))
        XCTAssertTrue(blob.contains("120.00–180.00 ms"))
        XCTAssertTrue(blob.contains(settings.noiseBedDescription))
        XCTAssertTrue(blob.contains("Sample limiter ceiling"))
        XCTAssertTrue(blob.contains("App version:"))
        XCTAssertFalse(blob.contains("~1 in 14"))
        XCTAssertFalse(blob.contains("P-SB7 calibrated"))
        XCTAssertFalse(blob.contains("LUFS"))
        let at75 = settings.harnessDiagnosticLines(sweepRate: .ms75, sampleRate: 48_000, buildLines: [])
            .joined(separator: "\n")
        XCTAssertTrue(at75.contains("63.75 ms"))
        XCTAssertFalse(at75.contains("120.00–180.00 ms"))
        XCTAssertTrue(at75.contains("Not a universal 100–180 ms range"))
    }

    func testArchivedBaselinePresetStaysFrozenAndIsNotTheLiveDefault() {
        XCTAssertNotEqual(SweepRendererSettings.archivedContinuousStatic, .listeningTest)
        XCTAssertEqual(SweepRendererSettings.archivedContinuousStatic.vocalEventProbability, 0.08, accuracy: 0.000_1)
        XCTAssertEqual(SweepRendererSettings.preset(identifier: "archived-continuous-static"), .archivedContinuousStatic)
        XCTAssertEqual(SweepRendererSettings.preset(identifier: "listening-test"), .listeningTest)
        XCTAssertNil(SweepRendererSettings.preset(identifier: "made-up"))
    }
}
