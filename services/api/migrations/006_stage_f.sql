-- Stage F: trust. Appends to 001-005, never edits them.
-- Plain language: a complaints desk (abuse reports) and a lock-change log (key rotation).

CREATE TABLE IF NOT EXISTS abuse_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reported_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_abuse_reports_status_created ON abuse_reports (status, created_at);

-- Lock-change log: every per-video key version lives in Vault; this table says when it changed.
-- Rotation job (monthly): new KEK version in Vault, re-wrap DEKs, insert row. Old KEK kept read-only
-- until no recording references it (checked via dek_id prefix), then destroyed.
CREATE TABLE IF NOT EXISTS key_rotations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kek_version TEXT NOT NULL,
  rotated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  note TEXT NOT NULL DEFAULT ''
);
