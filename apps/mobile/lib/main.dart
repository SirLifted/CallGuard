// T1 app shell: opens Home, proves tokens + router work. No real call yet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../packages/tokens/app_tokens.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomeStub()),
    GoRoute(path: '/call/:id', builder: (c, s) => CallStub(callId: s.pathParameters['id']!)),
  ],
);

void main() => runApp(const ProviderScope(child: CallGuardApp()));

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
      routerConfig: _router,
    );
  }
}

class HomeStub extends StatelessWidget {
  const HomeStub({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CallGuard (T1 shell)')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Recording pill proves the never-color-only rule from T0.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppTokens.recordingAlert, borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
            child: Text('● ${AppTokens.recordingLabel} 00:00', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/call/demo'),
            child: const Text('Open call stub'),
          ),
        ]),
      ),
    );
  }
}

class CallStub extends StatelessWidget {
  final String callId;
  const CallStub({super.key, required this.callId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Call $callId')), body: const Center(child: Text('LiveKit joins here in Stage C.')));
  }
}
