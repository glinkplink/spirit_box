import Foundation

/// Discrete sweep-rate detents locked for the audio harness.
/// Changing the selected rate must change scheduler cadence.
public enum SweepRate: Int, CaseIterable, Equatable, Sendable {
    case ms75 = 75
    case ms125 = 125
    case ms200 = 200
    case ms300 = 300

    public static let `default` = SweepRate.ms200

    public var milliseconds: Int { rawValue }

    public var timeInterval: TimeInterval {
        TimeInterval(rawValue) / 1000.0
    }
}

/// Traversal direction through eligible source material.
/// Reverse is the opposite ordered walk — not a relabel of the same random schedule.
public enum SweepDirection: String, CaseIterable, Equatable, Sendable {
    case forward
    case reverse

    public var debugLabel: String {
        switch self {
        case .forward: return "FWD"
        case .reverse: return "REV"
        }
    }
}

/// Constraints the scheduler may drop, in order, when the bank is too small.
public enum RelaxedConstraint: String, CaseIterable, Equatable, Sendable {
    case phoneticFamily = "phonetic_family"
    case performerOrVoiceFamily = "performer_or_voice_family"
    case recentWindow = "recent_window"
    case consecutiveAsset = "consecutive_asset"
}

/// Canonical 15–20 minute listening gate. Dev fixtures cannot satisfy it.
public enum AudioGateStatus {
    public static let notYetRunWaitingForPhase1Corpus =
        "NOT YET RUN — WAITING FOR PHASE 1 CORPUS"
}
