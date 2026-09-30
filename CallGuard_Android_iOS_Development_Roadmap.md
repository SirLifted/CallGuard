# CallGuard — Android & iOS App Development Roadmap

**Document type:** End-to-End Development Breakdown  
**Product:** CallGuard  
**Target platforms:** Android and iOS  
**Primary objective:** Build one privacy-controlled video-calling application with the same product appearance, specifications, workflows, and feature behaviour on both platforms.

---

## 1. Development Principles

The project should follow these principles from the beginning:

1. **One product, two platforms.**
   - Android and iOS should provide the same features and user journeys.
   - Differences caused by operating-system conventions should be kept minimal.

2. **Shared product specification.**
   - Do not design Android first and then make iOS a simplified copy.
   - Both platforms should be developed from the same functional and visual specification.

3. **Privacy by design.**
   - Recording consent, recording status, storage, access control, and deletion must be considered from the architecture stage.

4. **Backend-enforced security.**
   - The mobile applications must never be the sole authority for recording authorization.

5. **Build the MVP before advanced features.**
   - Prove the core recording-consent workflow before adding group calls, AI features, third-party integrations, subscriptions, and enterprise functionality.

6. **Do not circumvent other platforms.**
   - WhatsApp, Facebook/Messenger, Android, and iOS security restrictions must not be bypassed.
   - Third-party integrations should only be added where official capabilities permit them.

---

# 2. Overall Development Lifecycle

The project moves through PHASE 1 – PHASE 37 as defined below (single source of truth).

Summary groups:

- Foundation: PHASE 1–7 (validation, requirements, architecture, UX/UI, design system, environments, backend foundation)
- Calling: PHASE 8–10 (realtime infrastructure, app foundation, core call experience)
- Privacy core: PHASE 11–16 (consent engine, recording, extension, withdrawal, history/storage, retention/deletion)
- Trust: PHASE 17–21 (notifications, hardening, audit, abuse prevention, edge cases)
- Quality: PHASE 22–26 (accessibility, performance with SLOs, QA, cross-platform, security testing)
- Release: PHASE 27–33 (beta, readiness, store prep, RC, launch, monitoring, maintenance)
- Post-MVP: PHASE 34–37 (V2, AI, third-party integrations, enterprise)

Do not use any other phase list. If this summary and a PHASE heading disagree, the PHASE heading wins.

---

# PHASE 1 — PRODUCT VALIDATION

## Objective

Confirm that the product concept is technically and commercially worth building before significant development expenditure.

## Tasks

- Confirm target users.
- Confirm the core problem.
- Validate the consent-controlled recording concept.
- Interview potential users.
- Identify personal and professional use cases.
- Identify competing products.
- Research recording and consent requirements in target markets. Default to all-party consent; produce per-market matrix.
- Investigate technical restrictions on Android and iOS.
- Store-compliance gate: validate CallKit/PushKit (iOS) and Telecom ConnectionService + foreground-service types (Android) plus Play Data Safety / App Privacy disclosure acceptance for a recording app.
- Legal gate: counsel sign-off on consent model, retention vs audit split, data residency, Privacy Policy/ToS/DPA scope.

## Key decision

The initial product should be treated as an **independent video-calling environment**, not as an application that secretly monitors WhatsApp or Facebook.

## Deliverables

- Validated product concept
- Target-user definition
- MVP scope
- Initial competitor analysis
- Initial technical feasibility report
- Initial legal/privacy review

---

# PHASE 2 — REQUIREMENTS FINALIZATION

## Objective

Turn the product specification into a development contract.

## Finalize

### User features

- Registration
- Login
- Profile
- Contacts/user discovery
- One-to-one video calls
- Recording request
- Recording approval
- Recording decline
- Recording duration
- Recording quality
- Recording purpose
- Recording indicator
- Recording timer
- Recording extension
- Consent withdrawal
- Recording history
- Recording details
- Recording deletion
- Privacy settings
- Blocking/reporting

### System requirements

- Authentication
- Authorization
- Real-time communication
- Recording service
- Notification service
- Secure storage
- Audit logging
- Retention/deletion
- Monitoring
- Analytics

## Deliverables

- Final Product Requirements Document
- Final Software Requirements Specification
- Acceptance criteria for every feature
- MVP feature list
- Future feature list

---

# PHASE 3 — TECHNICAL ARCHITECTURE

## Objective

Decide how the complete system will work before implementation.

## Architecture areas

### Mobile

Choose a cross-platform or shared-code strategy so that Android and iOS can share as much application logic and UI specification as practical.

Possible approaches:

- Flutter
- React Native
- Kotlin Multiplatform with native UI
- Another suitable cross-platform architecture

The final choice should be made after evaluating video calling, recording, native permissions, performance, and long-term maintenance.

### Backend

Possible components:

- API layer
- Authentication service
- User service
- Call service
- Consent service
- Recording service
- Notification service
- Storage service
- Audit service

### Infrastructure

Define:

- Cloud provider
- Database
- Object storage
- CDN where appropriate
- Push notification infrastructure
- Video/WebRTC infrastructure
- Monitoring
- Logging
- Backup
- Disaster recovery

## Deliverables

- System architecture diagram
- Technology-selection document
- Database architecture
- API architecture
- Security architecture
- Infrastructure plan

---

# PHASE 4 — UX/UI DESIGN

## Objective

Create the complete visual and interaction system before development.

## Important requirement

The Android and iOS versions should have the **same visual identity and functional specification**.

They should share:

- Brand colours
- Typography
- Icons
- Logo
- Spacing
- Button styles
- Form styles
- Recording indicators
- Dialogs
- Notifications
- Screen layouts
- Terminology
- User journeys

Minor OS-specific interaction differences are acceptable only where required by Android or iOS conventions.

## Screens to design

1. Splash screen
2. Onboarding
3. Registration
4. Login
5. OTP verification
6. Forgot/reset credentials
7. Home
8. User search/contacts
9. User profile
10. Incoming call
11. Outgoing call
12. Active video call
13. Recording request
14. Recording approval
15. Active recording
16. Recording extension
17. Recording ending
18. Recording ended
19. Recording history
20. Recording details
21. Delete recording confirmation
22. Privacy settings
23. Notification settings
24. Security settings
25. Blocked users
26. Report user
27. Account settings
28. Help/support
29. Error states
30. Offline/network states

## Deliverables

- Wireframes
- High-fidelity designs
- Interactive prototype
- Mobile design system
- Accessibility specifications
- Android/iOS component mapping

---

# PHASE 5 — DESIGN SYSTEM

## Objective

Make sure developers can reproduce the same appearance consistently.

## Define

### Colours

Create named design tokens rather than hard-coding colours.

Example:

- Primary
- Secondary
- Background
- Surface
- Text primary
- Text secondary
- Error
- Warning
- Success
- Recording alert

### Typography

Define:

- Font family
- Heading sizes
- Body sizes
- Button text
- Caption text
- Line height
- Font weight

### Components

Define:

- Buttons
- Text fields
- Cards
- Bottom sheets
- Dialogs
- Toggles
- Tabs
- Navigation
- Recording indicator
- Timer
- Call controls
- Toasts
- Notifications

## Deliverable

A single design-system reference used by both Android and iOS development teams.

---

# PHASE 6 — DEVELOPMENT ENVIRONMENT & REPOSITORIES

## Objective

Create a professional engineering environment.

## Set up

- Source-control repository
- Branching strategy
- Development environment
- Staging environment
- Production environment
- CI/CD pipeline
- Automated builds
- Automated tests
- Code-quality checks
- Secrets management
- Environment configuration

## Recommended environments

```text
Development
     ↓
Staging
     ↓
Production
```

Never develop directly against production.

---

# PHASE 7 — BACKEND FOUNDATION

## Objective

Build the core server infrastructure.

## Implement

### Authentication

Fixed decision for MVP:

- Primary: phone-number OTP (Firebase Auth or Cognito or equivalent). Email + password is not the MVP path.
- OTP: 6-digit, 5 attempts max, 5 requests per 10 minutes per number, 5-minute code expiry.
- Sessions: short access token + rotating refresh token, server-side revocation, device binding, logout all devices supported.
- Recovery: OTP re-verification only. No security questions.
- Optional post-MVP: 2FA/passkeys.

### User service

- Profiles
- User IDs (stable UUID, never phone number as primary key)
- Preferences
- Blocking (block suppresses calls, recording requests, and notifications both ways)
- Account status
- User discovery privacy: hashed phone lookup, rate-limited search, no existence oracle (uniform responses), optional mutual-contact-only mode.

### Database

Implement core tables/entities:

- Users
- Calls
- Call participants
- Recording requests
- Consent
- Recordings
- Audit logs
- Notifications

## Deliverables

- Working backend
- Database migrations
- Authentication API
- User API
- Automated backend tests

---

# PHASE 8 — REAL-TIME CALLING INFRASTRUCTURE

## Objective

Create reliable one-to-one video calls.

## Implement

- Call creation
- Call invitation
- Call acceptance
- Call rejection
- Camera
- Microphone
- Speaker
- Camera switching
- Mute/unmute
- Video on/off
- Call termination
- Connection status
- Reconnection
- Network adaptation

## Technology

Fixed decision for MVP: WebRTC via SFU with server-side recording (recommended: LiveKit; alternatives: Chime SDK, Twilio, Daily).

- P2P mesh is rejected for MVP because the server cannot authoritatively stop a peer-to-peer recording.
- SFU is authoritative for recording: it validates `recording_auth_jwt` before starting and stops muxing on withdrawal/expiry.
- Clients never record locally with `MediaRecorder`. They only send requests; the server/SFU records.

## Test

- Wi-Fi
- 4G
- 5G
- Weak network
- Network switching
- Background/foreground transitions
- Different Android devices
- Different iPhones

---

# PHASE 9 — ANDROID & iOS APPLICATION FOUNDATION

## Objective

Create both mobile applications from the same product specification.

## Implement shared product structure

- Navigation
- Authentication screens
- User profile
- Home
- Contacts
- Call screens
- Settings
- Notifications
- Recording history

## Platform-specific requirements

Respect:

- Android permissions
- iOS permissions
- Camera permissions
- Microphone permissions
- Background execution rules
- Push notification requirements
- Audio-session behaviour
- OS lifecycle behaviour

The user-facing appearance should remain substantially identical.

---

# PHASE 10 — CORE VIDEO-CALL EXPERIENCE

## Objective

Complete the normal call experience before adding recording.

## Implement

### Outgoing call

- Select user
- Start call
- Ringing
- Cancel
- Connected

### Incoming call

- Caller information
- Accept
- Decline

### Active call

- Video
- Audio
- Mute
- Camera
- Speaker
- End call

## Acceptance criteria

Two test accounts should be able to establish a stable one-to-one video call on:

- Android ↔ Android
- iOS ↔ iOS
- Android ↔ iOS

---

# PHASE 11 — RECORDING CONSENT ENGINE

## Objective

Build the most important product feature.

## Workflow

```text
User requests recording
        ↓
Server creates request
        ↓
Participant receives request
        ↓
Participant reviews details
        ↓
Approve / Decline
        ↓
Server validates decision
        ↓
Recording authorization created
        ↓
Recording may begin
```

## Recording request fields

- Requester
- Participant
- Purpose
- Duration
- Quality
- Audio
- Video
- Timestamp

## Important rule

The client application must not be able to bypass the consent state.

The backend must verify the authorization before recording starts.

Enforcement design (MVP):

- On approval, server issues short-lived `recording_auth_jwt {call_id, request_id, participants, scope(audio/video), quality, duration, exp}` (e.g. 5-minute TTL, renewed only on approved extension).
- SFU validates JWT on `StartRecording`. No valid JWT = no recording. Expired/revoked JWT = immediate stop.
- Scope limitation: this guarantee covers in-app/server recording only. OS-level screen capture, external cameras, or rooted devices cannot be technically prevented. See PHASE 12 for deterrence.

---

# PHASE 12 — RECORDING SYSTEM

## Objective

Implement controlled recording.

## Implement

- Recording start
- Recording stop
- Recording timer
- Duration enforcement
- Quality enforcement
- Recording metadata
- Recording status
- Recording indicator
- Recording failure handling

## Recording states

```text
REQUESTED
APPROVED
STARTED
STOPPED
EXPIRED
CONSENT_WITHDRAWN
FAILED
CANCELLED
```

## Enforcement and capture deterrence

- Authoritative stop: SFU stops muxing within 2 seconds of `CONSENT_WITHDRAWN` / `EXPIRED` / JWT revocation.
- No local recording path: clients have no supported offline-record button.
- OS-capture deterrence (best effort, not prevention):
  - Android: `FLAG_SECURE` on call/recording screens.
  - iOS: `UIScreen.isCaptured` monitoring; on detection emit `capture_detected` audit event and notify both peers.
  - Visible watermark overlay with `user_id + timestamp` on video and recording indicator.
- Failed/invalid authorization attempts are audit-logged.

---

# PHASE 13 — RECORDING EXTENSION

## Objective

Allow controlled extension without silently extending consent.

## Workflow

```text
Recording approaching limit
        ↓
Requester selects "Extend"
        ↓
Extension request sent
        ↓
Participant receives request
        ↓
Approve / Decline
        ↓
If approved → recording continues
If declined → recording ends
```

The backend must enforce the extension.

---

# PHASE 14 — CONSENT WITHDRAWAL

## Objective

Allow participants to stop an active recording.

## Workflow

```text
Participant selects
"Withdraw Consent"
        ↓
Confirmation
        ↓
Server validates participant
        ↓
Recording stops
        ↓
Audit event created
        ↓
Both users notified
```

## Acceptance criterion

Once valid withdrawal is confirmed, the server/SFU must stop the in-app recording within 2 seconds (system-controlled termination window) and revoke the `recording_auth_jwt`.

Explicit scope: this does not and cannot prevent OS-level screen recording or external capture. Those cases are handled by deterrence (FLAG_SECURE, capture detection, watermark) plus audit and legal notice, not by technical prevention.

---

# PHASE 15 — RECORDING HISTORY & STORAGE

## Implement

- Recording list
- Recording details
- Duration
- Quality
- Purpose
- Participants
- Recording status
- Date/time
- Recording ID
- Storage status
- Deletion date

## Storage

Use secure object storage.

Do not expose recordings through public URLs.

Use authenticated and authorized access.

---

# PHASE 16 — RECORDING RETENTION & DELETION

## Implement

Retention options:

- 24 hours
- 7 days
- 30 days
- 90 days
- Custom
- Manual deletion

## Requirements

- Display deletion date.
- Automatically delete expired recordings (media bytes + derived artifacts like thumbnails).
- Immediately revoke signed URLs and access paths on delete/expiry.
- Maintain appropriate non-content audit metadata where required (see PHASE 19: metadata retained per audit policy, e.g. 12 months, then deleted; never retain media to satisfy audit).

---

# PHASE 17 — NOTIFICATION SYSTEM

## Implement

### Push notifications

- Incoming call
- Recording request
- Recording approved
- Recording declined
- Recording started
- Extension request
- Recording ending soon
- Recording ended
- Consent withdrawn

### In-app notifications

Use the same terminology and visual language on both platforms.

---

# PHASE 18 — PRIVACY & SECURITY HARDENING

## Implement

### Authentication security

- Secure tokens
- Session expiration
- Device/session management
- Optional MFA/passkeys

### Data security

Fixed decision for MVP: no end-to-end encryption. Server is the trusted recorder.

- Encryption in transit: TLS 1.2+ for API/signaling, DTLS-SRTP for media.
- Encryption at rest: S3-compatible storage with SSE-KMS, per-recording data key (DEK), KMS holds KEK, key rotation.
- Secure key management via cloud KMS only. No keys in app binaries.
- Access control: signed, expiring URLs tied to `recording_auth` check on every playback/download.
- E2EE is an explicit V2 non-goal because it conflicts with server-enforced recording.

### API security

- Authentication
- Authorization
- Rate limiting
- Input validation
- Request validation

### Recording security

- Protected storage
- Authorized playback
- Secure downloads
- Expiring links
- Access logging

---

# PHASE 19 — AUDIT SYSTEM

## Implement tamper-resistant audit records.

- Append-only store (e.g. WORM table or hash-chained log). No update/delete API. Previous-hash column verified by background job.
- Content vs metadata split: audit stores non-content metadata only (`recording_id, call_id, actor_id hash, event, timestamp, policy_id, content_sha256`). Never store purpose free-text verbatim if sensitive, never store media bytes.
- On content expiry/deletion, audit metadata is retained per audit policy (e.g. 12 months), then deleted per same policy.

Track:

- Recording requested
- User notified
- Recording approved
- Recording declined
- Recording started
- Recording stopped
- Consent withdrawn
- Extension requested
- Extension approved/declined
- Recording deleted
- Recording accessed/downloaded

The audit system should not expose unnecessary private content.

---

# PHASE 20 — ABUSE PREVENTION

## Implement

- Block user
- Report user
- Rate-limit recording requests
- Detect excessive request behaviour
- Prevent notification spam
- Account restrictions
- Abuse review workflow

## Example

If User A repeatedly sends unwanted recording requests to User B, User B should be able to block future requests.

---

# PHASE 21 — ERROR & EDGE-CASE IMPLEMENTATION

Explicitly implement behaviour for:

- Call disconnect
- Network loss
- Application crash
- Device restart
- User leaves call
- Backgrounding
- Recording server failure
- Storage failure
- Notification failure
- Expired consent
- Duplicate recording request
- Simultaneous recording requests
- Invalid recording authorization
- Unsupported recording quality

The backend must remain authoritative when the mobile client becomes unavailable.

---

# PHASE 22 — ACCESSIBILITY

Both Android and iOS versions should support:

- Screen readers
- Sufficient text contrast
- Dynamic text sizing where practical
- Large touch targets
- Clear error messages
- Accessible recording indicators
- Non-colour-only status communication

Recording status should never be communicated only through colour.

For example:

**🔴 RECORDING**

rather than simply showing a red dot.

---

# PHASE 23 — PERFORMANCE OPTIMIZATION

## SLO targets (MVP must meet these before RC)

- Call setup p95: <3s Wi-Fi, <5s 4G
- Crash-free sessions: >99.5%
- Push delivery p95: <5s (foreground/background killed states measured separately)
- Recording start success: >99% with valid JWT
- API p95: <300ms (auth, consent endpoints)
- SFU-to-storage upload: recording available in history p95 <60s after stop

Measure:

- App launch time
- Call connection time
- Video latency
- Audio latency
- CPU usage
- Memory usage
- Battery consumption
- Recording processing time
- Storage upload time

Optimize without compromising recording consent or security.

---

# PHASE 24 — QUALITY ASSURANCE

Testing should happen continuously, not only at the end.

## Unit testing

Test:

- Consent logic
- Recording states
- Duration calculations
- Permission validation
- Retention calculations

## Integration testing

Test:

- Authentication
- Calling
- Consent
- Recording
- Storage
- Notifications

## End-to-end testing

Test complete user journeys.

Example:

```text
Register
→ Find user
→ Call
→ Request recording
→ Receive request
→ Approve
→ Record
→ Withdraw consent
→ Stop
→ View history
→ Access recording
→ Delete recording
```

---

# PHASE 25 — CROSS-PLATFORM TESTING

Every major feature should be tested across:

### Android

- Android-to-Android
- Android-to-iOS

### iOS

- iOS-to-iOS
- iOS-to-Android

Test both:

- Latest supported OS versions
- A reasonable range of older supported versions

## Important

The test team should compare Android and iOS side-by-side for:

- Screen appearance
- Text
- Buttons
- Recording indicators
- Dialogs
- Notifications
- Navigation
- Error states
- Recording behaviour

---

# PHASE 26 — SECURITY TESTING

Conduct:

- API penetration testing
- Authentication testing
- Authorization testing
- Storage access testing
- Session testing
- Token testing
- Recording-access testing
- Consent-bypass testing
- Download-link testing
- Abuse testing

Critical test:

> Can a malicious client start or access a recording without valid server authorization?

Expected answer:

**No.**

---

# PHASE 27 — BETA VERSION

Create a controlled beta release.

## Beta users

Start with a limited group.

Test:

- Calls
- Recording requests
- Consent
- Recording
- Notifications
- Storage
- Device compatibility
- User experience

Collect:

- Bugs
- Crashes
- Performance issues
- Confusing screens
- Privacy concerns
- Feature requests

Do not immediately add every requested feature.

Prioritize issues affecting:

1. Privacy
2. Security
3. Call reliability
4. Recording reliability
5. Usability

---

# PHASE 28 — PRODUCTION READINESS

Before launch, confirm:

- Backend production environment
- Database backups
- Monitoring
- Alerting
- Secure storage
- Disaster recovery
- Privacy documentation
- Terms of service
- User support process
- Account deletion process
- Data deletion process
- Incident response process

---

# PHASE 29 — APP STORE PREPARATION

## Android

Prepare:

- Google Play developer account
- App name
- Package/application ID
- App icon
- Screenshots
- Store description
- Privacy policy
- Data-safety information (declare camera, mic, recordings, storage)
- Telecom ConnectionService integration, `FOREGROUND_SERVICE_CAMERA|MICROPHONE` + `FOREGROUND_SERVICE_PHONE_CALL` where used
- Content rating
- Release signing
- Production build

## iOS

Prepare:

- Apple Developer account
- Bundle ID
- App icon
- Screenshots
- Store description
- Privacy policy
- App privacy information (declare recording/data use)
- CallKit + PushKit for incoming calls, `NSCameraUsageDescription` / `NSMicrophoneUsageDescription`, privacy manifest
- Age rating
- Production certificates/signing
- App Store metadata

The store information must accurately describe the app's data collection and recording functionality.

Store feasibility is a Phase 1 gate, not a Phase 29 surprise: validate background-call, CallKit/ConnectionService, and recording-disclosure acceptance before building recording.

---

# PHASE 30 — RELEASE CANDIDATE

Create a final Release Candidate build.

Perform:

- Full regression testing
- Security testing
- Performance testing
- Cross-platform testing
- Store compliance review
- Privacy review
- Backup verification
- Disaster-recovery verification

Only unresolved low-risk issues should remain.

---

# PHASE 31 — PRODUCTION LAUNCH

## Launch sequence

1. Deploy production backend.
2. Verify monitoring.
3. Release Android application.
4. Release iOS application.
5. Monitor crashes.
6. Monitor call success.
7. Monitor recording success.
8. Monitor consent events.
9. Monitor server performance.
10. Respond to critical issues quickly.

Avoid changing major architecture immediately after launch unless required.

---

# PHASE 32 — POST-LAUNCH MONITORING

Track:

### Reliability

- Crash rate
- Call failure rate
- Recording failure rate
- Notification failure rate

### Performance

- API latency
- Call latency
- Recording processing time
- Storage performance

### Privacy/security

- Unauthorized access attempts
- Consent errors
- Security incidents
- Abuse reports

### Product

- Active users
- Calls
- Recording requests
- Recording approvals
- Recording declines
- Consent withdrawals

---

# PHASE 33 — MAINTENANCE

Ongoing work:

- Android OS compatibility
- iOS compatibility
- Dependency updates
- Security patches
- Server updates
- Database maintenance
- Performance optimization
- Bug fixes
- User support

Every major Android/iOS release should be tested before the product officially supports it.

---

# PHASE 34 — VERSION 2 FEATURES

After the MVP is stable, consider:

- Group video calls
- Group recording consent
- Screen-sharing consent
- Audio-only calls
- Secure recording sharing
- Watermarked recordings
- Organization accounts
- Team management
- Admin dashboard
- Advanced retention policies
- Subscription plans

---

# PHASE 35 — AI FEATURES

AI should be considered only after the core privacy and calling system is stable.

Potential features:

- Automatic transcription
- Meeting summary
- Action-item extraction
- Speaker identification
- Searchable transcript
- Recording highlights

Before enabling any AI processing, the product should clearly explain:

- What data is processed
- Why it is processed
- Where processing occurs
- How long the resulting data is retained
- Who can access it

AI processing should require the appropriate user authorization.

---

# PHASE 36 — THIRD-PARTY PLATFORM INTEGRATIONS

Investigate integrations only after the independent calling product is stable.

Explicit non-goals for all versions unless an official API proves otherwise:

- WhatsApp call interception/recording
- Facebook/Messenger call interception/recording

These platforms provide no official call-recording API and their ToS plus Android/iOS restrictions prohibit interception. Do not roadmap them as features.

Potential targets only where official APIs exist:
- Zoom
- Microsoft Teams
- Google Meet
- Other supported platforms

For every integration, answer:

1. Does the platform provide an official API?
2. Can the required call/recording event be detected?
3. Can participant consent be requested?
4. Can recording actually be controlled?
5. Does the platform permit the integration?
6. Does the integration comply with its developer policies?
7. Can Android/iOS restrictions be respected?

If the answer to the technical-control question is no, do not pretend that the integration provides capabilities it cannot provide.

---

# PHASE 37 — BUSINESS/ENTERPRISE VERSION

Potential features:

- Organization accounts
- Employee accounts
- Team administration
- Organization recording policies
- Centralized retention policies
- Audit reports
- Role-based access control
- Compliance controls
- Enterprise authentication
- Billing
- Usage reporting

---

# 38. Final Product Architecture

The intended mature architecture should resemble:

```text
                         CALLGUARD
                            │
             ┌──────────────┴──────────────┐
             │                             │
         Android                         iOS
             │                             │
             └──────────────┬──────────────┘
                            │
                         API Layer
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
 Authentication        Call Service       Consent Service
        │                   │                   │
        │                   ▼                   │
        │             Video Infrastructure     │
        │                                       │
        └───────────────────┬───────────────────┘
                            │
                    Recording Controller
                            │
             ┌──────────────┼──────────────┐
             │              │              │
          Storage         Audit        Notifications
             │              │              │
             └──────────────┴──────────────┘
                            │
                     Monitoring/Admin
```

---

# 39. Definition of MVP Completion

The MVP should not be considered complete until the following journey works reliably on both Android and iOS:

```text
User A registers
        ↓
User B registers
        ↓
User A finds User B
        ↓
User A starts video call
        ↓
User A requests recording
        ↓
User B receives request
        ↓
User B reviews:
    • Purpose
    • Duration
    • Quality
    • Audio
    • Video
        ↓
User B approves
        ↓
Recording starts
        ↓
Both see recording indicator
        ↓
Timer runs
        ↓
User B can withdraw consent
        ↓
Recording stops
        ↓
Recording metadata is saved
        ↓
Recording appears in history
        ↓
Authorized user can access it
        ↓
Recording is eventually deleted
        ↓
Audit trail remains according to policy
```

The same functional journey must work across:

- Android → Android
- iOS → iOS
- Android → iOS
- iOS → Android

---

# 40. Recommended Development Order

For practical project management, build in this order:

### Stage 1 — Foundation
1. Product requirements
2. Architecture
3. UX/UI
4. Design system
5. Development environments

### Stage 2 — Backend
6. Authentication
7. Users
8. Database
9. API
10. Notifications

### Stage 3 — Calling
11. Signaling
12. WebRTC/video
13. Audio
14. Call lifecycle
15. Network recovery

### Stage 4 — Privacy Core
16. Recording request
17. Consent
18. Authorization
19. Recording indicator
20. Recording timer
21. Duration enforcement
22. Consent withdrawal
23. Recording extension

### Stage 5 — Recording Management
24. Recording storage
25. Recording history
26. Recording details
27. Access control
28. Deletion/retention
29. Audit logs

### Stage 6 — Security
30. Authentication hardening
31. API authorization
32. Storage security
33. Abuse prevention
34. Security testing

### Stage 7 — Quality
35. Unit tests
36. Integration tests
37. End-to-end tests
38. Android testing
39. iOS testing
40. Cross-platform testing

### Stage 8 — Release
41. Beta
42. Bug fixing
43. Security review
44. Store preparation
45. Release candidate
46. Production launch

### Stage 9 — Growth
47. Monitoring
48. Maintenance
49. Version 2
50. Enterprise features
51. AI features
52. Official third-party integrations

---

# 41. Key Rule for the Entire Project

The product should always follow this sequence:

**Inform → Ask → Authorize → Record → Monitor → Stop → Store securely → Delete according to policy.**

No feature should undermine this principle.

---

# 42. Immediate Next Step

Before coding begins, the project should move into a separate **Technical Design & UI/UX Specification phase**.

That next document should define:

- Exact technology stack
- Exact database schema
- Complete API specification
- Authentication architecture
- Video/WebRTC architecture
- Recording architecture
- Cloud infrastructure
- Android project structure
- iOS project structure
- Shared design system
- Every app screen
- Every button and action
- Every validation rule
- Every error state
- Every permission
- Every notification
- Complete user flows
- Acceptance criteria

Once that document is approved, development can proceed systematically from Phase 1 through production rather than making architectural decisions while coding.
