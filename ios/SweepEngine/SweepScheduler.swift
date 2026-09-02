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
    public let configuration: SchedulerConfiguration

    private var historyIDs: [String] = []
    private var lastEventIndexByAssetID: [String: Int] = [:]
    private var eventCount = 0
    private var lastPickedID: String?

    public init(assets: [SourceAsset], configuration: SchedulerConfiguration = .default) {
        self.assets = assets.filter { !$0.assetID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        self.configuration = configuration
    }

    public var acceptedAssetCount: Int { assets.count }

    public func resetTraversal() {
        lastPickedID = nil
    }

    public func resetHistory() {
        historyIDs = []
        lastEventIndexByAssetID = [:]
        eventCount = 0
        lastPickedID = nil
    }

    public func orderedEligibleAssets(for direction: SweepDirection) -> [SourceAsset] {
        let eligible = assets.filter { $0.isEligible(for: direction) }
        let sorted = eligible.sorted { $0.assetID < $1.assetID }
        return direction == .forward ? sorted : Array(sorted.reversed())
    }

    public func next(direction: SweepDirection) -> ScheduleOutcome {
        let ordered = orderedEligibleAssets(for: direction)
        guard !ordered.isEmpty else {
            return .emptyCorpus
        }

        let last = lastPickedID.flatMap { id in assets.first { $0.assetID == id } }
        let start = startIndex(in: ordered)

        let passes: [[RelaxedConstraint]] = [
            [],
            [.phoneticFamily],
            [.phoneticFamily, .performerOrVoiceFamily],
            [.phoneticFamily, .performerOrVoiceFamily, .recentWindow],
            [.phoneticFamily, .performerOrVoiceFamily, .recentWindow, .consecutiveAsset],
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

        lastPickedID = asset.assetID
        lastEventIndexByAssetID[asset.assetID] = eventCount
        historyIDs.append(asset.assetID)
        eventCount += 1

        return SchedulePick(
            asset: asset,
            relaxedConstraints: relaxed,
            eventsSincePreviousUse: sincePrevious,
            decisionSummary: summary
        )
    }
}
