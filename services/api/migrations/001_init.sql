-- CallGuard MVP schema v1 (Postgres)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_hash TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL,
  push_token TEXT,
  last_seen TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE blocks (
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);

CREATE TABLE calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_by UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'ringing',
  started_at TIMESTAMPTZ DEFAULT now(),
  ended_at TIMESTAMPTZ
);

CREATE TABLE call_participants (
  call_id UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),
  left_at TIMESTAMPTZ,
  PRIMARY KEY (call_id, user_id)
);

CREATE TABLE recording_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_id UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
  requester_id UUID NOT NULL REFERENCES users(id),
  participant_id UUID NOT NULL REFERENCES users(id),
  purpose TEXT NOT NULL,
  duration_sec INT NOT NULL CHECK (duration_sec > 0 AND duration_sec <= 7200),
  quality TEXT NOT NULL DEFAULT '720p',
  scope_audio BOOLEAN NOT NULL DEFAULT true,
  scope_video BOOLEAN NOT NULL DEFAULT true,
  status TEXT NOT NULL DEFAULT 'REQUESTED',
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES recording_requests(id) ON DELETE CASCADE,
  decider_id UUID NOT NULL REFERENCES users(id),
  decision TEXT NOT NULL,
  decided_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE recordings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_id UUID NOT NULL REFERENCES calls(id),
  request_id UUID NOT NULL REFERENCES recording_requests(id),
  sfu_room TEXT NOT NULL,
  s3_key TEXT NOT NULL,
  dek_id TEXT NOT NULL,
  quality TEXT NOT NULL,
  duration_sec INT NOT NULL,
  status TEXT NOT NULL DEFAULT 'APPROVED',
  content_sha256 TEXT,
  delete_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX ON recordings (status, delete_at);

CREATE TABLE audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recording_id UUID REFERENCES recordings(id) ON DELETE SET NULL,
  call_id UUID REFERENCES calls(id) ON DELETE SET NULL,
  actor_hash TEXT NOT NULL,
  event TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  prev_hash TEXT NOT NULL DEFAULT 'GENESIS',
  hash TEXT NOT NULL
);
CREATE INDEX ON audit_events (recording_id, created_at);
-- No UPDATE/DELETE grants to app role (enforce in migration privileges).

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'queued',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
