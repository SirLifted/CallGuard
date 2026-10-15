// Dial pad: call anyone by typing their email or phone — no saving needed.
// Same directory lookup as search; unsaved people work identically once found.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client_provider.dart';
import '../../calls/pending_call.dart';
import '../../core/app_tokens.dart';

class DialScreen extends ConsumerStatefulWidget {
  const DialScreen({super.key});
  @override
  ConsumerState<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends ConsumerState<DialScreen> {
  final _q = TextEditingController();
  bool _busy = false;
  String _note = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _dial() async {
    final q = _q.text.trim();
    if (q.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _note = 'Looking up…';
    });
    try {
      final api = ref.read(apiClientProvider);
      final found = await api.searchPeople(q);
      if (!mounted) return;
      if (found.isEmpty) {
        setState(() {
          _busy = false;
          _note = 'Not found — check the spelling or ask them to join CallGuard';
        });
        return;
      }
      final person = found.first;
      final res = await api.createCall(person['id'] as String);
      ref.read(pendingCallProvider.notifier).state = PendingCall(
        url: res['livekit_url'] as String,
        token: res['caller_token'] as String,
        callId: res['call_id'] as String,
      );
      if (!mounted) return;
      context.go('/call/${res['call_id']}');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _note = 'Could not place call — Retry';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dial')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _q,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _dial(),
            decoration: const InputDecoration(
              hintText: 'Email or phone number',
              prefixIcon: Icon(Icons.dialpad),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _dial,
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
              child: _busy
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Call now'),
            ),
          ),
          const SizedBox(height: 12),
          if (_note.isNotEmpty) Text(_note, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          const Text('Works for unsaved people too — if they are registered, the call goes through.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTokens.secondary)),
        ]),
      ),
    );
  }
}
