// Real email-OTP auth via Supabase. Same state shape the router already reads
// (email/loggedIn/otpSent), plus an error line for wrong codes.
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final String email;
  final bool loggedIn;
  final bool otpSent;
  final bool sending;
  final bool verifying;
  final String error;
  const AuthState(
      {this.email = '',
      this.loggedIn = false,
      this.otpSent = false,
      this.sending = false,
      this.verifying = false,
      this.error = ''});

  AuthState copyWith({String? email, bool? loggedIn, bool? otpSent, bool? sending, bool? verifying, String? error}) =>
      AuthState(
        email: email ?? this.email,
        loggedIn: loggedIn ?? this.loggedIn,
        otpSent: otpSent ?? this.otpSent,
        sending: sending ?? this.sending,
        verifying: verifying ?? this.verifying,
        error: error ?? this.error,
      );
}

class AuthController extends StateNotifier<AuthState> {
  StreamSubscription? _sub;

  AuthController() : super(const AuthState()) {
    final client = Supabase.instance.client;
    // Restore session (Supabase persists it on device/web storage).
    if (client.auth.currentSession != null) {
      state = state.copyWith(loggedIn: true);
    }
    _sub = client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = state.copyWith(loggedIn: true, otpSent: false, error: '');
      } else if (state.loggedIn) {
        state = const AuthState(email: '');
      }
    });
  }

  void setEmail(String v) =>
      state = state.copyWith(email: v.trim().toLowerCase(), error: '');

  Future<void> sendOtp() async {
    state = state.copyWith(sending: true, error: '');
    try {
      await Supabase.instance.client.auth.signInWithOtp(email: state.email);
      state = state.copyWith(otpSent: true, sending: false);
    } catch (e) {
      state = state.copyWith(sending: false, error: 'Could not send code — check connection and retry');
    }
  }

  Future<void> confirmOtp(String code) async {
    if (code.length != 6) return;
    state = state.copyWith(verifying: true, error: '');
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: state.email,
        token: code,
      );
      if (res.session != null) {
        state = state.copyWith(loggedIn: true, otpSent: false, verifying: false);
      } else {
        state = state.copyWith(verifying: false, error: 'Wrong code — try again');
      }
    } catch (_) {
      state = state.copyWith(verifying: false, error: 'Wrong code — try again');
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController());
