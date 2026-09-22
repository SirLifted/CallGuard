# CallGuard — Privacy-Controlled Video Calling

CallGuard is a privacy-first video-calling app for Android and iOS with the same product, appearance, and behaviour on both platforms.

Core idea: **no recording without explicit, backend-enforced consent.**

```
Inform → Ask → Authorize → Record → Monitor → Stop → Store securely → Delete by policy
```

## Key features (MVP)

- 1-to-1 video calls (Android ↔ Android, iOS ↔ iOS, cross-platform)
- Recording request with purpose, duration, quality, audio/video scope
- Approve / decline flow, enforced by the backend — clients cannot bypass it
- Visible recording indicator + timer, duration/quality enforcement
- Consent withdrawal that stops recording (server-authoritative)
- Controlled recording extension (re-consent required, no silent extension)
- Secure recording history, details, authorized-only access (no public URLs)
- Retention policies: 24h / 7d / 30d / 90d / custom / manual + auto-delete
- Tamper-resistant audit trail (requested, approved, declined, started, stopped, withdrawn, extended, deleted, accessed)
- Push + in-app notifications for calls and recording events
- Block / report, rate-limiting, abuse prevention
- Accessibility: recording status never colour-only (e.g. `🔴 RECORDING`)

## MVP journey

```
Register → Find user → Call → Request recording (purpose/duration/quality)
→ Participant reviews → Approves → Recording starts (indicator + timer)
→ Withdraw consent possible → Stop → History → Authorized access → Auto-delete → Audit retained per policy
```

## Principles

1. One product, two platforms — minimal OS-only differences
2. Shared spec for Android + iOS, not a port
3. Privacy by design, backend-enforced security
4. MVP before group calls, AI, integrations, enterprise
5. No bypassing WhatsApp / Messenger / Android / iOS restrictions — only official APIs

## Repo status

Early planning stage. Current source of truth:

- `CallGuard_Android_iOS_Development_Roadmap.md` — full 37-phase roadmap from validation to launch + V2/AI/integrations

Next technical decisions (not yet fixed): cross-platform stack (Flutter / React Native / KMP), WebRTC topology (P2P vs SFU for enforceable server-side recording), E2EE vs server-visible media, auth method (phone/email/passwordless + OTP), cloud/storage/DB choice.

## Roadmap summary

1. Foundation: requirements, architecture, UX/UI, design system, environments
2. Backend: auth, users, DB, API, notifications
3. Calling: signalling, WebRTC video/audio, lifecycle, network recovery
4. Privacy core: request, consent, authorization, indicator, timer, enforcement, withdrawal, extension
5. Recording management: storage, history, access control, deletion/retention, audit
6. Security: auth hardening, API authz, storage security, abuse prevention
7. Quality: unit/integration/e2e, Android/iOS/cross-platform testing, security testing
8. Release: beta, store prep (Play + App Store), RC, launch, monitoring, maintenance
9. Post-MVP: group calls, AI transcription/summaries, official third-party integrations, enterprise

See the roadmap file for phases, acceptance criteria, and store/launch checklists.

## Getting started

No runnable app yet. To work on the next spec:

1. Read the roadmap file
2. Define: stack, DB schema, API spec, auth, WebRTC/recording architecture, infra, screen-by-screen UX
3. Build backend → calling → consent/recording → hardening → beta → launch (in that order)
