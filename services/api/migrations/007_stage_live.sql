-- Stage live: track the relay's save job so withdraw can stop exactly it.
ALTER TABLE recordings ADD COLUMN IF NOT EXISTS egress_id TEXT;
