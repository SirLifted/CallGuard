// DEMO auth state (no backend yet). Sign-in gate for the UI tour; real OTP arrives with Stage F wiring.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String email;
  final bool loggedIn;
  final bool otpSent;
  const AuthState({this.email = '', this.loggedIn = false, this.otpSent = false});

  AuthState copyWith({String? email, bool? loggedIn, bool? otpSent}) => AuthState(
        email: email ?? this.email,
        loggedIn: loggedIn ?? this.loggedIn,
        otpSent: otpSent ?? this.otpSent,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());
  void setEmail(String v) => state = state.copyWith(email: v.trim().toLowerCase());
  void sendOtp() => state = state.copyWith(otpSent: true);
  void confirmOtp(String code) {
    // DEMO: any 6 digits pass. Real flow = Supabase email OTP + server session.
    if (code.length == 6) state = state.copyWith(loggedIn: true, otpSent: false);
  }
  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController());
