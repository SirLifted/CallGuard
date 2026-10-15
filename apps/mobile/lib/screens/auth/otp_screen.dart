import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_tokens.dart';
import '../../auth/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _c = List.generate(6, (_) => TextEditingController());
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() async {
    while (_seconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds--);
    }
  }

  @override
  void dispose() {
    for (final t in _c) {
      t.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(authProvider.notifier);
    final code = _c.map((t) => t.text).join();

    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Enter code')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('We sent a 6-digit code to ${auth.email}',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Code sent — check your inbox and spam folder.',
                style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 44,
                height: 48,
                child: TextField(
                  controller: _c[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                    setState(() {});
                  },
                  decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          if (ref.watch(authProvider).error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(ref.watch(authProvider).error,
                  style: const TextStyle(color: AppTokens.error, fontSize: 13)),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (code.length == 6 && !ref.watch(authProvider).verifying)
                  ? () => ctrl.confirmOtp(code)
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
              child: ref.watch(authProvider).verifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Verify'),
            ),
          ),
          TextButton(
            onPressed: _seconds == 0
                ? () {
                    final messenger = ScaffoldMessenger.of(context);
                    ctrl.sendOtp().then((_) => messenger.showSnackBar(
                        const SnackBar(content: Text('New code sent — check inbox and spam'))));
                  }
                : null,
            child: Text(_seconds == 0 ? 'Resend code' : 'Resend in $_seconds'),
          ),
        ]),
      ),
    );
  }
}
