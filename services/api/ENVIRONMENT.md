# Environment keys (names only — real values live in secret stores, never in git)

Add each key in Supabase dashboard → Project Settings → Edge Functions → Secrets.
(The repo `.gitignore` blocks all `.env*` files, so keep filled copies out of git.)

| Key | Where it comes from | Used by |
|---|---|---|
| `SUPABASE_URL` | Project Settings → API | app + functions |
| `SUPABASE_ANON_KEY` | Project Settings → API | app |
| `R2_ENDPOINT` | `https://<accountid>.r2.cloudflarestorage.com` | storage paths |
| `R2_BUCKET` | `callguard-recordings-dev` | storage paths |
| `R2_ACCESS_KEY_ID` | R2 API token (verified working) | playback-url, retention-sweep |
| `R2_SECRET_ACCESS_KEY` | R2 API token, shown once | playback-url, retention-sweep |
| `UPSTASH_REDIS_REST_URL` | Upstash console (Stage C task) | ticket revocation, rate limits |
| `UPSTASH_REDIS_REST_TOKEN` | Upstash console (Stage C task) | ticket revocation, rate limits |
| `RECORDING_JWT_SECRET` | Vault in prod; random 32+ chars for dev | consent-ticket, recording-extension |
| `CRON_SECRET` | random string you invent | retention-sweep guard |
| `LIVEKIT_URL` / `LIVEKIT_API_KEY` / `LIVEKIT_API_SECRET` | self-hosted server (Stage 2 task) | calls function |

R2 status: bucket verified live (signed write/read/delete OK, anonymous read refused).
