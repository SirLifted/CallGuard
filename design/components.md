# T0 — Design system (done: tokens + parts + screens)

Source: `tokens.json` v1.0.0. Rule: no raw colors outside tokens. All touch targets ≥48dp. Recording status is always text + icon + timer, never color alone.

## Parts (each: looks / states / screen-reader name / Flutter widget)

### 1. Buttons
- Primary (blue fill, white text): `Start call`, `Approve`, `Play`. States: normal / pressed (darker) / disabled (grey, 50%) / loading (spinner replaces label).
- Secondary (grey fill): `Cancel`, `Decline`, `Delete` (cancel part). Destructive (red fill): `Withdraw consent`, `Stop saving`, `Delete forever`. Ghost (blue outline): `Extend`, `Review`.
- Flutter: `ElevatedButton` variants in `CgButton`. Min size 48 high, radius 12, label from tokens button 14/600.

### 2. Inputs
- Phone/email field: label + hint + error line (e.g. `Enter a valid email`). OTP box: 6 boxes, auto-advance, paste fills all, 5 tries then 10-min lock message.
- Flutter: `CgTextField`, `CgOtpBoxes`. Error text uses error color + icon, not color alone.

### 3. Cards / sheets / dialogs
- History card: title, who, minutes · quality · status · date · deletes-in. Two buttons: Play (primary), Delete (secondary).
- Bottom sheet: used for extension + recording details on small screens. Drag handle, scrim tap dismisses (except withdraw confirm which needs explicit choice).
- Dialogs (all have title + plain facts + 2 buttons):
  - Request: who · why · minutes · quality · audio/video.
  - Approve/Decline. Extend: +minutes ask. Withdraw confirm: `Saving stops within 2 seconds. Both sides are told. This is logged.` Delete confirm: `Video + thumbnails gone now. Log entry stays ~12 months.`
- Flutter: `showCgDialog`, `CgBottomSheet`. Screen-reader names match titles.

### 4. Call UI
- Controls bar (dark pill): mic, camera flip, speaker, hang up (red). Each 48dp circle, icon + label on long-press.
- Full-screen states: ringing (caller + Accept/Decline), active (both videos + watermark userID+time), weak-net banner `Reconnecting…`, background note `Call continues — return to app`.
- Native: Android ConnectionService full-screen intent + FCM high priority. iOS CallKit + PushKit. Secure flag Android, capture notice iOS.

### 5. Recording indicator + notices
- Pill: red dot (pulsing) + `RECORDING 04:32`. Always visible on call + history thumbnail when active.
- Toasts/banners: `Extension request +5 min — Review`, `Recording stopped — consent withdrawn`, `Link expired — request new one`. Toast = dark rounded box, 4s, action underlined.

### 6. Empty / error / offline
- Empty history: illustration slot + `No recordings yet` + `Start a call` button.
- Error: `Could not load — Retry`. Offline: `No connection — saving paused, requests queued`. Retry always a real button, not pull-only.

## Screens (30, each lists buttons + checks + errors + permission point)

1. Splash (logo, 1.5s max) 2. Onboarding (3 swipes, Skip) 3. Register email (field + Send code) 4. OTP (6 boxes + Resend in 60s) 5. Home (calls + history tabs) 6. Search (field, rate-limited, same `Not found` whether missing or blocked) 7. Profile 8. Incoming call (Accept/Decline, CallKit/ConnectionService) 9. Outgoing (Cancel) 10. Active call (controls + indicator + watermark) 11–16. Six recording screens: request → approval view → active (timer) → extension ask → ending (`Stopping…`) → ended (saved, deletes-in date) 17. History list 18. Details (facts + Play + Delete + report) 19. Delete confirm 20–24. Privacy / Notifications / Security / Blocked / Report / Account / Help 25–27. Error / offline / permission-explainer (`We need camera + mic to call. Recordings only with permission.`).

Each screen acceptance: wording exact, every button does one thing, errors name the fix, permission asked only at point of use with explainer first.

## T0 exit check (all true)
- [x] tokens.json frozen + app_tokens.dart generated
- [x] This parts + screens spec merged
- [ ] Clickable demo linked here once Penpot/Figma file exists (free tier)
- [ ] Side-by-side Android/iOS screenshots identical except OS chrome (at build time)
