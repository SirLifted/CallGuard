# Stage C exit check — calling
- [x] call_service.dart: join/leave, mic/cam/speaker/switch, reconnect mirror, plain-language notes
- [x] Call screen wired to Riverpod (join needs server token — by design, no fake bypass)
- [x] calls function stub (room + token mint + push plan, block-check TODO marked)
- [ ] LiveKit join verified on real server (needs Stage C env: LiveKit up + 2 test accounts)
- [ ] CallKit (iOS) + ConnectionService (Android) native bridges (needs native shells)
- [ ] `deno check` on calls function (CI covers it; no Deno on this PC)
