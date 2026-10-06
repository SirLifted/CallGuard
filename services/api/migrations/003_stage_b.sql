-- Stage B: backend basics. Appends to 001/002, never edits them.
-- Plain language: login counters (stop guessing), private search (no hints to strangers), block rules.

CREATE TABLE IF NOT EXISTS rate_limits (
  key TEXT PRIMARY KEY,
  count INT NOT NULL DEFAULT 0,
  window_start TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Uniform user search: same shape whether the person exists, is blocked, or is missing.
-- The app must show identical "Not found" for all three, so strangers can't probe who uses CallGuard.
CREATE OR REPLACE FUNCTION search_users(searcher_id UUID, q TEXT)
RETURNS TABLE (id UUID, display_name TEXT, avatar_url TEXT) AS $$
  SELECT u.id, u.display_name, u.avatar_url
  FROM users u
  WHERE (u.email_hash = lower(trim(q)) OR u.display_name ILIKE '%' || trim(q) || '%')
    AND u.status = 'active'
    AND NOT EXISTS (
      SELECT 1 FROM blocks b
      WHERE (b.blocker_id = searcher_id AND b.blocked_id = u.id)
         OR (b.blocker_id = u.id AND b.blocked_id = searcher_id)
    )
  LIMIT 10;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Block check helper: true if either side blocked the other (suppress calls + requests + popups both ways).
CREATE OR REPLACE FUNCTION is_blocked(a UUID, b UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM blocks
    WHERE (blocker_id = a AND blocked_id = b) OR (blocker_id = b AND blocked_id = a)
  );
$$ LANGUAGE sql STABLE;

-- Row-level security on (dev default-deny; service role bypasses for Edge Functions).
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE rate_limits ENABLE ROW LEVEL SECURITY;
