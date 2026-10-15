-- Stage profile gate: who the user is, before Home.
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS middle_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS dob DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_complete BOOLEAN NOT NULL DEFAULT false;

-- The app (logged-in user) may read/write ONLY its own row. No policies existed, so
-- RLS was denying everything; these open exactly the user's own record.
DROP POLICY IF EXISTS users_self_read ON users;
CREATE POLICY users_self_read ON users FOR SELECT USING (auth.uid() = id);
DROP POLICY IF EXISTS users_self_insert ON users;
CREATE POLICY users_self_insert ON users FOR INSERT WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS users_self_update ON users;
CREATE POLICY users_self_update ON users FOR UPDATE USING (auth.uid() = id);
