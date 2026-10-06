# Post-MVP: enterprise (design outline)

- Organization accounts with teams; employee accounts join by invite (email domain check).
- Central recording policy (default retention per org) + per-team overrides, all within the user's own consent:
  org policy can only shorten personal retention, never silently extend it.
- Role-based access: owner / admin / member / auditor (read-only audit, no play links).
- Compliance exports: audit CSV per org + retention window, signed by the same hash chain.
- Billing: per stored-minute + per transcribed-minute meters (already tracked: duration + transcript flags).
- Enterprise login (SSO/OIDC) plugs into the same session + device-binding model from Stage B.
