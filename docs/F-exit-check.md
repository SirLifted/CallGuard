# Stage F exit check — trust
- [x] notify stub (fixed wording map, FCM/APNs + queued in-app fallback, blocked pairs never notified)
- [x] 006 migration: abuse_reports (open → reviewed queue) + key_rotations log
- [x] edge-matrix.md: 14 rows, backend authoritative in each
- [x] pen-test-gate.md: 10 attacker tests, zero critical/high before RC
- [x] notice_service.dart: pull-on-foreground queue, dismiss
- [ ] Abuse review UI + rotation cron live test (needs Stage F env + admin account)
- [ ] `deno check` on notify (CI covers it; no Deno on this PC)
