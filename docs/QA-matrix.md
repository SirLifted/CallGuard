# QA matrix — Stage Q (run on staging with 2 test accounts + 4 device pairs)

## 1. End-to-end script (roadmap §39, must pass on Android↔Android, iOS↔iOS, both cross)
Register → find user → call → request (purpose/minutes/quality) → review → approve →
indicator + timer → withdraw → stop ≤2s → history → play link → delete → audit row present.

## 2. Cross-platform diff (side-by-side screenshots per screen)
Same words, buttons, order, indicator (`● RECORDING mm:ss`), dialogs, toasts, errors.
Only OS chrome may differ (status bar, permission sheet style).

## 3. Accessibility checks
- Screen reader reads every button + the recording state aloud.
- Contrast ≥4.5:1 body text (tokens pairs verified).
- 48dp targets (no exceptions on call controls).
- Recording never color-only (label + icon + timer present in every state).
- Dynamic text 200% does not clip Approve/Decline/Withdraw.

## 4. Load to SLOs (staging, then prod shadow)
- Call setup p95 <3s Wi-Fi / <5s 4G (100 sampled setups per network).
- Push p95 <5s foreground + killed-app states.
- Recording start success >99% with valid ticket (200 starts).
- API p95 <300ms on auth + consent endpoints (k6 or locust, free).
- History available p95 <60s after stop (50 stops).
- Crash-free >99.5% (Sentry free tier).

## 5. Security re-run
Pen-test gate (`docs/pen-test-gate.md`) green again after every release. New findings → security-labeled issues, RC blocked on critical/high.
