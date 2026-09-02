"""Canonical Phase 1 validation constants aligned with production plan."""

from __future__ import annotations

SCHEMA_VERSIONS = {1}

PHASE1_PERFORMERS = ("P01", "P02", "P03", "P04")
PHASE1_TOTAL_ASSETS = 120
PHASE1_ASSETS_PER_PERFORMER = 30

# source_type values from SourceAsset / production plan
SOURCE_TYPE_VOWEL = "vowel"
SOURCE_TYPE_CONTINUANT = "continuant"
SOURCE_TYPE_TRANSITION = "transition"
SOURCE_TYPE_BREATH = "breath"
SOURCE_TYPE_TRANSIENT = "transient"

PHASE1_SOURCE_TYPE_COUNTS = {
    SOURCE_TYPE_VOWEL: 28,
    SOURCE_TYPE_CONTINUANT: 32,
    SOURCE_TYPE_TRANSITION: 40,
}
PHASE1_BREATH_TRANSIENT_COMBINED = 20

RECOGNITION_RISK_VALUES = frozenset({"low", "medium", "high"})

# Canonical source-master WAV requirements (strict Phase 1)
REQUIRED_SAMPLE_RATE = 48_000
REQUIRED_SAMPLE_WIDTH_BYTES = 3  # 24-bit
REQUIRED_CHANNELS = 1

# Metadata duration tolerance: max(50 ms, 2% of declared duration)
DURATION_TOLERANCE_MIN_MS = 50
DURATION_TOLERANCE_PCT = 0.02

# Advisory duration ranges (ms) — production QC warnings, not hard rejects
DURATION_ADVISORY_MS = {
    SOURCE_TYPE_VOWEL: (500, 900),
    SOURCE_TYPE_CONTINUANT: (500, 900),
    SOURCE_TYPE_TRANSITION: (250, 450),
    SOURCE_TYPE_BREATH: (250, 800),
    SOURCE_TYPE_TRANSIENT: (150, 300),
}

# Rights ledger required shipping values
RIGHTS_REQUIRED_YES = frozenset(
    {
        "commercial_use",
        "mobile_app_embedding",
        "modification",
        "derivative_audio",
        "worldwide",
        "perpetual",
        "royalty_free",
        "marketing_use",
        "future_versions",
        "end_user_session_recording_use",
        "store_distribution_sublicense",
    }
)
RIGHTS_REQUIRED_NO = frozenset({"ai_training_permitted", "voice_cloning_permitted"})
RIGHTS_STATUS_APPROVED = "APPROVED"
RIGHTS_STATUS_HOLD = "HOLD"

AUDIO_GATE_STATUS = "NOT YET RUN — REQUIRES HUMAN PHYSICAL-DEVICE LISTENING TEST"

IGNORED_CORPUS_FILES = frozenset({"manifest.json", ".DS_Store"})
