-- v2 cheap-first: email OTP first, phone later. Appends to 001_init.sql, never edits it.
ALTER TABLE users ALTER COLUMN phone_hash DROP NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_hash TEXT UNIQUE;
-- Backfill hint: existing rows keep phone_hash; new email users set email_hash, phone_hash NULL.
