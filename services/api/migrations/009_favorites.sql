-- Saved contacts (favorites). The app's own address book: works on web, PC, and phone.
-- Phone-OS contacts import (Android permission) is a later client task; this table is the source of truth.
CREATE TABLE IF NOT EXISTS favorites (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  fav_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, fav_user_id),
  CHECK (user_id <> fav_user_id)
);

DROP POLICY IF EXISTS favorites_self_all ON favorites;
CREATE POLICY favorites_self_all ON favorites
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
