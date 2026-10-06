# Release runbook — RC to rollout

## RC bar (all true or no ship)
- QA matrix green on all 4 pairs, SLOs met, pen-test gate zero critical/high.
- Only low-risk issues open, each with owner + date.
- Backup restore + rollback both tried this cycle.

## Rollout order (staged, watch 48h each step)
1. Android 10% → 50% → 100% (Play staged rollout).
2. iOS TestFlight final → App Store phased release.
3. Backend first, then apps (DB migrations are backward-compatible one version).

## Watch (Sentry free + Grafana Cloud free + Uptime Kuma)
- Crash-free <99.5%, call-setup p95 >3s Wi-Fi, push p95 >5s, recording success <99% → freeze rollout.
- Consent errors / unauthorized attempts spike → freeze + security review.
- Daily during rollout: calls, requests, approvals, declines, withdrawals (product sanity).

## Rollback
- Apps: halt staged rollout, promote previous build.
- Backend: `migrate-down` one version (migrations 001–006 are append-only, each reversible).
- Comms template in Help: what broke, who is affected, what to do.
