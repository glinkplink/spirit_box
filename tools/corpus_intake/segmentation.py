"""Silence-based segmentation helpers for corpus intake (stdlib only)."""

from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass(frozen=True)
class SilenceInterval:
    start_sec: float
    end_sec: float

    @property
    def duration_sec(self) -> float:
        return self.end_sec - self.start_sec


@dataclass(frozen=True)
class VocalRegion:
    start_sec: float
    end_sec: float
    index: int

    @property
    def duration_sec(self) -> float:
        return self.end_sec - self.start_sec


_SILENCE_START_RE = re.compile(r"silence_start:\s*([\d.]+)")
_SILENCE_END_RE = re.compile(r"silence_end:\s*([\d.]+)")


def parse_silencedetect_output(stderr_text: str) -> list[SilenceInterval]:
    """Parse ffmpeg silencedetect lines into completed silence intervals."""
    intervals: list[SilenceInterval] = []
    pending_start: float | None = None

    for line in stderr_text.splitlines():
        start_match = _SILENCE_START_RE.search(line)
        if start_match:
            pending_start = float(start_match.group(1))
            continue

        end_match = _SILENCE_END_RE.search(line)
        if end_match and pending_start is not None:
            end_sec = float(end_match.group(1))
            if end_sec > pending_start:
                intervals.append(SilenceInterval(pending_start, end_sec))
            pending_start = None

    return intervals


def merge_adjacent_silences(
    silences: list[SilenceInterval],
    *,
    max_gap_sec: float,
) -> list[SilenceInterval]:
    """Merge silence intervals separated by tiny gaps (silencedetect artifacts)."""
    if not silences:
        return []

    merged: list[SilenceInterval] = [silences[0]]
    for current in silences[1:]:
        previous = merged[-1]
        if current.start_sec - previous.end_sec < max_gap_sec:
            merged[-1] = SilenceInterval(previous.start_sec, max(previous.end_sec, current.end_sec))
        else:
            merged.append(current)
    return merged


def vocal_regions_from_silences(
    silences: list[SilenceInterval],
    *,
    total_duration_sec: float,
) -> list[VocalRegion]:
    """Build vocal regions as gaps between merged silence intervals."""
    if total_duration_sec <= 0:
        return []

    regions: list[VocalRegion] = []
    cursor = 0.0
    index = 1

    for silence in silences:
        if silence.start_sec > cursor:
            regions.append(
                VocalRegion(
                    start_sec=cursor,
                    end_sec=min(total_duration_sec, silence.start_sec),
                    index=index,
                )
            )
            index += 1
        cursor = max(cursor, silence.end_sec)

    if cursor < total_duration_sec:
        regions.append(
            VocalRegion(
                start_sec=cursor,
                end_sec=total_duration_sec,
                index=index,
            )
        )

    return regions
