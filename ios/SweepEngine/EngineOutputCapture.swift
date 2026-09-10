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
/// Callers may pass a destination WAV URL into `EngineOutputCaptureWriter.start`
/// (for example an audio-gate run folder) instead of using `makeFileURL`.
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

    public static func documentsDirectory(fileManager: FileManager = .default) throws -> URL {
        try HarnessDocuments.resolve(fileManager: fileManager)
    }

    @discardableResult
    public static func ensureCaptureDirectory(
        in documents: URL,
        fileManager: FileManager = .default
    ) throws -> URL {
        let directory = self.directory(in: documents)
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue {
            return directory
        }
        if exists && !isDirectory.boolValue {
            throw HarnessDocuments.Error.captureDirectoryCreationFailed(
                "a file already exists at Documents/\(directoryName)"
            )
        }
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            return directory
        } catch {
            throw HarnessDocuments.Error.captureDirectoryCreationFailed(error.localizedDescription)
        }
    }

    public static func makeDiagnosticsURL(forCaptureURL url: URL) -> URL {
        url.deletingPathExtension().appendingPathExtension("engine-diagnostics.json")
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

/// Artifact metadata for live captures and offline renders. Built off the
/// real-time audio callback. Missing historical fields are explicit UNKNOWN.
enum CaptureProvenance {
    static let unknown = "UNKNOWN"

    /// First non-empty real value wins. Unexpanded `$(SETTING)` and explicit UNKNOWN are skipped.
    static func resolvedField(_ candidates: String?...) -> String {
        for value in candidates {
            guard let cleaned = nonEmpty(value), cleaned != unknown else { continue }
            if cleaned.hasPrefix("$(") && cleaned.hasSuffix(")") { continue }
            return cleaned
        }
        return unknown
    }

    static func sourceRevision(
        env: [String: String] = ProcessInfo.processInfo.environment,
        bundle: Bundle = .main
    ) -> (commit: String, dirty: String) {
        let commit = resolvedField(
            env["SPIRIT_BOX_SOURCE_COMMIT"],
            bundle.object(forInfoDictionaryKey: "SpiritBoxSourceCommit") as? String
        )
        let dirty = resolvedField(
            env["SPIRIT_BOX_SOURCE_DIRTY"],
            bundle.object(forInfoDictionaryKey: "SpiritBoxSourceDirty") as? String
        )
        return (commit, dirty)
    }

    static func appVersion() -> (version: String, build: String) {
        let bundle = Bundle.main
        let version = nonEmpty(bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? unknown
        let build = nonEmpty(bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? unknown
        return (version, build)
    }

    static func harnessBuildLines() -> [String] {
        let app = appVersion()
        let source = sourceRevision()
        return [
            "App version: \(app.version)  build: \(app.build)",
            "Source revision: \(source.commit)  dirty: \(source.dirty)",
        ]
    }

    static func makePayload(
        runID: String,
        timestamp: Date,
        settings: SweepRendererSettings,
        seed: UInt64?,
        corpus: LoadedCorpus,
        sampleRate: Double?,
        durationSeconds: Int?,
        sweepRate: SweepRate,
        direction: SweepDirection,
        controlChanges: [[String: Any]] = [],
        captureAnchorRenderSeconds: Double? = nil,
        captureAnchorSource: String = unknown,
        eventTimestampBasis: String,
        extraEngine: [String: Any] = [:]
    ) -> [String: Any] {
        let app = appVersion()
        let source = sourceRevision()
        let manifest: String
        if let root = corpus.rootURL, let hash = CorpusLoader.manifestIdentity(at: root) {
            manifest = hash
        } else {
            manifest = unknown
        }
        var payload: [String: Any] = [
            "run_id": runID,
            "timestamp": AudioGateRunISO.string(from: timestamp),
            "app_version": app.version,
            "build_number": app.build,
            "source_commit": source.commit,
            "source_dirty": source.dirty,
            "seed": seed.map { NSNumber(value: $0) as Any } ?? unknown,
            "corpus_source": describeCorpusSource(corpus.source),
            "corpus_label": corpus.label,
            "corpus_asset_count": corpus.assetCount,
            "corpus_manifest_sha256": manifest,
            "is_dev_fixtures": corpus.isDevFixture,
            "sweep_rate_ms": sweepRate.milliseconds,
            "direction": direction.debugLabel,
            "event_timestamp_basis": eventTimestampBasis,
            "capture_anchor_source": captureAnchorSource,
            "control_changes": controlChanges,
            "renderer_settings": settings.jsonObject(),
        ]
        payload["sample_rate"] = sampleRate.map { $0 as Any } ?? unknown
        payload["duration_seconds"] = durationSeconds.map { $0 as Any } ?? unknown
        payload["capture_anchor_render_seconds"] = captureAnchorRenderSeconds.map { $0 as Any } ?? unknown
        payload["scheduler_starting_state"] = [
            "seed": seed.map { NSNumber(value: $0) as Any } ?? unknown,
            "recent_exclusion_window": settings.recentExclusionWindow,
            "history_reset_on_engine_start": true,
            "density_reseeded_from_seed": true,
        ] as [String: Any]
        for (key, value) in extraEngine {
            payload[key] = value
        }
        return payload
    }

    static func controlChanges(from events: [SweepEvent]) -> [[String: Any]] {
        var changes: [[String: Any]] = []
        var lastRate: Int?
        var lastDirection: String?
        for event in events {
            let rate = event.sweepRate.milliseconds
            let direction = event.direction.debugLabel
            if lastRate == nil {
                lastRate = rate
                lastDirection = direction
                continue
            }
            if rate != lastRate || direction != lastDirection {
                var row: [String: Any] = [
                    "sweep_rate_ms": rate,
                    "direction": direction,
                ]
                row["render_time_seconds"] = event.renderTimeSeconds.map { $0 as Any } ?? NSNull()
                row["capture_time_seconds"] = event.captureTimeSeconds.map { $0 as Any } ?? NSNull()
                changes.append(row)
                lastRate = rate
                lastDirection = direction
            }
        }
        return changes
    }

    static func write(_ payload: [String: Any], to url: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys, .prettyPrinted])
        try data.write(to: url, options: .atomic)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func describeCorpusSource(_ source: CorpusSource) -> String {
        switch source {
        case .documentsPhase1: return "Documents/SpiritBoxPhase1Corpus"
        case .bundlePhase1: return "Bundle/Phase1"
        case .bundleDevFixtures: return "Bundle/DevFixtures"
        case .empty: return "none"
        }
    }
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
