# Post-MVP: AI features (design outline, consent-gated)

## Opt-in contract (shown before enabling, per recording)
What (transcript/summary/action items) · why (who asked) · where (on-device vs cloud + region) ·
how long (transcript inherits the recording's delete date, never longer) · who (same viewers as the video).

## Cheap-first options (decide at build time)
- On-device Whisper (tiny/base) for short clips: $0, private, slower, needs download + storage permission note.
- Cloud API free tier (e.g. Deepgram free credits) for long calls: faster, data leaves the device → must be
  explicit in the opt-in screen, region pinned, no training-on-your-data clause.
- Speaker labels + searchable text + highlights come free with either once transcripts exist.

## Rules
- No AI without a fresh YES covering that recording (call consent ≠ AI consent).
- AI outputs die with the recording (same `delete_at`, same sweep).
- Never WhatsApp/Messenger — no change here.
