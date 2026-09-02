import Foundation

/// Runtime source-asset metadata compatible with the Phase 1 production plan.
///
/// Fields are technical only. Nothing here is semantic content, a word list,
/// or a paranormal interpretation.
public struct SourceAsset: Identifiable, Hashable, Codable, Sendable, Equatable {
    public var assetID: String
    public var performerID: String?
    public var voiceFamily: String?
    public var sourceType: String?
    public var phoneticFamily: String?
    public var voicing: String?
    public var register: String?
    public var delivery: String?
    public var durationMs: Int?
    public var recognitionRisk: String?
    public var forwardAllowed: Bool
    public var reverseAllowed: Bool
    public var cropSafeStartMs: Int?
    public var cropSafeEndMs: Int?
    public var prepVersion: String?
    public var rightsRecordID: String?
    /// Path relative to the loaded corpus root. Harness-specific locator.
    public var relativePath: String

    public var id: String { assetID }

    public init(
        assetID: String,
        performerID: String? = nil,
        voiceFamily: String? = nil,
        sourceType: String? = nil,
        phoneticFamily: String? = nil,
        voicing: String? = nil,
        register: String? = nil,
        delivery: String? = nil,
        durationMs: Int? = nil,
        recognitionRisk: String? = nil,
        forwardAllowed: Bool = true,
        reverseAllowed: Bool = true,
        cropSafeStartMs: Int? = nil,
        cropSafeEndMs: Int? = nil,
        prepVersion: String? = nil,
        rightsRecordID: String? = nil,
        relativePath: String = ""
    ) {
        self.assetID = assetID
        self.performerID = performerID
        self.voiceFamily = voiceFamily
        self.sourceType = sourceType
        self.phoneticFamily = phoneticFamily
        self.voicing = voicing
        self.register = register
        self.delivery = delivery
        self.durationMs = durationMs
        self.recognitionRisk = recognitionRisk
        self.forwardAllowed = forwardAllowed
        self.reverseAllowed = reverseAllowed
        self.cropSafeStartMs = cropSafeStartMs
        self.cropSafeEndMs = cropSafeEndMs
        self.prepVersion = prepVersion
        self.rightsRecordID = rightsRecordID
        self.relativePath = relativePath
    }

    enum CodingKeys: String, CodingKey {
        case assetID = "asset_id"
        case performerID = "performer_id"
        case voiceFamily = "voice_family"
        case sourceType = "source_type"
        case phoneticFamily = "phonetic_family"
        case voicing
        case register
        case delivery
        case durationMs = "duration_ms"
        case recognitionRisk = "recognition_risk"
        case forwardAllowed = "forward_allowed"
        case reverseAllowed = "reverse_allowed"
        case cropSafeStartMs = "crop_safe_start_ms"
        case cropSafeEndMs = "crop_safe_end_ms"
        case prepVersion = "prep_version"
        case rightsRecordID = "rights_record_id"
        case relativePath = "relative_path"
        case filename
        case finalFilename = "final_filename"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetID = try container.decode(String.self, forKey: .assetID)
        performerID = try container.decodeIfPresent(String.self, forKey: .performerID)
        voiceFamily = try container.decodeIfPresent(String.self, forKey: .voiceFamily)
        sourceType = try container.decodeIfPresent(String.self, forKey: .sourceType)
        phoneticFamily = try container.decodeIfPresent(String.self, forKey: .phoneticFamily)
        voicing = try container.decodeIfPresent(String.self, forKey: .voicing)
        register = try container.decodeIfPresent(String.self, forKey: .register)
        delivery = try container.decodeIfPresent(String.self, forKey: .delivery)
        durationMs = try container.decodeIfPresent(Int.self, forKey: .durationMs)
        recognitionRisk = try container.decodeIfPresent(String.self, forKey: .recognitionRisk)
        forwardAllowed = try container.decodeIfPresent(Bool.self, forKey: .forwardAllowed) ?? true
        reverseAllowed = try container.decodeIfPresent(Bool.self, forKey: .reverseAllowed) ?? true
        cropSafeStartMs = try container.decodeIfPresent(Int.self, forKey: .cropSafeStartMs)
        cropSafeEndMs = try container.decodeIfPresent(Int.self, forKey: .cropSafeEndMs)
        prepVersion = try container.decodeIfPresent(String.self, forKey: .prepVersion)
        rightsRecordID = try container.decodeIfPresent(String.self, forKey: .rightsRecordID)

        if let path = try container.decodeIfPresent(String.self, forKey: .relativePath), !path.isEmpty {
            relativePath = path
        } else if let path = try container.decodeIfPresent(String.self, forKey: .filename), !path.isEmpty {
            relativePath = path
        } else if let path = try container.decodeIfPresent(String.self, forKey: .finalFilename), !path.isEmpty {
            relativePath = path
        } else {
            relativePath = ""
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(assetID, forKey: .assetID)
        try container.encodeIfPresent(performerID, forKey: .performerID)
        try container.encodeIfPresent(voiceFamily, forKey: .voiceFamily)
        try container.encodeIfPresent(sourceType, forKey: .sourceType)
        try container.encodeIfPresent(phoneticFamily, forKey: .phoneticFamily)
        try container.encodeIfPresent(voicing, forKey: .voicing)
        try container.encodeIfPresent(register, forKey: .register)
        try container.encodeIfPresent(delivery, forKey: .delivery)
        try container.encodeIfPresent(durationMs, forKey: .durationMs)
        try container.encodeIfPresent(recognitionRisk, forKey: .recognitionRisk)
        try container.encode(forwardAllowed, forKey: .forwardAllowed)
        try container.encode(reverseAllowed, forKey: .reverseAllowed)
        try container.encodeIfPresent(cropSafeStartMs, forKey: .cropSafeStartMs)
        try container.encodeIfPresent(cropSafeEndMs, forKey: .cropSafeEndMs)
        try container.encodeIfPresent(prepVersion, forKey: .prepVersion)
        try container.encodeIfPresent(rightsRecordID, forKey: .rightsRecordID)
        try container.encode(relativePath, forKey: .relativePath)
    }

    public var isDirectionEligible: Bool {
        forwardAllowed || reverseAllowed
    }

    public func isEligible(for direction: SweepDirection) -> Bool {
        switch direction {
        case .forward: return forwardAllowed
        case .reverse: return reverseAllowed
        }
    }

    /// Missing IDs are not treated as a shared family.
    public static func sharesPerformerOrVoiceFamily(_ a: SourceAsset, _ b: SourceAsset) -> Bool {
        if let left = a.performerID?.nonEmpty, let right = b.performerID?.nonEmpty, left == right {
            return true
        }
        if let left = a.voiceFamily?.nonEmpty, let right = b.voiceFamily?.nonEmpty, left == right {
            return true
        }
        return false
    }

    public static func sharesPhoneticOrSourceFamily(_ a: SourceAsset, _ b: SourceAsset) -> Bool {
        if let left = a.phoneticFamily?.nonEmpty, let right = b.phoneticFamily?.nonEmpty {
            return left == right
        }
        if a.phoneticFamily?.nonEmpty == nil,
           b.phoneticFamily?.nonEmpty == nil,
           let left = a.sourceType?.nonEmpty,
           let right = b.sourceType?.nonEmpty {
            return left == right
        }
        return false
    }
}

public struct CorpusManifest: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var label: String?
    public var kind: String?
    public var assets: [SourceAsset]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case label
        case kind
        case assets
    }

    public init(schemaVersion: Int = 1, label: String? = nil, kind: String? = nil, assets: [SourceAsset]) {
        self.schemaVersion = schemaVersion
        self.label = label
        self.kind = kind
        self.assets = assets
    }
}

public enum CorpusSource: String, Equatable, Sendable {
    case documentsPhase1
    case bundlePhase1
    case bundleDevFixtures
    case empty
}

public struct LoadedCorpus: Equatable, Sendable {
    public var assets: [SourceAsset]
    public var skippedMalformedCount: Int
    public var source: CorpusSource
    public var label: String
    public var isDevFixture: Bool
    public var rootURL: URL?

    public var assetCount: Int { assets.count }

    public static let empty = LoadedCorpus(
        assets: [],
        skippedMalformedCount: 0,
        source: .empty,
        label: "No corpus loaded",
        isDevFixture: true,
        rootURL: nil
    )
}

extension String {
    fileprivate var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
