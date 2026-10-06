# Readiness checklist — all boxes ticked before RC

## Data safety
- [ ] Postgres daily backup + one restore actually tried on staging (not just scheduled).
- [ ] R2 versioning/lifecycle on; delete_at job dry-run reviewed.
- [ ] KMS/Vault rotation drill done once; old key readable until unreferenced.

## Legal + support
- [ ] Privacy Policy + Terms live in-app and on web (recording, retention, audit, contacts use).
- [ ] Data-deletion path: in-app Delete + account deletion wipes rows per policy (audit per its own clock).
- [ ] Support inbox + macros: consent disputes, takedown asks, blocked-user appeals.
- [ ] Incident runbook: who pages, who talks, who freezes deletions (hash-chain alarm).

## Ops
- [ ] Staging mirrors prod (same LiveKit version, same R2 rules, smaller box).
- [ ] Rollback tested once: previous app build + DB migrate-down on staging.
- [ ] Store forms filled honestly: camera/mic/recording/storage declared (Play Data Safety + App Privacy).
