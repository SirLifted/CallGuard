# CallGuard — Detailed Implementation Plan (Phased)

**Source of truth companion to:** `CallGuard_Android_iOS_Development_Roadmap.md`
**Status:** Planning — no runnable app yet
**Fixed MVP decisions (do not revisit without ADR):**
- Cross-platform: Flutter (single codebase, one product two platforms)
- Calls: WebRTC via SFU, server-side recording authoritative (LiveKit recommended; alt: Chime SDK / Twilio / Daily). P2P rejected.
- Auth: phone-number OTP primary (Firebase Auth or Cognito). No email/password MVP.
- Consent: backend-issued short-lived `recording_auth_jwt`, SFU-validated. Clients never record locally.
- Encryption: TLS + DTLS-SRTP in transit, SSE-KMS per-recording DEK at rest. No E2EE in MVP (server is trusted recorder).
- Guarantee scope: in-app/server recording only. OS capture = deterrence (FLAG_SECURE, isCaptured, watermark) + audit, not prevention.
- SLOs: setup p95 3s Wi-Fi / 5s 4G, crash-free >99.5%, push p95 <5s, recording success >99%, API p95 <300ms, history available p95 <60s.
- WhatsApp/Messenger interception: explicit non-goal.

---

## STAGE T0 — Product Technical Design System

**Goal:** developers can reproduce identical UI on Android/iOS from tokens, no hard-coding.
**Inputs:** roadmap PHASE 4-5. **Output:** `design/` + tokens file.

### T0.1 Tokens (versioned JSON)
- Colors: `primary, secondary, background, surface, textPrimary, textSecondary, error, warning, success, recordingAlert` with light/dark values + contrast ratios.
- Typography: font family (1 family + fallback), scale H1-H3 / body / button / caption, line-height, weight. Min body 14sp, dynamic-type support.
- Spacing/radius/elevation: 4pt grid, radius sm/md/lg, elevation levels.
- Motion: durations 150/250ms, easing standard.
- Deliverable: `design/tokens.json` + generated Flutter `AppTokens` class. CI check fails on raw hex outside tokens.

### T0.2 Components (single spec, Flutter implements once)
Buttons (primary/secondary/destructive/ghost), text fields + OTP input, cards, bottom sheets, dialogs (recording request/approve/withdraw/extend/delete), toggles, tabs, nav bar, call controls, recording indicator (`🔴 RECORDING + timer`, never color-only), toasts, in-app notification banner, empty/error/offline states.
- Each component: anatomy, states (default/pressed/disabled/loading), a11y label, min touch target 48dp.
- Deliverable: Figma + `design/components.md` + Flutter widgetbook/storybook.

### T0.3 Screens (30 screens from roadmap §4)
Splash, onboarding, registration (phone), OTP, login, home, search/contacts, profile, incoming/outgoing/active call, recording request/approval/active/extension/ending/ended, history/details/delete-confirm, privacy/notification/security/blocked/report/account/help, error/offline.
- Each screen: layout, every button/action, validation, error copy, permission trigger point.
- Acceptance: side-by-side Android/iOS screenshot diff = identical except OS chrome.

**Exit criteria:** tokens frozen v1, component checklist signed, Figma prototype clickable for MVP journey.

---

## STAGE T1 — Architecture Design (must freeze before code)

### T1.1 Mobile architecture
- Flutter stable, Dart. State: Riverpod/Bloc (pick one, document). Nav: go_router with auth guard + call overlay route.
- Layers: `presentation / application (use-cases) / domain / data (repos + DTOs) / core (tokens, logging, config)`.
- Native bridges: CallKit + PushKit (iOS), Telecom ConnectionService + FCM high-priority (Android), camera/mic permission handlers, `FLAG_SECURE` (Android), `isCaptured` listener (iOS).
- Repo layout: `apps/mobile/lib/...`, `packages/tokens/`, `packages/api_client/`.

### T1.2 Backend architecture
- API: NestJS (Node) or equivalent, REST for CRUD + WebSocket for signaling (LiveKit handles media). Postgres (primary), Redis (presence, rate-limit, JWT revocation), S3-compatible (recordings), KMS (keys).
- Services: auth, users, calls, consent/recording-controller, notifications, storage, audit (append-only), admin/monitoring.
- Environments: dev → staging → prod, IaC (Terraform), secrets in manager (never in repo), CI/CD (lint + test + build + migrate).

### T1.3 Data model (migrations v1)
- `users(id UUID, phone_hash, display_name, avatar_url, status, created_at)`
- `devices(id, user_id, platform, push_token, last_seen)`
- `blocks(blocker_id, blocked_id, created_at)`
- `calls(id, created_by, status, started_at, ended_at)`
- `call_participants(call_id, user_id, joined_at, left_at)`
- `recording_requests(id, call_id, requester_id, participant_id, purpose, duration_sec, quality, scope_audio, scope_video, status, expires_at)`
- `consents(id, request_id, decider_id, decision, decided_at)`
- `recordings(id, call_id, request_id, sfu_room, s3_key, dek_id, quality, duration_sec, status[REQUESTED|APPROVED|STARTED|STOPPED|EXPIRED|CONSENT_WITHDRAWN|FAILED|CANCELLED], content_sha256, delete_at)`
- `audit_events(id, recording_id, call_id, actor_hash, event, timestamp, prev_hash, hash)` — no UPDATE/DELETE grants.
- `notifications(id, user_id, type, payload, status, created_at)`
- Indexes on `calls(created_by)`, `recordings(delete_at,status)`, `audit_events(recording_id,timestamp)`.

### T1.4 API + JWT contracts
- Auth: `POST /auth/otp/request|verify|refresh|logout|logout-all`
- Users: `GET/PATCH /users/me`, `GET /users/search?q=` (rate-limited, uniform 404), `POST/DELETE /blocks`
- Calls: `POST /calls`, `POST /calls/:id/accept|decline|leave`
- Consent: `POST /calls/:id/recording-requests`, `POST /recording-requests/:id/approve|decline`, `POST /recordings/:id/withdraw`, `POST /recordings/:id/extension-requests`, `POST /extension-requests/:id/approve|decline`
- Recordings: `GET /recordings`, `GET /recordings/:id`, `GET /recordings/:id/playback-url` (5-min signed URL after authz), `DELETE /recordings/:id`
- `recording_auth_jwt = {call_id, request_id, participants[], scope, quality, duration, exp(5min), jti}`. SFU webhook `onStartRecording` must present valid non-revoked JWT. Revocation list in Redis on withdraw/expiry.

### T1.5 Realtime + recording + notifications
- LiveKit room per call (`call_<uuid>`), SFU egress to S3 on valid JWT only. Stop egress within 2s of withdraw/expiry webhook. Timer enforced server-side, not client countdown.
- Push: FCM (Android, high-priority + full-screen intent) + APNs PushKit (iOS CallKit). Fallback in-app socket event. Types: incoming-call, recording-request/approved/declined/started/ending/ended, extension-request, consent-withdrawn.
- Storage: `s3://callguard-recordings/<env>/<recording_id>.mp4` + `.json` metadata. Lifecycle rule deletes on `delete_at`. Signed URLs 5min, authz-checked per request, every access audit-logged.

### T1.6 Security + privacy + observability
- Rate limits: OTP 5/10min, search 30/min, recording-request 10/call + 20/day per pair, playback-url 60/min.
- Abuse: block/report workflow, spam detection, admin review queue.
- Logging: structured JSON, PII redaction, audit separate from app logs. Metrics: SLO dashboards + alerts (setup time, crash rate, recording success, consent errors, unauthorized attempts). Tracing on consent endpoints.

**Exit criteria:** ADRs signed for Flutter/LiveKit/Postgres, ERD + OpenAPI + JWT claims merged, IaC plan approved, store-gate validated.

---

## STAGE B — Backend Foundation (roadmap PHASE 7)
1. Auth OTP + sessions + device binding + tests.
2. Users/blocks/search with anti-enumeration + tests.
3. Migrations + seed + CI pipeline.
- Acceptance: register → OTP → search → block flows via API tests; no existence oracle.

## STAGE C — Calling (PHASE 8-10)
1. Signaling + LiveKit rooms + CallKit/ConnectionService integration.
2. Flutter call UI (outgoing/incoming/active) + camera/mic/speaker/switch/mute.
3. Network adaptation, reconnect, background/foreground handling.
- Acceptance: 2 test accounts stable on Android↔Android, iOS↔iOS, cross-platform on Wi-Fi/4G/weak/switch.

## STAGE D — Privacy Core (PHASE 11-14)
1. Request → approve/decline → JWT issuance.
2. SFU start/stop + timer + quality/duration enforcement + indicator.
3. Extension (re-consent only) + withdrawal (2s stop + revoke + notify + audit).
- Acceptance: no-JWT start rejected; expired JWT stops; double-request/simultaneous-request handled; withdrawal stops ≤2s (server clock).

## STAGE E — Recording Management (PHASE 15-16,19)
1. S3 upload + metadata + history/details + playback-url authz.
2. Retention scheduler (24h/7d/30d/90d/custom/manual), URL revocation, audit retention (12mo example).
3. Append-only audit + hash-chain verifier job.
- Acceptance: expired content unreachable (403 on old URL), audit survives content delete, hash-chain passes.

## STAGE F — Trust: Notifications, Hardening, Abuse, Edge Cases (PHASE 17-18,20-21)
- Push + in-app parity, auth hardening, KMS rotation, API authz tests, block/rate-limit/abuse queue.
- Edge matrix: disconnect, network loss, crash, restart, leave, background, SFU/storage/notify failure, expired/duplicate/simultaneous/invalid-auth/unsupported-quality — backend authoritative in each.
- Acceptance: malicious client cannot start/access without JWT (pen-test gate).

## STAGE Q — Quality (PHASE 22-26)
- Unit (consent machine, durations, retention), integration (auth→call→consent→record→store→notify), e2e script from roadmap §39.
- Cross-platform screenshot + behavior diff, a11y (screen reader, contrast, 48dp, non-color status), SLO load test.
- Security test: bypass, token replay, URL sharing, storage direct-access, spam.
- Acceptance: SLOs met, zero critical/high vulns open.

## STAGE R — Release (PHASE 27-33)
1. Closed beta (100-500 users), triage order: privacy > security > call reliability > recording reliability > usability.
2. Readiness: prod env, backups verified, runbooks, Privacy Policy/ToS/deletion process, incident response.
3. Store prep + RC (regression + store + privacy review) → staged rollout Android then iOS → monitor crash/call/record/consent/server dashboards.
- Acceptance: RC has only low-risk opens; rollback plan tested.

## STAGE G — Growth (PHASE 34-37, post-MVP only)
Group calls + group consent, screen-share consent, audio-only, secure sharing, watermark admin, orgs/RBAC/billing, AI transcription (with explicit opt-in + retention disclosure). No WhatsApp/Messenger interception.

---

## Build order + repo map
`design/tokens.json` → `openapi.yaml` + migrations → `apps/mobile` + `services/api` + `infra/` → LiveKit → consent/recording → storage/audit → hardening → beta → launch.
Proposed repo: `apps/mobile/`, `services/api/`, `packages/api_client/`, `packages/tokens/`, `infra/`, `design/`, `docs/` (this plan + ADRs + QA matrix).

## Definition of done (MVP)
Roadmap §39 journey passes on all 4 device pairs, SLOs met, audit hash-chain green, store disclosures approved, deletion verified, no bypass.
