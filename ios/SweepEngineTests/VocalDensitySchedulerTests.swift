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
        let slots = 2_000
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
        XCTAssertGreaterThan(density, 0.25)
        XCTAssertLessThan(density, 0.40)
        XCTAssertGreaterThan(maxNoise, 2, "Need consecutive noise-only slots")
        XCTAssertEqual(maxVocal, 2, "Occasional pairs, never longer bursts")
        XCTAssertLessThan(Double(flips) / Double(slots - 1), 0.70, "Must not be a metronomic alternate")
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
        XCTAssertEqual(SweepRendererSettings.listeningTest.staticGain, 0.10, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTest.vocalGain, 0.48, accuracy: 0.001)
        XCTAssertEqual(SweepRendererSettings.listeningTest.clusteriness, 0.18, accuracy: 0.001)
        XCTAssertEqual(SweepRate.default, .ms300)
    }
}
