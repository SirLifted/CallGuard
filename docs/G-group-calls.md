# Post-MVP: group calls (design outline, no code until MVP stable)

## Consent rule for groups
- Recording needs a YES from EVERY participant (all-party, same as 1-to-1). One decline = no recording.
- Any participant's withdraw stops the whole save within 2s (same as 1-to-1). No per-person tracks in MVP
  (per-person saves multiply storage, consent states, and audit complexity — revisit with usage data).
- Late joiners see `This call is being recorded (purpose, minutes left)` and must approve before
  their audio/video is included; until then they are view-only and unrecorded.

## Technical notes (for later)
- Same SFU room, egress mix stays one file; `recording_auth_jwt` gains `participants[]` (all must be listed).
- Extension needs all-party re-approval. Withdraw by anyone kills the ticket.
- Screen-share is a separate consent scope (`scope.screen`), asked like recording, same ticket pattern.
- Audio-only calls reuse the call flow with video publications disabled (cheaper egress — good for low data).

## Gate
See `docs/G-exit-check.md`. None of this starts before the gate is green.
