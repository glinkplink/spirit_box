import AVFoundation
import Foundation

public enum EngineOutputCaptureState: Equatable, Sendable {
    case idle
    case capturing(elapsedSeconds: Int, durationSeconds: Int, url: URL)
    case finished(url: URL, seconds: Int)
    case failed(String)
}

/// Diagnostic capture of the engine's final mixed output.
///
/// This is NOT customer session recording and does NOT use the microphone.
public enum EngineOutputCaptureLocator {
    public static let directoryName = "EngineOutputCaptures"
    public static let defaultDurationSeconds = 120
    public static let manualEvaluationDurationSeconds = 1200

    public static func directory(in documents: URL) -> URL {
        documents.appendingPathComponent(directoryName, isDirectory: true)
    }

    public static func makeFileURL(in documents: URL, now: Date = Date()) -> URL {
        let stamp = timestampFormatter.string(from: now)
        return directory(in: documents)
            .appendingPathComponent("engine-output-capture-\(stamp).wav")
    }

    public static func makeEventLogURL(forCaptureURL url: URL) -> URL {
        url.deletingPathExtension().appendingPathExtension("events.jsonl")
    }

    public static func documentsDirectory(fileManager: FileManager = .default) -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

final class EngineOutputCaptureWriter {
    private var file: AVAudioFile?
    private(set) var url: URL?
    private var writtenFrames: AVAudioFrameCount = 0
    private var targetFrames: AVAudioFrameCount = 0
    private(set) var durationSeconds: Int = 0

    var isWriting: Bool { file != nil }

    var elapsedSeconds: Int {
        guard targetFrames > 0, let file else { return 0 }
        let rate = file.fileFormat.sampleRate
        guard rate > 0 else { return 0 }
        return Int(Double(writtenFrames) / rate)
    }

    func start(url: URL, format: AVAudioFormat, durationSeconds: Int) throws {
        stop()
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false,
        ]

        file = try AVAudioFile(forWriting: url, settings: settings)
        self.url = url
        writtenFrames = 0
        self.durationSeconds = durationSeconds
        targetFrames = AVAudioFrameCount(max(1, durationSeconds) * Int(format.sampleRate.rounded()))
    }

    /// Returns true when the configured duration has been reached. No-ops after stop.
    @discardableResult
    func write(_ buffer: AVAudioPCMBuffer) throws -> Bool {
        guard let file else { return true }
        try file.write(from: buffer)
        writtenFrames += buffer.frameLength
        return writtenFrames >= targetFrames
    }

    var recordedFrameCount: AVAudioFrameCount { writtenFrames }

    @discardableResult
    func stop() -> (url: URL?, seconds: Int) {
        let finished = url
        let seconds = elapsedSeconds
        file = nil
        url = nil
        writtenFrames = 0
        targetFrames = 0
        durationSeconds = 0
        return (finished, seconds)
    }
}

/// Deep-copies PCM samples so they remain valid after an AVAudioEngine tap callback returns.
enum PCMBufferIndependentCopy {
    static func make(from buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        let frames = buffer.frameLength
        guard frames > 0 else { return nil }
        guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: frames) else {
            return nil
        }
        copy.frameLength = frames

        let sourceList = UnsafeMutableAudioBufferListPointer(
            UnsafeMutablePointer(mutating: buffer.audioBufferList)
        )
        let destinationList = UnsafeMutableAudioBufferListPointer(copy.mutableAudioBufferList)
        guard sourceList.count == destinationList.count else { return nil }

        for index in 0..<sourceList.count {
            let source = sourceList[index]
            var destination = destinationList[index]
            guard let sourceData = source.mData, let destinationData = destination.mData else {
                return nil
            }
            let byteCount = Int(source.mDataByteSize)
            destinationData.copyMemory(from: sourceData, byteCount: byteCount)
            destination.mDataByteSize = source.mDataByteSize
            destinationList[index] = destination
        }
        return copy
    }
}
