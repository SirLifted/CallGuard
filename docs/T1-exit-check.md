# T1 exit check
- [x] Flutter shell opens (main.dart) with tokens + router stub
- [x] ApiClient matches openapi.yaml (otp / approve / withdraw / playback-url)
- [x] consent-ticket function stub defines 5-min ticket + revoke plan
- [x] LiveKit+Redis compose for $5 server; R2/Supabase free tiers per ADR v2
- [x] Flutter 3.47.6 installed (`flutter --version` passes, Dart 3.13.5)
- [x] `flutter doctor`: Flutter/Windows/Chrome/device/network OK; Android needs cmdline-tools + licenses; VS Build Tools missing (only needed for Windows desktop builds, not Android/iOS)
- [ ] `flutter analyze` on apps/mobile (running in background, slow network for first pub get)
- [ ] `flutter doctor --android-licenses` (needs interactive `y` + cmdline-tools via Android Studio)
