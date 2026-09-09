import AVFoundation
import XCTest
@testable import SpiritBoxAudioHarness

final class FragmentBufferFactoryTests: XCTestCase {
    func testReverseFlipsSampleOrder() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4))
        buffer.frameLength = 4
        let samples = try XCTUnwrap(buffer.floatChannelData)[0]
        samples[0] = 0.10
        samples[1] = 0.20
        samples[2] = 0.30
        samples[3] = 0.40

        let reversed = FragmentBufferFactory.reverse(buffer)
        let out = try XCTUnwrap(reversed.floatChannelData)[0]
        XCTAssertEqual(out[0], 0.40, accuracy: 0.0001)
        XCTAssertEqual(out[1], 0.30, accuracy: 0.0001)
        XCTAssertEqual(out[2], 0.20, accuracy: 0.0001)
        XCTAssertEqual(out[3], 0.10, accuracy: 0.0001)
    }

    func testCropLengthFollowsSweepRate() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let frames: AVAudioFrameCount = 48_000
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        if let samples = buffer.floatChannelData?[0] {
            for index in 0..<Int(frames) {
                samples[index] = 0.25
            }
        }

        let asset = SourceAsset(assetID: "CROP", durationMs: 1000, relativePath: "crop.wav")
        let cropped = FragmentBufferFactory.crop(
            buffer,
            asset: asset,
            sweepRate: .ms75,
            startJitterFraction: 0
        )
        XCTAssertEqual(Int(cropped.frameLength), 3_600)
    }

    func testCropLengthFollowsEachLockedSweepRate() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let frames: AVAudioFrameCount = 48_000
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        let asset = SourceAsset(assetID: "RATES", durationMs: 1000, relativePath: "rates.wav")

        let expected = [SweepRate.ms75: 3_600, .ms125: 6_000, .ms200: 9_600, .ms300: 14_400]
        for (rate, framesExpected) in expected {
            let cropped = FragmentBufferFactory.crop(buffer, asset: asset, sweepRate: rate, startJitterFraction: 0)
            XCTAssertEqual(Int(cropped.frameLength), framesExpected, "Crop must follow \(rate.milliseconds) ms cadence")
        }
    }

    func testCropDoesNotExceedCropSafeWindow() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let frames: AVAudioFrameCount = 48_000
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        let asset = SourceAsset(
            assetID: "SAFE",
            durationMs: 1000,
            cropSafeStartMs: 100,
            cropSafeEndMs: 250,
            relativePath: "safe.wav"
        )

        let cropped = FragmentBufferFactory.crop(buffer, asset: asset, sweepRate: .ms300, startJitterFraction: 0)
        XCTAssertEqual(Int(cropped.frameLength), 7_200)
    }
    func testFinalVocalSlotsAreDwellSizedFiniteFadedAndBounded() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let source = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 9600))
        source.frameLength = 9600
        let input = try XCTUnwrap(source.floatChannelData)[0]
        for i in 0..<9600 { input[i] = Float(sin(Double(i) * 0.12) * 4) }
        let asset = SourceAsset(assetID: "test", durationMs: 200)
        for rate in SweepRate.allCases {
            for direction in SweepDirection.allCases {
                let buffer = FragmentBufferFactory.makeBuffer(convertedSource: source, asset: asset,
                    sweepRate: rate, direction: direction, startJitterFraction: 0.5)
                XCTAssertEqual(Int(buffer.frameLength), rate.milliseconds * 48)
                let data = try XCTUnwrap(buffer.floatChannelData)[0]
                XCTAssertEqual(data[0], 0, accuracy: 0.00001)
                XCTAssertEqual(data[Int(buffer.frameLength) - 1], 0, accuracy: 0.00001)
                for i in 0..<Int(buffer.frameLength) {
                    XCTAssertTrue(data[i].isFinite)
                    XCTAssertLessThanOrEqual(abs(data[i]), SweepTuning.vocalPeakLimit + 0.00001)
                }
            }
        }
        XCTAssertLessThan((SweepTuning.vocalPeakLimit * SweepTuning.vocalGain + SweepTuning.staticGain) * SweepTuning.outputGain, 1)
    }

    func testRadioShapeAttenuatesDCAndUltrasonicContent() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        func energy(hz: Double) throws -> Double {
            let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 48000))
            buffer.frameLength = 48000
            let samples = try XCTUnwrap(buffer.floatChannelData)[0]
            for i in 0..<48000 { samples[i] = Float(0.1 * cos(2 * Double.pi * hz * Double(i) / 48000)) }
            FragmentBufferFactory.applyRadioShape(buffer, variation: 0.5)
            return (24000..<48000).reduce(0) { $0 + Double(samples[$1] * samples[$1]) } / 24000
        }
        let mid = try energy(hz: 1000)
        XCTAssertLessThan(try energy(hz: 0), mid * 0.01)
        XCTAssertLessThan(try energy(hz: 18000), mid * 0.2)
    }

    func testLiveRateAndDirectionChangesKeepTheSameEngineRunning() throws {
        let engine = SweepAudioEngine()
        // Noise-only graph exercises the actual start/control/stop lifecycle.
        try engine.start()
        defer { engine.stop() }
        for rate in SweepRate.allCases {
            engine.setSweepRate(rate)
            XCTAssertEqual(engine.currentRate, rate)
            XCTAssertTrue(engine.isRunning)
        }
        engine.setDirection(.reverse)
        XCTAssertEqual(engine.currentDirection, .reverse)
        XCTAssertTrue(engine.isRunning)
        engine.stop()
        XCTAssertFalse(engine.isRunning)
    }

}
