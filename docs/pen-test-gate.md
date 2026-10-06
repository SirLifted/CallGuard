# Pen-test gate — Stage F acceptance (all must fail for the attacker)

Run against staging with a hacked client (your own test build that skips app-side checks):

1. Start saving with no ticket → relay must refuse; attempt in audit; account flagged at 5 tries.
2. Replay a withdrawn ticket (old jti) → refused (Upstash revocation).
3. Replay an expired ticket → refused (exp enforced by relay, not app clock).
4. Open someone else's play link as another user → 404 identical (authz per request, link viewer-bound).
5. Share my link with a second account → 404 (signature binds viewer id).
6. Hit R2 object URL directly (no signed link) → bucket denies (no public read).
7. Spam 50 recording requests in a minute → capped (10/call, 20/day per pair), identical responses.
8. Call/search a blocker → identical 404/empty, no existence leak; no push reaches either side.
9. Tamper one audit row's hash → hourly `verify_audit_chain()` flags it, deletions freeze.
10. Withdraw during extension vote → saving stops ≤2s, extension auto-declined.

Gate: zero critical/high findings open before RC. Findings become GitHub issues labeled security.
