-- Stage D: privacy-core enforcement. Appends to 001/002/003, never edits them.
-- Plain language: the database itself refuses illegal moves (double-approve, approve-after-stop).

ALTER TABLE recordings ADD COLUMN IF NOT EXISTS auth_jti TEXT;
ALTER TABLE recordings ADD COLUMN IF NOT EXISTS ticket_expires_at TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION assert_recording_transition()
RETURNS TRIGGER AS $$
DECLARE
  allowed TEXT[];
BEGIN
  -- Mirror of the ALLOWED map in consent-ticket/index.ts. Keep both in sync.
  CASE OLD.status
    WHEN 'REQUESTED' THEN allowed := ARRAY['APPROVED','DECLINED','CANCELLED'];
    WHEN 'APPROVED' THEN allowed := ARRAY['STARTED','CANCELLED'];
    WHEN 'STARTED' THEN allowed := ARRAY['STOPPED','EXPIRED','CONSENT_WITHDRAWN','FAILED'];
    ELSE allowed := ARRAY[]::TEXT[]; -- terminal states never move
  END CASE;
  IF NOT (NEW.status = ANY (allowed)) THEN
    RAISE EXCEPTION 'Illegal recording transition % -> %', OLD.status, NEW.status;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_recording_transition ON recordings;
CREATE TRIGGER trg_recording_transition
  BEFORE UPDATE OF status ON recordings
  FOR EACH ROW EXECUTE FUNCTION assert_recording_transition();
