import Foundation

public struct SchedulerConfiguration: Equatable, Sendable {
    /// Rolling recent-use exclusion window, in fragment events.
    public var recentExclusionWindow: Int
    public var avoidConsecutiveSamePerformerOrVoiceFamily: Bool
    public var avoidConsecutiveSamePhoneticOrSourceFamily: Bool

    public init(
        recentExclusionWindow: Int = 8,
        avoidConsecutiveSamePerformerOrVoiceFamily: Bool = true,
        avoidConsecutiveSamePhoneticOrSourceFamily: Bool = true
    ) {
        self.recentExclusionWindow = max(0, recentExclusionWindow)
        self.avoidConsecutiveSamePerformerOrVoiceFamily = avoidConsecutiveSamePerformerOrVoiceFamily
        self.avoidConsecutiveSamePhoneticOrSourceFamily = avoidConsecutiveSamePhoneticOrSourceFamily
    }

    public static let `default` = SchedulerConfiguration()
}

public struct SchedulePick: Equatable, Sendable {
    public var asset: SourceAsset
    public var relaxedConstraints: [RelaxedConstraint]
    public var eventsSincePreviousUse: Int?
    public var eventsSinceSpeakerUse: Int? = nil
    public var decisionSummary: String
}

public enum ScheduleOutcome: Equatable, Sendable {
    case emptyCorpus
    case picked(SchedulePick)
}

/// Completely non-semantic fragment scheduler.
///
/// May use asset identity, performer / voice family, phonetic/source family,
/// duration, direction eligibility, and recent-use history.
/// Must never use meaning, user speech, microphone input, or expected answers.
public final class SweepScheduler: @unchecked Sendable {
    private let assets: [SourceAsset]
    public var configuration: SchedulerConfiguration

    private var historyIDs: [String] = []
    private var lastEventIndexByAssetID: [String: Int] = [:]
    private var eventCount = 0
    private var lastPickedID: String?
    private var recentUtterances: [String] = []
    private var recentSpeakers: [String] = []
    private var lastSpeakerIndex: [String: Int] = [:]
    private let seed: UInt64
    private var useCounts: [String: Int] = [:]
    private let usesProvenance: Bool
    private var orderCache: [SweepDirection: [SourceAsset]] = [:]
    // Hard limits for sentence-derived corpora. Never relaxed to fill a vocal slot.
    public static let fragmentCooldown = 64
    public static let utteranceCooldown = 32
    public static let speakerCooldown = 2

    public init(assets: [SourceAsset], configuration: SchedulerConfiguration = .default, seed: UInt64 = 0xC0FFEE) {
        self.assets = assets.filter { !$0.assetID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        self.configuration = configuration
        self.seed = seed
        self.usesProvenance = assets.contains { $0.utteranceID != nil || $0.rightsRecordID == "VCTK-0.92-CCBY4" }
    }

    public var acceptedAssetCount: Int { assets.count }

    public func resetTraversal() {
        lastPickedID = nil
    }

    public func resetHistory() {
        historyIDs = []
        recentUtterances = []
        recentSpeakers = []
        lastSpeakerIndex = [:]
        useCounts = [:]
        lastEventIndexByAssetID = [:]
        eventCount = 0
        lastPickedID = nil
    }

    public func orderedEligibleAssets(for direction: SweepDirection) -> [SourceAsset] {
        if let cached = orderCache[direction] { return cached }
        let eligible = assets.filter { $0.isEligible(for: direction) }
        let sorted = eligible.sorted {
            if usesProvenance {
                let left = stableOrder($0.assetID), right = stableOrder($1.assetID)
                if left != right { return left < right }
            }
            return $0.assetID < $1.assetID
        }
        let ordered = direction == .forward ? sorted : Array(sorted.reversed())
        orderCache[direction] = ordered
        return ordered
    }

    public func next(direction: SweepDirection) -> ScheduleOutcome {
        let ordered = orderedEligibleAssets(for: direction)
        guard !ordered.isEmpty else {
            return .emptyCorpus
        }

        let last = lastPickedID.flatMap { id in assets.first { $0.assetID == id } }
        let start = startIndex(in: ordered)

        if usesProvenance {
            // Prefer the least-used admissible asset; directional ring order breaks
            // ties. A last-pick cursor plus short strides can bounce in a tiny
            // region forever when direction changes. Fairness must be independent
            // of that cursor, and survives direction changes with the cooldowns.
            let fragments = Set(historyIDs.suffix(Self.fragmentCooldown))
            let utterances = Set(recentUtterances)
            let speakers = Set(recentSpeakers.suffix(Self.speakerCooldown))
            var candidate: SourceAsset?
            var minimumUses = Int.max
            for offset in 0..<ordered.count {
                let asset = ordered[(start + offset) % ordered.count]
                let uses = useCounts[asset.assetID, default: 0]
                guard uses < minimumUses,
                      let utterance = asset.utteranceID, !utterance.isEmpty,
                      let speaker = asset.performerID, !speaker.isEmpty,
                      !fragments.contains(asset.assetID),
                      !utterances.contains(utterance),
                      !speakers.contains(speaker)
                else { continue }
                candidate = asset
                minimumUses = uses
                if uses == 0 { break }
            }
            if let candidate { return .picked(recordPick(candidate, relaxed: [])) }
            // Noise continues; do not violate source protections for an exhausted bank.
            return .emptyCorpus
        }

        let passes: [[RelaxedConstraint]] = [
            [],
            [.highRecognitionRisk],
            [.highRecognitionRisk, .phoneticFamily],
            [.highRecognitionRisk, .phoneticFamily, .performerOrVoiceFamily],
            [.highRecognitionRisk, .phoneticFamily, .performerOrVoiceFamily, .recentWindow],
            [.highRecognitionRisk, .phoneticFamily, .performerOrVoiceFamily, .recentWindow, .consecutiveAsset],
        ]

        for relaxed in passes {
            if let asset = firstCandidate(
                in: ordered,
                start: start,
                last: last,
                relaxing: Set(relaxed)
            ) {
                return .picked(recordPick(asset, relaxed: relaxed))
            }
        }

        return .picked(recordPick(ordered[start], relaxed: RelaxedConstraint.allCases))
    }

    private func stableOrder(_ id: String) -> UInt64 {
        // Swift Hasher is process-randomized; FNV is stable across devices/runs.
        id.utf8.reduce(14_695_981_039_346_656_037 ^ seed) { ($0 ^ UInt64($1)) &* 1_099_511_628_211 }
    }

    private func startIndex(in ordered: [SourceAsset]) -> Int {
        guard let lastPickedID,
              let index = ordered.firstIndex(where: { $0.assetID == lastPickedID })
        else {
            return 0
        }
        return (index + 1) % ordered.count
    }

    private func firstCandidate(
        in ordered: [SourceAsset],
        start: Int,
        last: SourceAsset?,
        relaxing: Set<RelaxedConstraint>
    ) -> SourceAsset? {
        for offset in 0..<ordered.count {
            let asset = ordered[(start + offset) % ordered.count]
            if isAllowed(asset, last: last, bank: ordered, relaxing: relaxing) {
                return asset
            }
        }
        return nil
    }

    private func isAllowed(
        _ asset: SourceAsset,
        last: SourceAsset?,
        bank: [SourceAsset],
        relaxing: Set<RelaxedConstraint>
    ) -> Bool {
        let alternativesExist = bank.count > 1

        if !relaxing.contains(.highRecognitionRisk),
           asset.isHighRecognitionRisk {
            let hasSafer = bank.contains { !$0.isHighRecognitionRisk }
            if hasSafer {
                return false
            }
        }

        if !relaxing.contains(.consecutiveAsset),
           alternativesExist,
           let last,
           asset.assetID == last.assetID {
            return false
        }

        if !relaxing.contains(.recentWindow) {
            let window = configuration.recentExclusionWindow
            if window > 0 {
                let recent = Array(historyIDs.suffix(window))
                if recent.contains(asset.assetID) {
                    return false
                }
            }
        }

        if configuration.avoidConsecutiveSamePerformerOrVoiceFamily,
           !relaxing.contains(.performerOrVoiceFamily),
           let last,
           SourceAsset.sharesPerformerOrVoiceFamily(asset, last) {
            let hasAlternative = bank.contains { !SourceAsset.sharesPerformerOrVoiceFamily($0, last) }
            if hasAlternative {
                return false
            }
        }

        if configuration.avoidConsecutiveSamePhoneticOrSourceFamily,
           !relaxing.contains(.phoneticFamily),
           let last,
           SourceAsset.sharesPhoneticOrSourceFamily(asset, last) {
            let hasAlternative = bank.contains { !SourceAsset.sharesPhoneticOrSourceFamily($0, last) }
            if hasAlternative {
                return false
            }
        }

        return true
    }

    private func recordPick(_ asset: SourceAsset, relaxed: [RelaxedConstraint]) -> SchedulePick {
        let previousIndex = lastEventIndexByAssetID[asset.assetID]
        let sincePrevious = previousIndex.map { eventCount - $0 }
        let summary: String
        if relaxed.isEmpty {
            summary = "all constraints satisfied"
        } else {
            let names = relaxed.map(\.rawValue).joined(separator: ", ")
            summary = "relaxed \(names)"
        }

        let speakerDistance = asset.performerID.flatMap { lastSpeakerIndex[$0] }.map { eventCount - $0 }
        if let speaker = asset.performerID {
            lastSpeakerIndex[speaker] = eventCount
            recentSpeakers.append(speaker)
            recentSpeakers = Array(recentSpeakers.suffix(Self.speakerCooldown))
        }
        if let utterance = asset.utteranceID {
            recentUtterances.append(utterance)
            recentUtterances = Array(recentUtterances.suffix(Self.utteranceCooldown))
        }
        useCounts[asset.assetID, default: 0] += 1
        lastPickedID = asset.assetID
        lastEventIndexByAssetID[asset.assetID] = eventCount
        historyIDs.append(asset.assetID)
        historyIDs = Array(historyIDs.suffix(max(Self.fragmentCooldown, configuration.recentExclusionWindow)))
        eventCount += 1

        return SchedulePick(
            asset: asset,
            relaxedConstraints: relaxed,
            eventsSincePreviousUse: sincePrevious,
            eventsSinceSpeakerUse: speakerDistance,
            decisionSummary: summary
        )
    }
}

/// Independent Layer B scheduler: decide whether a sweep slot exposes a vocal.
///
/// Does not pick assets, listen to the microphone, or time events to questions.
/// Stickiness is only to avoid a metronomic voice / noise / voice pattern.
public final class VocalDensityScheduler: @unchecked Sendable {
    public private(set) var settings: SweepRendererSettings
    private var seed: UInt64
    private var lastWasVocal = false
    private var consecutiveVocals = 0

    public init(settings: SweepRendererSettings = .listeningTest, seed: UInt64 = 0xC0FFEE) {
        self.settings = settings
        self.seed = seed
    }

    public func updateSettings(_ settings: SweepRendererSettings) {
        self.settings = settings.clamped()
        // Preserve the hard streak limit when internal tuning changes mid-run.
    }

    public func reset(seed: UInt64? = nil) {
        if let seed {
            self.seed = seed
        }
        lastWasVocal = false
        consecutiveVocals = 0
    }

    public var continueProbability: Double {
        slotProbability(afterVocal: true)
    }

    public var startProbability: Double {
        slotProbability(afterVocal: false)
    }

    public func nextContainsVocal() -> Bool {
        let probability = lastWasVocal ? continueProbability : startProbability
        seed = seed &* 6_364_136_223_846_793_005 &+ 1
        let draw = Double(seed % 10_000) / 10_000.0
        let vocal = consecutiveVocals < 2 && draw < probability
        consecutiveVocals = vocal ? consecutiveVocals + 1 : 0
        lastWasVocal = vocal
        return vocal
    }

    private func slotProbability(afterVocal: Bool) -> Double {
        let base = min(1, max(0, settings.vocalEventProbability))
        let cluster = min(1, max(0, settings.clusteriness))
        if afterVocal {
            return min(1, max(0, base + cluster * (1 - base) * 0.55))
        }
        return min(1, max(0, base * (1 - cluster * 0.55)))
    }
}
