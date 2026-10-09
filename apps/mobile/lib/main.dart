// T1 app shell: opens Home, proves tokens + router work. No real call yet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/app_tokens.dart';
import 'calls/call_service.dart';

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
            child: const Text('● ${AppTokens.recordingLabel} 00:00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

class CallStub extends ConsumerWidget {
  final String callId;
  const CallStub({super.key, required this.callId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(callServiceProvider);
    final svc = ref.read(callServiceProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text('Call $callId')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Status: ${call.status.name}${call.note.isEmpty ? '' : ' — ${call.note}'}'),
          const SizedBox(height: 12),
          // TODO(Stage C env): join with real url+token from POST /calls, after mic/cam permission explainer.
          ElevatedButton(
            onPressed: call.status == CallStatus.inCall ? null : () => svc.join(url: 'wss://livekit.example', token: 'TODO'),
            child: const Text('Join (needs server token)'),
          ),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _tog('Mic', call.micOn, svc.toggleMic),
            _tog('Cam', call.cameraOn, svc.toggleCamera),
            _tog('Spk', call.speakerOn, svc.toggleSpeaker),
          ]),
          TextButton(onPressed: svc.switchCamera, child: const Text('Switch camera')),
          TextButton(
              onPressed: () async {
                await svc.leave();
                if (context.mounted) context.go('/');
              },
              child: const Text('Leave')),
        ]),
      ),
    );
  }

  Widget _tog(String label, bool on, VoidCallback fn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(onPressed: fn, child: Text('$label ${on ? 'on' : 'off'}')),
    );
  }
}
