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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: code.length == 6 ? () => ctrl.confirmOtp(code) : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
              child: const Text('Verify'),
            ),
          ),
          TextButton(
            onPressed: _seconds == 0 ? ctrl.sendOtp : null,
            child: Text(_seconds == 0 ? 'Resend code' : 'Resend in $_seconds'),
          ),
        ]),
      ),
    );
  }
}
