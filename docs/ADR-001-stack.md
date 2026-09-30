# ADR-001 — Stack (MVP, frozen)

- Mobile: Flutter stable. State: Riverpod. Nav: go_router with auth guard + call overlay.
- Backend: NestJS (REST + WebSocket signaling), Postgres 15, Redis 7, S3-compatible + KMS.
- Realtime: LiveKit SFU. Room per call `call_<uuid>`. Server-side egress only with valid `recording_auth_jwt`.
- Auth: Firebase Auth or Cognito phone OTP. Access 15min, refresh rotating 30d, Redis revocation, device binding.
- Rejected: P2P mesh (cannot enforce stop), email/password MVP, E2EE MVP, WhatsApp/Messenger interception.

# ADR-002 — Recording enforcement

- JWT claims: `call_id, request_id, participants[], scope{audio,video}, quality, duration_sec, exp(5min), jti`.
- SFU validates JWT on StartRecording; withdraw/expiry revokes `jti` in Redis and stops egress <=2s.
- No local MediaRecorder path. OS capture = deterrence only.
