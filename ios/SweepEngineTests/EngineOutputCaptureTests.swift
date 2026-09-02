import AVFoundation
import XCTest
@testable import SpiritBoxAudioHarness

final class EngineOutputCaptureTests: XCTestCase {
    private var scratchDirectory: URL!

    override func setUpWithError() throws {
        scratchDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpiritBoxCaptureTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratchDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let scratchDirectory {
            try? FileManager.default.removeItem(at: scratchDirectory)
        }
        scratchDirectory = nil
    }

    func testIndependentCopySurvivesMutationOfTheOriginalBuffer() throws {
        let original = try makeBuffer(frames: 8, fill: 0.42)
        let copy = try XCTUnwrap(PCMBufferIndependentCopy.make(from: original))

        let originalSamples = try XCTUnwrap(original.floatChannelData)[0]
        for index in 0..<8 {
            originalSamples[index] = 0
        }

        let copySamples = try XCTUnwrap(copy.floatChannelData)[0]
        for index in 0..<8 {
            XCTAssertEqual(copySamples[index], 0.42, accuracy: 0.000_1)
        }
        XCTAssertTrue(
            original.floatChannelData?[0] != copy.floatChannelData?[0],
            "Copy must not alias the original channel pointer"
        )
    }

    func testWriterCreatesReadableFileFromKnownPCM() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let captureURL = scratchDirectory.appendingPathComponent("writer-known-pcm.wav")
        let writer = EngineOutputCaptureWriter()
        let inputFrames: AVAudioFrameCount = 48_000

        try writer.start(url: captureURL, format: format, durationSeconds: 2)
        XCTAssertTrue(writer.isWriting)

        let buffer = try makeBuffer(frames: inputFrames, fill: 0.25)
        let reachedDuration = try writer.write(buffer)
        XCTAssertFalse(reachedDuration)
        XCTAssertEqual(writer.recordedFrameCount, inputFrames)

        let stopped = writer.stop()
        XCTAssertEqual(stopped.url, captureURL)
        XCTAssertEqual(stopped.seconds, 1)

        XCTAssertTrue(FileManager.default.fileExists(atPath: captureURL.path))
        let attributes = try FileManager.default.attributesOfItem(atPath: captureURL.path)
        let size = try XCTUnwrap(attributes[.size] as? NSNumber).intValue
        XCTAssertGreaterThan(size, 0)

        let file = try AVAudioFile(forReading: captureURL)
        XCTAssertGreaterThan(file.length, 0)
        XCTAssertLessThanOrEqual(abs(file.length - AVAudioFramePosition(inputFrames)), 2)
        XCTAssertEqual(file.fileFormat.sampleRate, 48_000, accuracy: 0.1)
        let duration = Double(file.length) / file.fileFormat.sampleRate
        XCTAssertEqual(duration, 1.0, accuracy: 0.002)
    }

    func testWriterFrameCountMatchesMultipleKnownBuffers() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let captureURL = scratchDirectory.appendingPathComponent("writer-multiple-buffers.wav")
        let writer = EngineOutputCaptureWriter()
        try writer.start(url: captureURL, format: format, durationSeconds: 3)

        let chunk: AVAudioFrameCount = 4_800
        for _ in 0..<10 {
            try writer.write(try makeBuffer(frames: chunk, fill: 0.1))
        }
        XCTAssertEqual(writer.recordedFrameCount, 48_000)
        _ = writer.stop()

        let file = try AVAudioFile(forReading: captureURL)
        XCTAssertLessThanOrEqual(abs(file.length - 48_000), 2)
    }

    func testRepeatedStopDoesNotCorruptTheFile() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let captureURL = scratchDirectory.appendingPathComponent("writer-double-stop.wav")
        let writer = EngineOutputCaptureWriter()
        try writer.start(url: captureURL, format: format, durationSeconds: 2)
        try writer.write(try makeBuffer(frames: 24_000, fill: 0.2))

        let first = writer.stop()
        let second = writer.stop()

        XCTAssertEqual(first.url, captureURL)
        XCTAssertNil(second.url)
        XCTAssertFalse(writer.isWriting)

        let file = try AVAudioFile(forReading: captureURL)
        XCTAssertLessThanOrEqual(abs(file.length - 24_000), 2)
    }

    func testWriteAfterStopIsANoOp() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let captureURL = scratchDirectory.appendingPathComponent("writer-write-after-stop.wav")
        let writer = EngineOutputCaptureWriter()
        try writer.start(url: captureURL, format: format, durationSeconds: 2)
        try writer.write(try makeBuffer(frames: 12_000, fill: 0.3))
        _ = writer.stop()

        XCTAssertTrue(try writer.write(try makeBuffer(frames: 12_000, fill: 0.9)))

        let file = try AVAudioFile(forReading: captureURL)
        XCTAssertLessThanOrEqual(abs(file.length - 12_000), 2)
    }

    func testStartFailsGracefullyWhenOutputDirectoryCannotBeCreated() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let blocker = scratchDirectory.appendingPathComponent("not-a-directory")
        try Data("x".utf8).write(to: blocker)
        let badURL = blocker.appendingPathComponent("out.wav")
        let writer = EngineOutputCaptureWriter()

        XCTAssertThrowsError(try writer.start(url: badURL, format: format, durationSeconds: 1))
        XCTAssertFalse(writer.isWriting)
        XCTAssertNil(writer.url)
    }

    func testStartingCaptureWhileSweepStoppedThrowsWithoutCrashing() {
        let engine = SweepAudioEngine()
        XCTAssertThrowsError(try engine.startEngineOutputCapture()) { error in
            guard let captureError = error as? SweepAudioEngine.CaptureError else {
                return XCTFail("Expected CaptureError, got \(error)")
            }
            XCTAssertEqual(captureError, .sweepNotRunning)
        }
        engine.stopEngineOutputCapture()
        engine.stopEngineOutputCapture()
    }

    func testStartingAudioGateRunWhileSweepStoppedThrowsWithoutCrashing() {
        let engine = SweepAudioEngine()
        XCTAssertThrowsError(try engine.startAudioGateRun(durationSeconds: 120)) { error in
            guard let captureError = error as? SweepAudioEngine.CaptureError else {
                return XCTFail("Expected CaptureError, got \(error)")
            }
            XCTAssertEqual(captureError, .sweepNotRunning)
        }
        engine.stopAudioGateRun()
    }

    private func makeBuffer(frames: AVAudioFrameCount, fill: Float) throws -> AVAudioPCMBuffer {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        let samples = try XCTUnwrap(buffer.floatChannelData)[0]
        for index in 0..<Int(frames) {
            samples[index] = fill
        }
        return buffer
    }
}
