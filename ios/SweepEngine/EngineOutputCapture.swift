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

    func write(_ buffer: AVAudioPCMBuffer) throws -> Bool {
        guard let file else { return true }
        try file.write(from: buffer)
        writtenFrames += buffer.frameLength
        return writtenFrames >= targetFrames
    }

    @discardableResult
    func stop() -> URL? {
        let finished = url
        file = nil
        url = nil
        writtenFrames = 0
        targetFrames = 0
        return finished
    }
}
