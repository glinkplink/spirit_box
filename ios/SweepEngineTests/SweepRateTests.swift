import XCTest
@testable import SpiritBoxAudioHarness

final class SweepRateTests: XCTestCase {
    func testExactLockedRates() {
        XCTAssertEqual(SweepRate.allCases.map(\.milliseconds), [75, 125, 200, 300])
    }

    func testDefaultIs300Milliseconds() {
        XCTAssertEqual(SweepRate.default, .ms300)
        XCTAssertEqual(SweepRate.default.milliseconds, 300)
    }

    func testEngineStoresEachLockedRate() {
        let engine = SweepAudioEngine()
        XCTAssertEqual(engine.currentRate, .ms300)
        for rate in SweepRate.allCases {
            engine.setSweepRate(rate)
            XCTAssertEqual(engine.currentRate, rate)
        }
    }

    func testIntervalsMatchMilliseconds() {
        XCTAssertEqual(SweepRate.ms75.timeInterval, 0.075, accuracy: 0.000_001)
        XCTAssertEqual(SweepRate.ms125.timeInterval, 0.125, accuracy: 0.000_001)
        XCTAssertEqual(SweepRate.ms200.timeInterval, 0.200, accuracy: 0.000_001)
        XCTAssertEqual(SweepRate.ms300.timeInterval, 0.300, accuracy: 0.000_001)
    }
}
