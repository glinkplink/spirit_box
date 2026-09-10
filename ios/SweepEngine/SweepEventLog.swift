import Foundation

/// One scheduled fragment. Diagnostic only — no transcription or interpretation.
public struct SweepEvent: Identifiable, Equatable, Sendable {
    public var utteranceID: String? = nil
    public var sourceFile: String? = nil
    public var sourceStartFrame: Int? = nil
    public var sourceFrameCount: Int? = nil
    public var eventsSinceSpeakerUse: Int? = nil
    public var renderTimeSeconds: Double? = nil
    public var cropOffsetFrames: Int? = nil
    public var emittedFrameCount: Int? = nil
    public var id: UUID
    public var timestamp: Date
    public var assetID: String
    public var performerID: String?
    public var voiceFamily: String?
    public var phoneticFamily: String?
    public var sourceType: String?
    public var sweepRate: SweepRate
    public var direction: SweepDirection
    public var eventsSincePreviousUse: Int?
    public var relaxedConstraints: [RelaxedConstraint]
    public var decisionSummary: String
    public var containsVocal: Bool = true
    public var sourceOffsetMs: Int? = nil
    public var exposedDurationMs: Int? = nil
    /// Seconds from capture WAV start. Nil when no capture is active.
    /// Live captures can start after the engine timeline; acoustics must use this
    /// rather than `renderTimeSeconds` when it is present.
    public var captureTimeSeconds: Double? = nil

    public init(
        id: UUID = UUID(),
        timestamp: Date,
        assetID: String,
        performerID: String?,
        voiceFamily: String?,
        phoneticFamily: String?,
        sourceType: String?,
        sweepRate: SweepRate,
        direction: SweepDirection,
        eventsSincePreviousUse: Int?,
        relaxedConstraints: [RelaxedConstraint],
        decisionSummary: String,
        containsVocal: Bool = true,
        sourceOffsetMs: Int? = nil,
        exposedDurationMs: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.assetID = assetID
        self.performerID = performerID
        self.voiceFamily = voiceFamily
        self.phoneticFamily = phoneticFamily
        self.sourceType = sourceType
        self.sweepRate = sweepRate
        self.direction = direction
        self.eventsSincePreviousUse = eventsSincePreviousUse
        self.relaxedConstraints = relaxedConstraints
        self.decisionSummary = decisionSummary
        self.containsVocal = containsVocal
        self.sourceOffsetMs = sourceOffsetMs
        self.exposedDurationMs = exposedDurationMs
    }

    public static func noiseOnlySlot(
        rate: SweepRate,
        direction: SweepDirection,
        timestamp: Date,
        decisionSummary: String = "noise-only"
    ) -> SweepEvent {
        SweepEvent(
            timestamp: timestamp,
            assetID: "",
            performerID: nil,
            voiceFamily: nil,
            phoneticFamily: nil,
            sourceType: nil,
            sweepRate: rate,
            direction: direction,
            eventsSincePreviousUse: nil,
            relaxedConstraints: [],
            decisionSummary: decisionSummary,
            containsVocal: false
        )
    }

    public init(pick: SchedulePick, rate: SweepRate, direction: SweepDirection, timestamp: Date = Date()) {
        self.init(
            timestamp: timestamp,
            assetID: pick.asset.assetID,
            performerID: pick.asset.performerID,
            voiceFamily: pick.asset.voiceFamily,
            phoneticFamily: pick.asset.phoneticFamily,
            sourceType: pick.asset.sourceType,
            sweepRate: rate,
            direction: direction,
            eventsSincePreviousUse: pick.eventsSincePreviousUse,
            relaxedConstraints: pick.relaxedConstraints,
            decisionSummary: pick.decisionSummary
        )
        utteranceID = pick.asset.utteranceID
        sourceFile = pick.asset.sourceFile
        sourceStartFrame = pick.asset.sourceStartFrame
        sourceFrameCount = pick.asset.sourceFrameCount
        eventsSinceSpeakerUse = pick.eventsSinceSpeakerUse
        containsVocal = true
    }

    public var debugLine: String {
        let kind = containsVocal ? "vocal" : "noise"
        let since = eventsSincePreviousUse.map(String.init) ?? (containsVocal ? "first" : "—")
        let family = voiceFamily ?? performerID ?? "—"
        let phonetic = phoneticFamily ?? sourceType ?? "—"
        let asset = containsVocal ? assetID : "—"
        let offset = sourceOffsetMs.map { "off=\($0)ms" } ?? "off=—"
        let exposed = exposedDurationMs.map { "exp=\($0)ms" } ?? "exp=—"
        return "\(timestamp.formatted(date: .omitted, time: .standard))  \(kind)  \(asset)  \(family)  \(phonetic)  \(sweepRate.milliseconds)ms  \(direction.debugLabel)  \(offset)  \(exposed)  since=\(since)  \(decisionSummary)"
    }

    public func diagnosticJSONLine() -> String {
        var payload: [String: Any] = [
            // Stable audio timeline in exported traces; the in-memory wall time
            // remains available for the harness display.
            "timestamp": renderTimeSeconds ?? timestamp.timeIntervalSince1970,
            "asset_id": assetID,
            "sweep_rate_ms": sweepRate.milliseconds,
            "direction": direction.debugLabel,
            "relaxed_constraints": relaxedConstraints.map(\.rawValue),
            "decision_summary": decisionSummary,
            "contains_vocal": containsVocal,
        ]
        if let utteranceID { payload["utterance_id"] = utteranceID }
        if let sourceFile { payload["source_file"] = sourceFile }
        if let sourceStartFrame { payload["source_start_frame"] = sourceStartFrame }
        if let sourceFrameCount { payload["source_frame_count"] = sourceFrameCount }
        if let eventsSinceSpeakerUse { payload["events_since_speaker_use"] = eventsSinceSpeakerUse }
        if let renderTimeSeconds { payload["render_time_seconds"] = renderTimeSeconds }
        if let cropOffsetFrames { payload["crop_offset_frames"] = cropOffsetFrames }
        if let emittedFrameCount { payload["emitted_frame_count"] = emittedFrameCount }
        if let performerID { payload["performer_id"] = performerID }
        if let voiceFamily { payload["voice_family"] = voiceFamily }
        if let phoneticFamily { payload["phonetic_family"] = phoneticFamily }
        if let sourceType { payload["source_type"] = sourceType }
        if let eventsSincePreviousUse { payload["events_since_previous_use"] = eventsSincePreviousUse }
        if let sourceOffsetMs { payload["source_offset_ms"] = sourceOffsetMs }
        if let exposedDurationMs { payload["exposed_duration_ms"] = exposedDurationMs }
        if let captureTimeSeconds { payload["capture_time_seconds"] = captureTimeSeconds }
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]),
              let line = String(data: data, encoding: .utf8)
        else {
            return "{\"asset_id\":\"\(assetID)\"}"
        }
        return line
    }
}

public final class SweepEventLog: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [SweepEvent] = []
    public let capacity: Int

    public init(capacity: Int = 20_000) {
        self.capacity = max(1, capacity)
    }

    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return storage.count
    }

    public func append(_ event: SweepEvent) {
        lock.lock()
        storage.append(event)
        if storage.count > capacity {
            storage.removeFirst(storage.count - capacity)
        }
        lock.unlock()
    }

    public func recent(limit: Int = 80) -> [SweepEvent] {
        lock.lock()
        defer { lock.unlock() }
        return Array(storage.suffix(limit).reversed())
    }

    public func allChronological() -> [SweepEvent] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    public func reset() {
        lock.lock()
        storage.removeAll(keepingCapacity: true)
        lock.unlock()
    }
}
