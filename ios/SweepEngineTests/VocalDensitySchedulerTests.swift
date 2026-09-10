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
        XCTAssertGreaterThan(maxVocal, 1, "Need occasional vocal clusters")
        XCTAssertLessThan(Double(flips) / Double(slots - 1), 0.70, "Must not be a metronomic alternate")
    }

    func testZeroProbabilityNeverSchedulesVocals() {
        let scheduler = VocalDensityScheduler(
            settings: SweepRendererSettings(vocalEventProbability: 0, clusteriness: 0.45),
            seed: 99
        )
        XCTAssertFalse((0..<400).contains { _ in scheduler.nextContainsVocal() })
    }

    func testFullProbabilityWithNoClusterAlwaysSchedulesVocals() {
        let scheduler = VocalDensityScheduler(
            settings: SweepRendererSettings(vocalEventProbability: 1, clusteriness: 0),
            seed: 99
        )
        XCTAssertEqual((0..<200).filter { _ in scheduler.nextContainsVocal() }.count, 200)
    }

    func testSameSeedReplaysAndDifferentSeedDiverges() {
        let a = VocalDensityScheduler(settings: .listeningTest, seed: 88)
        let b = VocalDensityScheduler(settings: .listeningTest, seed: 88)
        let c = VocalDensityScheduler(settings: .listeningTest, seed: 89)
        let first = (0..<300).map { _ in a.nextContainsVocal() }
        XCTAssertEqual(first, (0..<300).map { _ in b.nextContainsVocal() })
        XCTAssertNotEqual(first, (0..<300).map { _ in c.nextContainsVocal() })
    }

    func testListeningTestStaticIsQuietRelativeToPreviousBed() {
        XCTAssertLessThan(SweepRendererSettings.listeningTest.staticGain, 0.05)
        XCTAssertLessThan(SweepRendererSettings.listeningTest.staticGain, 0.09)
        XCTAssertGreaterThan(SweepRendererSettings.listeningTest.staticGain, 0.01)
        XCTAssertEqual(SweepRendererSettings.listeningTest.vocalEventProbability, 0.33, accuracy: 0.001)
        XCTAssertEqual(SweepRate.default, .ms300)
    }
}
