-- Stage E: saving + history + notebook. Appends to 001-004, never edits them.
-- Plain language: remember when saving stopped, allow shredding bytes while keeping the log entry,
-- and a checker that proves nobody rewrote the notebook.

ALTER TABLE recordings ADD COLUMN IF NOT EXISTS stopped_at TIMESTAMPTZ;
ALTER TABLE recordings ADD COLUMN IF NOT EXISTS media_deleted_at TIMESTAMPTZ;
ALTER TABLE recordings ALTER COLUMN s3_key DROP NOT NULL;

-- Hash-chain verifier: each audit row's hash must equal sha256(prev_hash || event || id).
-- Run hourly (cron). Any mismatch → page on-call, freeze deletions until reviewed.
CREATE OR REPLACE FUNCTION verify_audit_chain()
RETURNS TABLE (bad_id UUID, expected TEXT, actual TEXT) AS $$
  SELECT a.id,
         encode(digest(coalesce(a.prev_hash,'') || a.event || a.id::text, 'sha256'), 'hex'),
         a.hash
  FROM audit_events a
  WHERE a.hash <> encode(digest(coalesce(a.prev_hash,'') || a.event || a.id::text, 'sha256'), 'hex')
  LIMIT 100;
$$ LANGUAGE sql STABLE;

-- Playback rule helper: watchable only if stopped, not expired, bytes still present.
CREATE OR REPLACE FUNCTION is_watchable(r recordings)
RETURNS BOOLEAN AS $$
  SELECT r.status = 'STOPPED'
     AND r.media_deleted_at IS NULL
     AND r.delete_at > now();
$$ LANGUAGE sql STABLE;
