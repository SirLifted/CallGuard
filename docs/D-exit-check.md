# Stage D exit check — privacy core
- [x] consent-ticket upgraded: transition map (double-approve/approve-after-stop rejected), jose JWT, jti plan
- [x] recording-withdraw stub (revoke jti → stop egress ≤2s → notify both → audit, identical 404s)
- [x] recording-extension stub (fresh approval mints fresh ticket; decline keeps old stop time)
- [x] 004 migration: auth_jti + ticket_expires_at + transition trigger (DB refuses illegal moves)
- [x] ApiClient: requestRecording / requestExtension / approveExtension added
- [x] recording_service.dart: server-owned countdown + indicator label (text + timer, never color alone)
- [ ] Live withdraw-timing test on real server (needs Stage D env: LiveKit + Upstash + 2 accounts)
- [ ] `deno check` on new functions (CI covers it; no Deno on this PC)
