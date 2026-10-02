# ADR-001 — Stack v2 cheap-first (MVP, frozen, supersedes v1)

- Mobile: Flutter stable (free). State: Riverpod. Nav: go_router with auth guard + call overlay.
- Backend: Supabase free tier (Postgres + Auth + Vault) + Edge Functions for referee logic. Upstash Redis free tier for ticket revocation + rate limits. 1 Hetzner VPS (~$5.50/mo) runs LiveKit self-hosted + Uptime Kuma. No NestJS server, no AWS bills in MVP.
- Storage: Cloudflare R2 (10GB free, $0 egress) for videos. Signed 5-min play links, per-video key in Supabase Vault (free), rotation via cron. No S3, no AWS KMS.
- Realtime: LiveKit self-hosted SFU. Room per call `call_<uuid>`. Server-side save only with valid `recording_auth_jwt`. LiveKit Cloud free tier for dev only.
- Auth v2: email magic-link OTP first via Supabase Auth (free 50k MAU). Access 15min, refresh rotating 30d, Redis revocation, device binding. Phone SMS OTP deferred to post-MVP (SMS costs per message). DB: `phone_hash` nullable, add `email_hash UNIQUE`.
- Design: Penpot free (or Figma free tier). Monitoring: Sentry free + Grafana Cloud free + Uptime Kuma free. CI: GitHub Actions free. DNS/TLS: Cloudflare free.
- Rejected: P2P mesh (cannot enforce stop), phone-SMS-first (cost), S3 egress fees, AWS KMS, Twilio/Chime per-minute, E2EE MVP, WhatsApp/Messenger interception.

# ADR-002 — Recording enforcement

- JWT claims: `call_id, request_id, participants[], scope{audio,video}, quality, duration_sec, exp(5min), jti`.
- SFU validates JWT on StartRecording; withdraw/expiry revokes `jti` in Redis and stops egress <=2s.
- No local MediaRecorder path. OS capture = deterrence only.
