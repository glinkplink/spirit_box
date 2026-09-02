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
}
