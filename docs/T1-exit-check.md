# T1 exit check
- [x] Flutter shell opens (main.dart) with tokens + router stub
- [x] ApiClient matches openapi.yaml (otp / approve / withdraw / playback-url)
- [x] consent-ticket function stub defines 5-min ticket + revoke plan
- [x] LiveKit+Redis compose for $5 server; R2/Supabase free tiers per ADR v2
- [x] Flutter 3.47.6 installed (`flutter --version` passes, Dart 3.13.5)
- [x] `flutter doctor`: Flutter/Windows/Chrome/device/network OK; Android needs cmdline-tools + licenses; VS Build Tools missing (only needed for Windows desktop builds, not Android/iOS)
- [x] `flutter analyze` on apps/mobile passes (fixed cross-package import via `lib/core/app_tokens.dart`; workspace wiring deferred to Stage B)
- [x] `flutter doctor --android-licenses` accepted via cmdline-tools (`Sdk\cmdline-tools\latest`, sdkmanager). `flutter doctor`: Flutter/Windows/Android/Chrome/device/network OK. Visual Studio missing — explicitly out of scope (Windows-desktop builds only; targets are Android/iOS).
