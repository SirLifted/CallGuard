# Stage B exit check — backend basics
- [x] 003 migration: rate_limits table, uniform `search_users()` (block-filtered, max 10), `is_blocked()` helper, RLS on
- [x] blocks function stub (both-ways wall + JWT TODO marked)
- [x] user-search function stub (30/min, identical 404 miss, JWT TODO marked)
- [x] Free CI (`.github/workflows/ci.yml`): tokens check + flutter analyze + deno check + migrations on Postgres 15
- [ ] Live Supabase project wiring (needs your dashboard: create project, run migrations, set Edge Function secrets) — Stage B env task
- [ ] `deno check` locally (no Deno/Node on this PC; CI covers it until you install Deno)
