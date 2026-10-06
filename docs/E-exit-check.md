# Stage E exit check — saving + history + notebook
- [x] playback-url stub (authz check, STOPPED-only, 5-min viewer-bound link, audit-before-return)
- [x] retention-sweep stub (hourly shred of bytes, row metadata kept, audit kept ~12mo, second sweep)
- [x] 005 migration: stopped_at + media_deleted_at, s3_key nullable, verify_audit_chain(), is_watchable()
- [x] ApiClient: listRecordings / deleteRecording added
- [x] history_service.dart: server-driven list, Retry wording per T0, delete-then-refresh
- [ ] R2 + sweep live test: expired video gives 403/410, audit survives, chain green (needs Stage E env)
- [ ] `deno check` on new functions (CI covers it; no Deno on this PC)
