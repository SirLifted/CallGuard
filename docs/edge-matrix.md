# Edge-case matrix — backend is the referee in every row

| # | Event | App shows | Server does (authoritative) |
|---|---|---|---|
| 1 | Call drops mid-save | `Reconnecting…`, timer freezes | Keeps egress open 30s grace; resumes on rejoin or stops + audits |
| 2 | Network lost | Offline banner, requests queued | Queued writes rejected if ticket expired meanwhile; client re-asks |
| 3 | App crashes / device restarts | Reopen → call screen offers rejoin | Room stays 30s; recording continues only while ticket valid, else stops |
| 4 | User leaves call | `You left` | Participant row `left_at`; if saver leaves, recording stops + audits |
| 5 | App backgrounded | `Call continues` note | Recording continues (ticket still valid); OS capture notice still monitored on return |
| 6 | Relay (SFU) fails | `Saving failed — retry` | Status FAILED + audit; partial file kept with sha, marked incomplete |
| 7 | Storage write fails | Same as 6 | Retry queue 3x, then FAILED + page on-call |
| 8 | Push fails | Nothing (silent) | Notification row stays queued; app pulls on next foreground (in-app fallback) |
| 9 | Ticket expired mid-save | Timer hits 0 → `Stopping…` | Egress stops at expiry; needs fresh approval to continue (no auto-extend) |
| 10 | Duplicate request (double-tap) | One spinner | Second insert returns existing REQUESTED row (idempotency key: call + requester + minute) |
| 11 | Simultaneous requests both ways | Both see `Review` | First-writer-wins; second gets 409 identical + points at the open request |
| 12 | Invalid/forged ticket at relay | `Not allowed` | Egress refused, attempt audit-logged, account flagged after 5 tries |
| 13 | Quality higher than approved | Capped silently + note | Relay caps egress to approved quality; upgrade needs new approval |
| 14 | Withdraw arrives during extension vote | `Stopping…` | Withdraw wins always; extension request auto-declined + both told |
