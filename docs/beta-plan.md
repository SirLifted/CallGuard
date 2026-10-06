# Beta plan — 100–500 testers, closed track

## Who
- 50 friends/family (friendly, forgiving, varied phones + networks).
- 50 target users (people who record calls for work: journalists, researchers, sales).
- Rest from waitlist, Android-heavy first (faster review track), then iOS TestFlight.
- Exclude: anyone who needs WhatsApp/Messenger recording (non-goal — tell them on day one).

## What they test (one task per week)
1. Register + find + 1-to-1 call (any network).
2. Request → approve → record 5 min → history → play.
3. Withdraw mid-save + extension vote.
4. Kill the app mid-call, weak-net walk, background/foreground.
5. Delete a video + check the log entry stays.

## Feedback channel
- In-app: shake or Help → `Report a problem` (attaches logs, never video without permission).
- GitHub issues with template (device, OS, network, what happened, what should happen).
- Labels: `privacy`, `security`, `call-drop`, `recording`, `ux`, `beta-feedback`.

## Triage order (fix in this order, weekly release)
1. Privacy (wrong person hears/saves) 2. Security (bypass, leak) 3. Call drops
4. Save failures 5. Confusing screens. Feature requests wait until after launch.
