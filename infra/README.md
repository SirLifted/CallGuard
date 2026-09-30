# Infra (dev → staging → prod)

- Terraform: VPC, Postgres (RDS/Cloud SQL), Redis, S3 bucket `callguard-recordings-<env>` with lifecycle on `delete_at`, KMS key per env, LiveKit (Cloud or self-hosted) + TURN.
- CI: lint + `tokens.json` check (no raw hex) + API tests + `sqlfluff`/migrate dry-run + Flutter analyze.
- Secrets: cloud secret manager only. Never commit `.env`, keystores, `google-services.json`, `GoogleService-Info.plist` (see .gitignore).
- Monitoring: SLO dashboards (setup p95, crash-free, push p95, recording success, API p95) + alerts + audit hash-chain verifier cron.
