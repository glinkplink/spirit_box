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
        XCTAssertEqual(Int(cropped.frameLength), 2_400)
        XCTAssertLessThan(Int(cropped.frameLength), 3_600)
    }

    func testCropIsAGlimpseNotADwellSizedRecording() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let frames: AVAudioFrameCount = 48_000
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        let asset = SourceAsset(assetID: "RATES", durationMs: 1000, relativePath: "rates.wav")

        let shortest: [SweepRate: Int] = [.ms75: 2_400, .ms125: 2_400, .ms200: 2_400, .ms300: 3_168]
        let longest: [SweepRate: Int] = [.ms75: 2_400, .ms125: 2_880, .ms200: 4_080, .ms300: 3_600]
        for rate in SweepRate.allCases {
            let dwell = rate.milliseconds * 48
            let minCrop = FragmentBufferFactory.crop(buffer, asset: asset, sweepRate: rate, startJitterFraction: 0, durationJitterFraction: 0)
            let maxCrop = FragmentBufferFactory.crop(buffer, asset: asset, sweepRate: rate, startJitterFraction: 1, durationJitterFraction: 1)
            XCTAssertEqual(Int(minCrop.frameLength), shortest[rate], "Min exposure for \(rate.milliseconds) ms")
            XCTAssertEqual(Int(maxCrop.frameLength), longest[rate], "Max exposure for \(rate.milliseconds) ms")
            XCTAssertLessThanOrEqual(Int(maxCrop.frameLength), dwell)
            XCTAssertEqual(minCrop.format.sampleRate, 48_000, "Must crop, not resample/speed-change")
        }
        let max200 = FragmentBufferFactory.crop(buffer, asset: asset, sweepRate: .ms200, startJitterFraction: 1, durationJitterFraction: 1)
        let max300 = FragmentBufferFactory.crop(buffer, asset: asset, sweepRate: .ms300, startJitterFraction: 1, durationJitterFraction: 1)
        XCTAssertLessThan(Int(max300.frameLength), Int(max200.frameLength))
        XCTAssertLessThan(Int(max200.frameLength), 9_600)
        XCTAssertLessThan(Int(max300.frameLength), 14_400)
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
        XCTAssertEqual(Int(cropped.frameLength), 3_168)
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
        XCTAssertLessThan(SweepMasterLimiter.sampleCeiling, 1)
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
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 48000))
        buffer.frameLength = 48000
        let samples = try XCTUnwrap(buffer.floatChannelData)[0]
        for i in 0..<48000 { samples[i] = Float(sin(Double(i) * 0.13) * 0.1) }
        let url = root.appendingPathComponent("fixture.wav")
        do {
            let file = try AVAudioFile(forWriting: url, settings: format.settings)
            try file.write(from: buffer)
        }
        let engine = SweepAudioEngine()
        engine.load(LoadedCorpus(assets: (0..<3).map { SourceAsset(assetID: "test-\($0)", durationMs: 1000, relativePath: "fixture.wav") },
            skippedMalformedCount: 0, source: .bundleDevFixtures, label: "test", isDevFixture: true, rootURL: root))
        engine.setSweepRate(.ms75)
        let changed = expectation(description: "New control values reach a vocal slot without restart")
        var firstTime: Double?
        engine.onEvent = { event in
            if firstTime == nil {
                firstTime = event.renderTimeSeconds
                // Every source must already be decoded, including first-use
                // assets selected after START. Playback no longer needs this file.
                try? FileManager.default.removeItem(at: url)
                for rate in SweepRate.allCases {
                    engine.setSweepRate(rate)
                    XCTAssertEqual(engine.currentRate, rate)
                    XCTAssertTrue(engine.isRunning)
                }
                engine.setDirection(.reverse)
            } else if event.sweepRate == .ms300 && event.direction == .reverse {
                XCTAssertLessThanOrEqual((event.renderTimeSeconds ?? 10) - (firstTime ?? 0), 0.34)
                XCTAssertTrue(engine.isRunning)
                engine.onEvent = nil
                changed.fulfill()
            }
        }
        defer { engine.onEvent = nil; engine.stop() }
        try engine.start()
        wait(for: [changed], timeout: 3)
        engine.stop()
        XCTAssertFalse(engine.isRunning)
    }

    func testCustomSettingsCannotExposeWholeDwell() {
        let settings = SweepRendererSettings(minVocalExposureSeconds: 1,
                                            maxVocalExposureSeconds: 2,
                                            minExposureFractionOfDwell: 1,
                                            maxExposureFractionOfDwell: 1)
        for rate in SweepRate.allCases {
            let frames = FragmentBufferFactory.exposureFrameCount(sampleRate: 48000,
                sweepRate: rate, availableFrames: 48000, durationJitterFraction: 1, settings: settings)
            XCTAssertLessThanOrEqual(frames, rate == .ms300 ? 3600 : 4320)
        }
    }

    func testNoiseOnlySlotsAreClockedAndSeededAcrossRateChanges() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1))
        let a = ProceduralNoiseState(), b = ProceduralNoiseState()
        a.reset(seed: 12648430)
        b.reset(seed: 12648430)
        for rate in [SweepRate.ms300, .ms200, .ms75, .ms125, .ms300] {
            let count = rate.milliseconds * 48
            func render(_ state: ProceduralNoiseState) throws -> [Float] {
                let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(count)))
                buffer.frameLength = AVAudioFrameCount(count)
                let data = try XCTUnwrap(buffer.floatChannelData)[0]
                data.initialize(repeating: 0, count: count)
                SweepSlotMixer.mix(buffer, noise: state, settings: .listeningTest)
                return Array(UnsafeBufferPointer(start: data, count: count))
            }
            let first = try render(a)
            XCTAssertEqual(first, try render(b), "Every slot uses the same seed and PCM path")
            func rms(_ range: Range<Int>) -> Double {
                sqrt(range.reduce(0.0) { $0 + Double(first[$1] * first[$1]) } / Double(range.count))
            }
            let quiet = rms(48..<Int(Double(count) * 0.15))
            let open = rms((count / 2)..<(count * 3 / 4))
            XCTAssertGreaterThan(20 * log10(open / quiet), 15)
            XCTAssertTrue(first.allSatisfy { $0.isFinite && abs($0) <= SweepMasterLimiter.sampleCeiling })
        }
    }

    func testMasterLimiterBoundsIntersampleReconstructionAndInvalidInput() {
        var samples = (0..<4800).map { Float(sin(Double($0) * 2.2) * 12) }
        samples[2] = .nan
        samples[3] = .infinity
        samples.withUnsafeMutableBufferPointer { data in
            SweepMasterLimiter.process(data.baseAddress!, count: data.count, sampleRate: 48000)
        }
        XCTAssertTrue(samples.allSatisfy { $0.isFinite && abs($0) <= SweepMasterLimiter.sampleCeiling })
        func sinc(_ x: Double) -> Double {
            abs(x) < 1e-12 ? 1 : sin(Double.pi * x) / (Double.pi * x)
        }
        for i in 16..<(samples.count - 17) {
            for phase in 1...3 {
                let t = Double(phase) / 4
                var reconstructed = 0.0, weight = 0.0
                for k in -15...16 {
                    let x = t - Double(k)
                    let tap = sinc(x) * sinc(x / 16)
                    reconstructed += Double(samples[i + k]) * tap
                    weight += tap
                }
                XCTAssertLessThanOrEqual(abs(reconstructed / weight), Double(SweepMasterLimiter.truePeakCeiling))
            }
        }
    }

    func testRadioShapingHasEqualEnergyInBothDirections() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1))
        let source = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 9600))
        source.frameLength = 9600
        let data = try XCTUnwrap(source.floatChannelData)[0]
        for i in 0..<9600 {
            data[i] = Float(exp(-Double(i) / 500) * sin(Double(i) * 0.08))
        }
        let asset = SourceAsset(assetID: "asymmetric", durationMs: 200)
        for rate in SweepRate.allCases {
            let f = FragmentBufferFactory.makeBuffer(convertedSource: source, asset: asset,
                sweepRate: rate, direction: .forward, startJitterFraction: 0)
            let r = FragmentBufferFactory.makeBuffer(convertedSource: source, asset: asset,
                sweepRate: rate, direction: .reverse, startJitterFraction: 0)
            func energy(_ buffer: AVAudioPCMBuffer) -> Double {
                let samples = buffer.floatChannelData![0]
                return (0..<Int(buffer.frameLength)).reduce(0) { $0 + Double(samples[$1]) * Double(samples[$1]) }
            }
            XCTAssertEqual(energy(f), energy(r), accuracy: 1e-8)
        }
    }

    func testVocalBalanceTargetsGlimpseRMSWithBoundedLiftAndPeak() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1))
        let count = 4800
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(count)))
        buffer.frameLength = AVAudioFrameCount(count)
        let data = try XCTUnwrap(buffer.floatChannelData)[0]
        for amplitude in [Float(0), 0.0001, 0.06, 2] {
            for i in 0..<count { data[i] = amplitude * Float(sin(Double(i) * 2 * Double.pi / 48)) }
            FragmentBufferFactory.balanceVocalLevel(buffer)
            let rms = sqrt((0..<count).reduce(0.0) { $0 + Double(data[$1]) * Double(data[$1]) } / Double(count))
            if amplitude == 0 { XCTAssertEqual(rms, 0) }
            else if amplitude < 0.001 {
                XCTAssertLessThanOrEqual(rms, Double(amplitude) * 4, "Do not amplify near silence without bound")
            } else {
                XCTAssertEqual(rms, 0.105, accuracy: 0.00001)
            }
            XCTAssertTrue((0..<count).allSatisfy { abs(data[$0]) <= SweepTuning.vocalPeakLimit })
        }
        data.initialize(repeating: 0, count: count)
        data[2400] = 0.5
        FragmentBufferFactory.balanceVocalLevel(buffer)
        XCTAssertLessThanOrEqual(abs(data[2400]), SweepTuning.vocalPeakLimit)
    }

}
