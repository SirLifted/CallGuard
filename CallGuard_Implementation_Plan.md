# CallGuard — Implementation Plan v2 (cheap-first, plain language)

**Same file, new version.** v1 was correct but used expensive tools. v2 does the same job for almost $0.
**Companion to:** `CallGuard_Android_iOS_Development_Roadmap.md`
**Status:** Planning — no runnable app yet.

## Plain-language glossary (read this first)

- **App (Flutter):** one code base builds both Android and iOS apps. Free.
- **Backend / API:** small server that checks who you are and who allowed recording. Think of it as the referee.
- **Database (Postgres):** tables that store users, calls, consents. We use Supabase free tier to host it.
- **SFU / LiveKit:** video relay room. Your video goes to this relay, the relay sends it to the other person and saves a copy only if allowed. Self-hosted = we run it on a cheap $5 server instead of paying per minute to Twilio.
- **JWT (recording ticket):** short-lived permission slip, e.g. 5 minutes. No valid ticket = no recording. Checked by the relay.
- **Egress:** moving video out of the relay to storage. Paid services charge per minute for this. Self-hosting + R2 avoids it.
- **Storage (R2):** hard drive in the cloud for saved videos. Cloudflare R2 is used because downloads cost $0 (S3 charges for downloads).
- **Push (FCM/APNs):** free popups for incoming calls. Apple CallKit + Android ConnectionService make them look like real phone calls.
- **Audit log:** tamper-proof notebook of who allowed what, without storing video itself.

## What changed from v1 and why (cost savers)

| v1 (works but pricey) | v2 cheap replacement | Saving | Quality kept how |
|---|---|---|---|
| Phone SMS OTP first (Firebase/Cognito) | Email magic-link OTP first via Supabase Auth (free 50k users). Add phone SMS later only if needed | Saves ~$0.02 per SMS, ~$50–200 in testing | Same session + device binding, rate limits, OTP expiry. Phone can be added without DB change (`phone_hash` nullable) |
| AWS S3 + AWS KMS | Cloudflare R2 (10GB free, $0 download fees) + Supabase Vault free + SOPS/age for secrets | Saves egress (~$0.09/GB on S3) + $1/key/mo KMS | Same: per-video secret key, signed 5-min links, rotation |
| Managed Redis + separate backend host | Upstash Redis free tier (or same $5 server) + Supabase Edge Functions free + 1 cheap server for all | Saves $15–30/mo | Same revocation list, rate limits |
| LiveKit Cloud / Twilio / Chime per-minute | LiveKit self-hosted on 1 Hetzner VPS (~$5.50/mo, e.g. CX22). Use LiveKit Cloud free tier only for dev | Saves per-minute fees that explode with testing | Same 2-second stop enforcement, same JWT check |
| Datadog / paid monitoring, Figma paid | Sentry free (5k errors/mo) + Grafana Cloud free + Uptime Kuma free on same server. Penpot free (or Figma free tier) for design | Saves $20+/mo | Same SLO alerts, crash reports |
| Separate dev/staging/prod clouds | 1 server + free tiers: dev on laptop + Supabase free, staging on same $5 server (second LiveKit room), prod on same server to start, split only when full | Saves $50+/mo early | Same dev→staging→prod flow, just smaller machines |

**Expected bill:** $0 during build (laptop + free tiers). ~$5–10/mo for closed beta (1 Hetzner + R2 free + Supabase free + Cloudflare free). Split/upgrade only after 100–500 beta users.

## Fixed decisions v2 (do not change without ADR)

- App: Flutter free, Riverpod, go_router. One UI for both phones.
- Calls: LiveKit self-hosted. P2P rejected (server could not force stop).
- Auth v2: email OTP first. Phone SMS is Phase G add-on.
- Recording: server ticket (JWT 5 min), relay checks it, stops within 2 seconds of withdraw/expiry.
- Encryption: TLS + DTLS-SRTP in transit, R2 with per-video key at rest. No E2EE in MVP (server must be able to stop/save).
- Scope honesty: in-app recording is enforced. Phone screen-record or second camera cannot be blocked, only discouraged (secure flag, capture notice, watermark with user ID + time) + logged.
- Targets: call setup <3s Wi-Fi / <5s 4G, crash-free >99.5%, push <5s, recording success >99%, API <300ms, video in history <60s after stop.
- Never build WhatsApp/Messenger spying. Explicit non-goal.

---

## T0 — Look and feel (design system)

**Goal in one sentence:** both phones look identical without guessing colors.
**Cheap tool:** Penpot free (or Figma free tier) + `design/tokens.json` already in repo.
- T0.1 Tokens: 10 colors, 1 font family, sizes H1/H2/H3/body/button/caption, 4pt spacing, round corners 8/12/16, fast 150ms motion. One file generates `packages/tokens/app_tokens.dart`. CI fails if anyone hard-codes a color.
- T0.2 Parts: buttons, OTP box, cards, popups for request/approve/withdraw/extend/delete, call buttons, red `RECORDING + timer` label (never color alone), toasts, empty/error/offline pages. Each part lists looks + disabled/loading states + screen-reader name + 48dp finger size.
- T0.3 Screens (30 from roadmap): splash, onboarding, email register, OTP code, home, search, profile, incoming/outgoing/active call, 6 recording screens, history/details/delete-confirm, settings pages, error/offline.
- **Done when:** tokens v1 frozen, clickable demo of register → call → request → approve → record → withdraw → history works in design tool.

## T1 — Blueprint before code (architecture)

**Goal:** freeze choices so coding does not stop for debates.
**Cheap tools:** Supabase free (Postgres + Auth + Vault), Upstash free, R2 free, 1 Hetzner, Terraform free, GitHub Actions free.
- T1.1 App layout: `apps/mobile/lib` in layers (screens / logic / data). Bridges: CallKit+PushKit on iPhone, ConnectionService+FCM on Android, secure-flag + capture notice. Files already started: `design/`, `packages/tokens/`, `packages/api_client/` (to add).
- T1.2 Backend layout: Supabase Postgres (tables) + Edge Functions (referee logic: auth, calls, consent, storage links, audit) + Upstash (blocklist, ticket revocation). LiveKit on Hetzner. Dev on laptop, staging + prod as separate rooms/buckets on same box at first.
- T1.3 Tables v1: see `services/api/migrations/001_init.sql` (users, devices, blocks, calls, participants, recording_requests, consents, recordings, audit_events append-only with hash chain, notifications). Change for v2: `users.phone_hash` is now nullable (email first), add `users.email_hash UNIQUE`.
- T1.4 API + ticket: see `services/api/openapi.yaml`. Auth is now `email OTP request/verify/refresh/logout`. Ticket = `{call_id, request_id, who, audio/video, quality, minutes, expires, id}`. Relay refuses start without fresh ticket, stops on revoked ticket.
- T1.5 Video + storage + push: one LiveKit room per call `call_<id>`. Save to R2 only with ticket: `r2://callguard/<env>/<recording_id>.mp4` + `.json`. Auto-delete on `delete_at`. Play link lives 5 minutes, checks permission each time, every view logged. Push free via FCM/APNs + in-app fallback.
- T1.6 Safety + watch: limits (OTP 5/10min, search 30/min, request 10/call, link 60/min), block/report queue, JSON logs with phone/email hidden, free dashboards for the targets above, ticket endpoints traced.
- **Done when:** ADRs signed (`docs/ADR-001-stack.md` updated to v2), table + API files merged, server cost sheet approved, store gate checked (CallKit/ConnectionService + recording disclosure accepted).

## B — Backend basics

Build email OTP login, profiles, hashed search with no hints to strangers (same answer whether user exists or not), block (block stops calls + requests + popups both ways), tables + free CI. **Done when:** register → OTP → search → block passes on API tests.

## C — Calling

Signal + LiveKit room + full-screen call popup, Flutter call screen (mute, camera flip, speaker, hang up), reconnect on weak net/switch, background handling. **Done when:** 2 test accounts hold a stable call Android↔Android, iOS↔iOS, and cross on Wi-Fi/4G/weak/switch.

## D — Privacy core (most important)

Request (why + minutes + quality) → other side approves/declines → server hands 5-min ticket → relay records with red label + timer → extend needs new approval → withdraw kills ticket and stops save within 2 seconds + tells both + logs. **Done when:** no ticket = no save, expired ticket stops, double/simultaneous requests safe, withdraw ≤2s by server clock.

## E — Saving + history + notebook

Upload to R2 + details page + permission-checked play link, auto-delete choices 24h/7d/30d/90d/custom/manual (video + thumbnails gone, old links dead immediately), notebook keeps only metadata (ids, times, hash) ~12 months then gone, hash-chain checker job. **Done when:** expired video gives 403, notebook survives video delete, chain check green.

## F — Trust (popups, hardening, abuse, edge cases)

Same wording popups both phones, key rotation via Vault, permission tests, block + limits + review queue. Edge list each forced to server decision: drop, no net, crash, restart, leave, background, relay/storage/popup fail, expired/duplicate/double/invalid-ticket/bad-quality. **Done when:** hacked app without ticket cannot start or watch (pen-test gate).

## Q — Quality

Small tests (consent steps, minutes math, delete dates), chain tests (login→call→allow→save→store→popup), full walkthrough from roadmap §39, side-by-side phone screenshots, screen-reader/contrast/48dp/non-color checks, load test to SLOs, attack tests (replay ticket, share link, direct storage hit, spam). **Done when:** SLOs met, no critical/high security holes open.

## R — Trial release

100–500 testers, fix order: privacy > security > call drops > save fails > confusing UI. Checklist: backup restore tried, help + delete-account + incident steps written, Privacy Policy/ToS live, store forms honest about recording, release candidate has only tiny issues, rollback tried, Android first then iOS, watch crash/call/save/consent dashboards. **Done when:** RC clean, rollback works.

## G — Later only (after stable)

Group calls + group permission, screen-share permission, audio-only, safe sharing, company accounts/billing, AI text summaries only with clear opt-in (what/why/where/how long/who). Never WhatsApp/Messenger spying.

---

## Build order + folders

`design/tokens.json` → `openapi.yaml` + `001_init.sql` → `apps/mobile` + `services/api` (Edge Functions) + `infra/` → LiveKit on Hetzner → consent/ticket → R2/audit → hardening → trial → launch.
Folders: `apps/mobile/`, `services/api/`, `packages/api_client/`, `packages/tokens/`, `infra/`, `design/`, `docs/`.

## Done = MVP complete

Roadmap §39 walkthrough passes on all 4 phone pairs, SLOs met, audit chain green, store forms approved, deleted videos stay deleted, no bypass.
