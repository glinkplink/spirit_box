# Pass C — cooldown relaxation (owner-gated only)

**Status:** flagged, not implemented

Relaxing `speakerCooldown(2)` in `SweepScheduler.swift` (or `fragmentCooldown` / `utteranceCooldown`)
to allow same-performer bursts on adjacent vocal slots conflicts with canonical §6.2 and is
enforced by `tools/check_sweep_render.py`.

**Do not implement without explicit product-owner approval.**

If Pass A and Pass B candidates still lack adjacent-slot performer continuity after human
listening review, stop and request a product decision rather than tuning cooldowns as a
renderer trick.
