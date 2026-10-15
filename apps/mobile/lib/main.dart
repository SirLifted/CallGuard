// App shell + router. UI tour is DEMO data until the backend wiring lands (Stages B–F tasks).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'core/app_tokens.dart';
import 'core/supabase_config.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/call_screen.dart';
import 'screens/recording_details_screen.dart';
import 'screens/settings_screens.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.anonKey);
  runApp(const ProviderScope(child: CallGuardApp()));
}

class CallGuardApp extends StatelessWidget {
  const CallGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CallGuard',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppTokens.primary,
        scaffoldBackgroundColor: AppTokens.background,
      ),
      routerConfig: _router(),
    );
  }
}

// Where to land right after login (email links point here via AppLinks.postLoginCallUrl).
final postLoginTargetProvider = StateProvider<String>((_) => '/');

GoRouter _router() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final box = ProviderScope.containerOf(context, listen: false);
      final auth = box.read(authProvider);
      final loc = state.matchedLocation;
      final onAuth = loc.startsWith('/auth');
      const setupPath = '/profile/setup';
      if (!auth.loggedIn && !onAuth) {
        // Remember where the link pointed so login drops the user straight there.
        box.read(postLoginTargetProvider.notifier).state = loc;
        return auth.otpSent ? '/auth/otp' : '/auth';
      }
      if (auth.loggedIn && onAuth) {
        if (auth.profileLoading) return null; // wait for profile row before routing
        if (!auth.profileComplete) return setupPath;
        final next = box.read(postLoginTargetProvider);
        box.read(postLoginTargetProvider.notifier).state = '/';
        return next;
      }
      // Logged in but profile unfinished: gate everything behind setup.
      if (auth.loggedIn && !auth.profileLoading && !auth.profileComplete && loc != setupPath) {
        return setupPath;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/auth/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/profile/setup', builder: (_, __) => const ProfileSetupScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/call/:id', builder: (_, s) => CallScreen(callId: s.pathParameters['id']!)),
      GoRoute(path: '/history/:id', builder: (_, s) => RecordingDetailsScreen(recordingId: s.pathParameters['id']!)),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsHubScreen()),
      GoRoute(path: '/settings/privacy', builder: (_, __) => const PrivacySettingsScreen()),
      GoRoute(path: '/settings/notifications', builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(path: '/settings/security', builder: (_, __) => const SecuritySettingsScreen()),
      GoRoute(path: '/settings/blocked', builder: (_, __) => const BlockedUsersScreen()),
      GoRoute(path: '/settings/report', builder: (_, __) => const ReportUserScreen()),
      GoRoute(path: '/settings/account', builder: (_, __) => const AccountSettingsScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ],
  );
}
