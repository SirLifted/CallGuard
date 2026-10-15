import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_tokens.dart';
import '../../../auth/auth_controller.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final ctrl = ref.read(authProvider.notifier);
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(auth.email);

    return Scaffold(
      appBar: AppBar(title: const Text('CallGuard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Private calls, saved only with permission.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          const Text('Email'),
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: ctrl.setEmail,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              errorText: auth.email.isEmpty || emailOk ? null : 'Enter a valid email',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (emailOk && !auth.sending) ? ctrl.sendOtp : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
              child: auth.sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send code'),
            ),
          ),
          const SizedBox(height: 8),
          const Text('No password to lose. Recordings only start after the other side says yes.',
              style: TextStyle(fontSize: 12, color: AppTokens.secondary)),
        ]),
      ),
    );
  }
}
