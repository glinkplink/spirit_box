import Foundation

/// Completion of one private audio-gate evaluation run.
/// Diagnostic artifact status only — not an audio-gate verdict.
public enum AudioGateRunCompletion: String, Equatable, Sendable {
    case completed
    case stoppedEarly = "stopped_early"
    case failed
}

public enum AudioGateRunFinishReason: Equatable, Sendable {
    case durationReached
    case userStopped
    case failed(String)
}

/// Unique Documents folder for one evaluation-run bundle.
public struct AudioGateRunLocation: Equatable, Sendable {
    public let runID: String
    public let directoryURL: URL

    public var wavURL: URL {
        directoryURL.appendingPathComponent(AudioGateRunLocator.wavFileName)
    }

    public var eventsURL: URL {
        directoryURL.appendingPathComponent(AudioGateRunLocator.eventsFileName)
    }

    public var summaryJSONURL: URL {
        directoryURL.appendingPathComponent(AudioGateRunLocator.summaryJSONFileName)
    }

    public var summaryMarkdownURL: URL {
        directoryURL.appendingPathComponent(AudioGateRunLocator.summaryMarkdownFileName)
    }

    public var listeningNotesURL: URL {
        directoryURL.appendingPathComponent(AudioGateRunLocator.listeningNotesFileName)
    }
}

public enum AudioGateRunLocator {
    public static let directoryName = "AudioGateRuns"
    public static let wavFileName = "engine-output.wav"
    public static let eventsFileName = "events.jsonl"
    public static let summaryJSONFileName = "summary.json"
    public static let summaryMarkdownFileName = "summary.md"
    public static let listeningNotesFileName = "LISTENING_NOTES.md"

    public static func directory(in documents: URL) -> URL {
        documents.appendingPathComponent(directoryName, isDirectory: true)
    }

    public static func filesAppInstruction(appDisplayName: String) -> String {
        "Files → On My iPhone → \(appDisplayName) → \(directoryName)"
    }

    public static func documentsDirectory(fileManager: FileManager = .default) -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
    }

    /// Creates a unique run directory. Never overwrites an existing run.
    public static func createUniqueRunDirectory(
        in documents: URL,
        now: Date = Date(),
        fileManager: FileManager = .default,
        shortID: String? = nil
    ) throws -> AudioGateRunLocation {
        let root = directory(in: documents)
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: root.path, isDirectory: &isDirectory), !isDirectory.boolValue {
            throw AudioGateRunError.rootIsNotADirectory
        }

        let stamp = timestampFormatter.string(from: now)
        for attempt in 0..<32 {
            let suffix = attempt == 0
                ? (shortID ?? Self.makeShortID())
                : Self.makeShortID()
            let runID = "\(stamp)-\(suffix)"
            let url = root.appendingPathComponent(runID, isDirectory: true)
            if fileManager.fileExists(atPath: url.path) {
                continue
            }
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
                return AudioGateRunLocation(runID: runID, directoryURL: url)
            } catch {
                if fileManager.fileExists(atPath: url.path) {
                    continue
                }
                throw error
            }
        }
        throw AudioGateRunError.unableToAllocateUniqueDirectory
    }

    public static func makeShortID() -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(8)).lowercased()
    }

    static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

public enum AudioGateRunError: Error, LocalizedError, Equatable {
    case rootIsNotADirectory
    case unableToAllocateUniqueDirectory

    public var errorDescription: String? {
        switch self {
        case .rootIsNotADirectory:
            return "Could not create Documents/\(AudioGateRunLocator.directoryName): a file already exists at that name."
        case .unableToAllocateUniqueDirectory:
            return "Could not allocate a unique audio-gate run directory."
        }
    }
}

public enum AudioGateRunCompletionResolver {
    public static func resolve(
        reason: AudioGateRunFinishReason,
        reportingError: String?
    ) -> AudioGateRunCompletion {
        switch reason {
        case .failed:
            return .failed
        case .durationReached:
            return reportingError == nil ? .completed : .failed
        case .userStopped:
            return .stoppedEarly
        }
    }

    public static func failureMessage(
        reason: AudioGateRunFinishReason,
        reportingError: String?
    ) -> String? {
        var parts: [String] = []
        if case .failed(let message) = reason {
            parts.append(message)
        }
        if let reportingError, !reportingError.isEmpty {
            parts.append(reportingError)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " | ")
    }
}

/// Deterministic descriptive metrics for one run-scoped event set.
public struct AudioGateRunSummary: Equatable, Sendable {
    public var runID: String
    public var startedAt: Date
    public var endedAt: Date
    public var requestedDurationSeconds: Int
    public var capturedDurationSeconds: Int
    public var completion: AudioGateRunCompletion
    public var failureMessage: String?

    public var corpusSource: String
    public var corpusLabel: String
    public var corpusAssetCount: Int
    public var skippedMalformedCount: Int
    public var isDevFixture: Bool
    public var isDocumentsPhase1: Bool

    public var startingSweepRateMs: Int
    public var startingDirection: String
    public var observedSweepRateMs: [Int]
    public var observedDirections: [String]

    public var totalEvents: Int
    public var uniqueAssetIDs: Int
    public var corpusCoverage: Double?
    public var firstUseEventCount: Int
    public var repeatUseEventCount: Int
    public var minimumRepeatDistance: Int?
    public var medianRepeatDistance: Double?
    public var repeatDistanceBuckets: [String: Int]

    public var performerCounts: [String: Int]
    public var performerPercents: [String: Double]
    public var voiceFamilyCounts: [String: Int]
    public var voiceFamilyPercents: [String: Double]
    public var maxConsecutiveSamePerformer: Int
    public var maxConsecutiveSameVoiceFamily: Int

    public var relaxedConstraintCounts: [String: Int]
    public var eventsRequiringRelaxation: Int
    public var relaxationPercent: Double?

    public static func make(
        runID: String,
        startedAt: Date,
        endedAt: Date,
        requestedDurationSeconds: Int,
        capturedDurationSeconds: Int,
        completion: AudioGateRunCompletion,
        failureMessage: String?,
        corpus: LoadedCorpus,
        startingSweepRate: SweepRate,
        startingDirection: SweepDirection,
        events: [SweepEvent]
    ) -> AudioGateRunSummary {
        let uniqueAssets = Set(events.map(\.assetID))
        let coverage: Double?
        if corpus.assetCount > 0 {
            coverage = Double(uniqueAssets.count) / Double(corpus.assetCount)
        } else {
            coverage = nil
        }

        let firstUse = events.filter { $0.eventsSincePreviousUse == nil }.count
        let repeatDistances = events.compactMap(\.eventsSincePreviousUse)
        let buckets = [
            "0-4": repeatDistances.filter { $0 <= 4 }.count,
            "5-9": repeatDistances.filter { $0 >= 5 && $0 <= 9 }.count,
            "10-19": repeatDistances.filter { $0 >= 10 && $0 <= 19 }.count,
            "20+": repeatDistances.filter { $0 >= 20 }.count,
        ]

        let performerCounts = counted(events.compactMap(\.performerID))
        let familyCounts = counted(events.compactMap(\.voiceFamily))
        let total = events.count

        let relaxedCounts = counted(events.flatMap { $0.relaxedConstraints.map(\.rawValue) })
        let needingRelaxation = events.filter { !$0.relaxedConstraints.isEmpty }.count

        return AudioGateRunSummary(
            runID: runID,
            startedAt: startedAt,
            endedAt: endedAt,
            requestedDurationSeconds: requestedDurationSeconds,
            capturedDurationSeconds: capturedDurationSeconds,
            completion: completion,
            failureMessage: failureMessage,
            corpusSource: describeCorpusSource(corpus.source),
            corpusLabel: corpus.label,
            corpusAssetCount: corpus.assetCount,
            skippedMalformedCount: corpus.skippedMalformedCount,
            isDevFixture: corpus.isDevFixture,
            isDocumentsPhase1: corpus.source == .documentsPhase1,
            startingSweepRateMs: startingSweepRate.milliseconds,
            startingDirection: startingDirection.debugLabel,
            observedSweepRateMs: Array(Set(events.map(\.sweepRate.milliseconds))).sorted(),
            observedDirections: Array(Set(events.map(\.direction.debugLabel))).sorted(),
            totalEvents: total,
            uniqueAssetIDs: uniqueAssets.count,
            corpusCoverage: coverage,
            firstUseEventCount: firstUse,
            repeatUseEventCount: repeatDistances.count,
            minimumRepeatDistance: repeatDistances.min(),
            medianRepeatDistance: median(repeatDistances),
            repeatDistanceBuckets: buckets,
            performerCounts: performerCounts,
            performerPercents: percents(performerCounts, total: total),
            voiceFamilyCounts: familyCounts,
            voiceFamilyPercents: percents(familyCounts, total: total),
            maxConsecutiveSamePerformer: maxConsecutive(events.map(\.performerID)),
            maxConsecutiveSameVoiceFamily: maxConsecutive(events.map(\.voiceFamily)),
            relaxedConstraintCounts: relaxedCounts,
            eventsRequiringRelaxation: needingRelaxation,
            relaxationPercent: total > 0 ? (Double(needingRelaxation) / Double(total)) * 100.0 : nil
        )
    }

    public func jsonObject() -> [String: Any] {
        var payload: [String: Any] = [
            "run_id": runID,
            "started_at": AudioGateRunISO.string(from: startedAt),
            "ended_at": AudioGateRunISO.string(from: endedAt),
            "requested_duration_seconds": requestedDurationSeconds,
            "captured_duration_seconds": capturedDurationSeconds,
            "completion": completion.rawValue,
            "corpus_source": corpusSource,
            "corpus_label": corpusLabel,
            "corpus_asset_count": corpusAssetCount,
            "skipped_malformed_count": skippedMalformedCount,
            "is_dev_fixtures": isDevFixture,
            "is_documents_phase1": isDocumentsPhase1,
            "starting_sweep_rate_ms": startingSweepRateMs,
            "starting_direction": startingDirection,
            "observed_sweep_rates_ms": observedSweepRateMs,
            "observed_directions": observedDirections,
            "total_scheduled_fragment_events": totalEvents,
            "unique_asset_ids_used": uniqueAssetIDs,
            "first_use_event_count": firstUseEventCount,
            "repeat_use_event_count": repeatUseEventCount,
            "repeat_distance_buckets": repeatDistanceBuckets,
            "performer_event_counts": performerCounts,
            "performer_event_percents": performerPercents,
            "voice_family_event_counts": voiceFamilyCounts,
            "voice_family_event_percents": voiceFamilyPercents,
            "max_consecutive_same_performer": maxConsecutiveSamePerformer,
            "max_consecutive_same_voice_family": maxConsecutiveSameVoiceFamily,
            "relaxed_constraint_counts": relaxedConstraintCounts,
            "events_requiring_relaxation": eventsRequiringRelaxation,
        ]
        payload["failure_message"] = failureMessage.map { $0 as Any } ?? NSNull()
        payload["corpus_coverage"] = corpusCoverage.map { $0 as Any } ?? NSNull()
        payload["minimum_repeat_distance"] = minimumRepeatDistance.map { $0 as Any } ?? NSNull()
        payload["median_repeat_distance"] = medianRepeatDistance.map { $0 as Any } ?? NSNull()
        payload["relaxation_percent"] = relaxationPercent.map { $0 as Any } ?? NSNull()
        return payload
    }

    public func jsonData() throws -> Data {
        try JSONSerialization.data(withJSONObject: jsonObject(), options: [.prettyPrinted, .sortedKeys])
    }

    public func markdown() -> String {
        var lines: [String] = []
        lines.append("AUDIO GATE STATUS:")
        lines.append("NOT YET PASSED BY THIS RUN")
        lines.append("")
        lines.append("AUTOMATED METRICS ARE DIAGNOSTIC ONLY.")
        lines.append("THE CANONICAL AUDIO GATE REQUIRES HUMAN LISTENING.")
        lines.append("")
        if isDevFixture {
            lines.append("DEV FIXTURES CANNOT PASS THE CANONICAL AUDIO GATE.")
            lines.append("")
        }
        if completion == .stoppedEarly {
            lines.append("INCOMPLETE / STOPPED EARLY")
            lines.append("")
        }
        lines.append("Run ID: \(runID)")
        lines.append("Completion: \(completion.rawValue)")
        if let failureMessage {
            lines.append("Reporting note: \(failureMessage)")
        }
        lines.append("Started: \(AudioGateRunISO.string(from: startedAt))")
        lines.append("Ended: \(AudioGateRunISO.string(from: endedAt))")
        lines.append("Requested duration: \(requestedDurationSeconds)s")
        lines.append("Captured duration: \(capturedDurationSeconds)s")
        lines.append("")
        lines.append("Corpus source: \(corpusSource)")
        lines.append("Corpus label: \(corpusLabel)")
        lines.append("Corpus asset count: \(corpusAssetCount)")
        lines.append("Skipped/malformed: \(skippedMalformedCount)")
        lines.append("DevFixtures: \(isDevFixture ? "yes" : "no")")
        lines.append("Documents Phase 1: \(isDocumentsPhase1 ? "yes" : "no")")
        lines.append("")
        lines.append("Starting sweep rate: \(startingSweepRateMs) ms")
        lines.append("Starting direction: \(startingDirection)")
        lines.append("Observed sweep rates (ms): \(observedSweepRateMs.map(String.init).joined(separator: ", "))")
        lines.append("Observed directions: \(observedDirections.joined(separator: ", "))")
        lines.append("")
        lines.append("Scheduled fragment events: \(totalEvents)")
        lines.append("Unique asset IDs used: \(uniqueAssetIDs)")
        if let corpusCoverage {
            lines.append(
                String(
                    format: "Corpus coverage: %d / %d (%.3f)",
                    uniqueAssetIDs,
                    corpusAssetCount,
                    corpusCoverage
                )
            )
        } else {
            lines.append("Corpus coverage: n/a (zero-asset corpus)")
        }
        lines.append("First-use events: \(firstUseEventCount)")
        lines.append("Repeat-use events: \(repeatUseEventCount)")
        lines.append("Minimum repeat distance: \(minimumRepeatDistance.map(String.init) ?? "n/a")")
        lines.append("Median repeat distance: \(medianRepeatDistance.map { String(format: "%.1f", $0) } ?? "n/a")")
        lines.append("Repeat-distance buckets:")
        for key in ["0-4", "5-9", "10-19", "20+"] {
            lines.append("  \(key): \(repeatDistanceBuckets[key] ?? 0)")
        }
        lines.append("")
        lines.append("Performer event counts:")
        appendCountLines(&lines, counts: performerCounts, percents: performerPercents)
        lines.append("Max consecutive same performer: \(maxConsecutiveSamePerformer)")
        lines.append("Voice-family event counts:")
        appendCountLines(&lines, counts: voiceFamilyCounts, percents: voiceFamilyPercents)
        lines.append("Max consecutive same voice family: \(maxConsecutiveSameVoiceFamily)")
        lines.append("")
        lines.append("Scheduler relaxation counts:")
        if relaxedConstraintCounts.isEmpty {
            lines.append("  (none)")
        } else {
            for key in relaxedConstraintCounts.keys.sorted() {
                lines.append("  \(key): \(relaxedConstraintCounts[key] ?? 0)")
            }
        }
        lines.append("Events requiring any relaxation: \(eventsRequiringRelaxation)")
        if let relaxationPercent {
            lines.append(String(format: "Relaxation percent: %.1f", relaxationPercent))
        } else {
            lines.append("Relaxation percent: n/a")
        }
        lines.append("")
        lines.append("These figures describe scheduler/corpus usage only.")
        lines.append("They are not a listening verdict.")
        return lines.joined(separator: "\n") + "\n"
    }

    public static func listeningNotes(runID: String) -> String {
        """
        Run ID: \(runID)
        Listener:
        Device/output route:
        Approximate listening volume:
        Date:

        Questions:

        1. What, if anything, made the audio feel artificial?

        2. Did you notice repeated sounds or voices?
           If yes:
           - approximate timestamp
           - description

        3. Did anything seem timed as a response to what was said?
           If yes:
           - approximate timestamp
           - description

        4. Did the output feel like:
           - continuous instrument
           - small set of clips
           - unsure

        5. Additional observations:

        """
    }
}

public enum AudioGateRunBundleWriter {
    public static func writeListeningNotes(
        to url: URL,
        runID: String,
        fileManager: FileManager = .default
    ) throws {
        try writeNewFile(AudioGateRunSummary.listeningNotes(runID: runID), to: url, fileManager: fileManager)
    }

    public static func writeSummaries(
        _ summary: AudioGateRunSummary,
        location: AudioGateRunLocation,
        fileManager: FileManager = .default
    ) throws {
        let json = try summary.jsonData()
        var errors: [String] = []
        do {
            try writeNewFile(json, to: location.summaryJSONURL, fileManager: fileManager)
        } catch {
            errors.append(error.localizedDescription)
        }
        do {
            try writeNewFile(summary.markdown(), to: location.summaryMarkdownURL, fileManager: fileManager)
        } catch {
            errors.append(error.localizedDescription)
        }
        if !errors.isEmpty {
            throw AudioGateRunBundleWriteError.partialWrite(errors.joined(separator: "; "))
        }
    }

    /// Writes only if the destination does not already exist.
    public static func writeNewFile(
        _ contents: String,
        to url: URL,
        fileManager: FileManager = .default
    ) throws {
        try writeNewFile(Data(contents.utf8), to: url, fileManager: fileManager)
    }

    public static func writeNewFile(
        _ data: Data,
        to url: URL,
        fileManager: FileManager = .default
    ) throws {
        if fileManager.fileExists(atPath: url.path) {
            throw AudioGateRunBundleWriteError.wouldOverwrite(url.lastPathComponent)
        }
        try data.write(to: url, options: .withoutOverwriting)
    }
}

public enum AudioGateRunBundleWriteError: Error, LocalizedError, Equatable {
    case wouldOverwrite(String)
    case partialWrite(String)

    public var errorDescription: String? {
        switch self {
        case .wouldOverwrite(let name):
            return "Refusing to overwrite existing run file \(name)."
        case .partialWrite(let message):
            return message
        }
    }
}

public enum AudioGateRunState: Equatable, Sendable {
    case idle
    case running(
        runID: String,
        elapsedSeconds: Int,
        durationSeconds: Int,
        directoryName: String,
        corpusSource: String,
        isDevFixture: Bool
    )
    case finalized(
        runID: String,
        completion: AudioGateRunCompletion,
        capturedSeconds: Int,
        durationSeconds: Int,
        directoryName: String,
        corpusSource: String,
        isDevFixture: Bool,
        failureMessage: String?
    )
}

enum AudioGateRunISO {
    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

private func describeCorpusSource(_ source: CorpusSource) -> String {
    switch source {
    case .documentsPhase1:
        return "Documents/SpiritBoxPhase1Corpus"
    case .bundlePhase1:
        return "Bundle/Phase1"
    case .bundleDevFixtures:
        return "Bundle/DevFixtures"
    case .empty:
        return "none"
    }
}

private func counted(_ values: [String]) -> [String: Int] {
    var result: [String: Int] = [:]
    for value in values {
        result[value, default: 0] += 1
    }
    return result
}

private func percents(_ counts: [String: Int], total: Int) -> [String: Double] {
    guard total > 0 else { return [:] }
    var result: [String: Double] = [:]
    for (key, count) in counts {
        result[key] = (Double(count) / Double(total)) * 100.0
    }
    return result
}

private func median(_ values: [Int]) -> Double? {
    guard !values.isEmpty else { return nil }
    let sorted = values.sorted()
    let middle = sorted.count / 2
    if sorted.count.isMultiple(of: 2) {
        return Double(sorted[middle - 1] + sorted[middle]) / 2.0
    }
    return Double(sorted[middle])
}

private func maxConsecutive(_ values: [String?]) -> Int {
    var longest = 0
    var current = 0
    var last: String?
    for value in values {
        guard let value else {
            current = 0
            last = nil
            continue
        }
        if value == last {
            current += 1
        } else {
            current = 1
            last = value
        }
        longest = max(longest, current)
    }
    return longest
}

private func appendCountLines(_ lines: inout [String], counts: [String: Int], percents: [String: Double]) {
    if counts.isEmpty {
        lines.append("  (none)")
        return
    }
    for key in counts.keys.sorted() {
        let percent = percents[key].map { String(format: "%.1f%%", $0) } ?? "n/a"
        lines.append("  \(key): \(counts[key] ?? 0) (\(percent))")
    }
}
