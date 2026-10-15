// Real email-OTP auth via Supabase. Same state shape the router already reads
// (email/loggedIn/otpSent), plus an error line for wrong codes.
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_links.dart';

class AuthState {
  final String email;
  final bool loggedIn;
  final bool otpSent;
  final bool sending;
  final bool verifying;
  final bool profileLoading;
  final bool profileComplete;
  final String error;
  const AuthState(
      {this.email = '',
      this.loggedIn = false,
      this.otpSent = false,
      this.sending = false,
      this.verifying = false,
      this.profileLoading = true,
      this.profileComplete = false,
      this.error = ''});

  AuthState copyWith(
      {String? email,
      bool? loggedIn,
      bool? otpSent,
      bool? sending,
      bool? verifying,
      bool? profileLoading,
      bool? profileComplete,
      String? error}) =>
      AuthState(
        email: email ?? this.email,
        loggedIn: loggedIn ?? this.loggedIn,
        otpSent: otpSent ?? this.otpSent,
        sending: sending ?? this.sending,
        verifying: verifying ?? this.verifying,
        profileLoading: profileLoading ?? this.profileLoading,
        profileComplete: profileComplete ?? this.profileComplete,
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
      _loadProfile();
    } else {
      state = state.copyWith(profileLoading: false);
    }
    _sub = client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        final wasIn = state.loggedIn;
        state = state.copyWith(loggedIn: true, otpSent: false, error: '');
        if (!wasIn) _loadProfile();
      } else if (state.loggedIn) {
        state = const AuthState(email: '', profileLoading: false);
      }
    });
  }

  // Own profile row only (RLS: auth.uid() = id). Creates it on first login.
  Future<void> _loadProfile() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser!.id;
      final row = await client.from('users').select('profile_complete').eq('id', uid).maybeSingle();
      if (row == null) {
        await client.from('users').upsert({
          'id': uid,
          'email_hash': state.email.trim().toLowerCase(),
          'display_name': state.email.trim().toLowerCase(),
        });
        if (mounted) state = state.copyWith(profileLoading: false, profileComplete: false);
      } else if (mounted) {
        state = state.copyWith(
            profileLoading: false, profileComplete: (row['profile_complete'] as bool?) ?? false);
      }
    } catch (_) {
      if (mounted) state = state.copyWith(profileLoading: false, profileComplete: false);
    }
  }

  Future<void> saveProfile(
      {required String first, required String middle, required String last, required String dob, required String location}) async {
    state = state.copyWith(error: '');
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser!.id;
      await client.from('users').update({
        'first_name': first.trim(),
        'middle_name': middle.trim(),
        'last_name': last.trim(),
        'dob': dob.isEmpty ? null : dob,
        'location': location.trim(),
        'display_name': '${first.trim()} ${last.trim()}'.trim(),
        'profile_complete': true,
      }).eq('id', uid);
      state = state.copyWith(profileComplete: true);
    } catch (_) {
      state = state.copyWith(error: 'Could not save — check connection and retry');
    }
  }

  void setEmail(String v) =>
      state = state.copyWith(email: v.trim().toLowerCase(), error: '');

  Future<void> sendOtp() async {
    state = state.copyWith(sending: true, error: '');
    try {
      // emailRedirectTo: the link in the email lands straight on the call screen.
      // Must be allow-listed in Supabase → Auth → URL Configuration → Redirect URLs.
      await Supabase.instance.client.auth.signInWithOtp(
        email: state.email,
        emailRedirectTo: AppLinks.postLoginCallUrl,
      );
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
