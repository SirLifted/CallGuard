// First-run biodata: who the user is, before Home. Required once; editable later in Account.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_controller.dart';
import '../../core/app_tokens.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();
  final _dob = TextEditingController(); // YYYY-MM-DD
  final _location = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _middle.dispose();
    _last.dispose();
    _dob.dispose();
    _location.dispose();
    super.dispose();
  }

  bool get _valid =>
      _first.text.trim().isNotEmpty &&
      _last.text.trim().isNotEmpty &&
      _location.text.trim().isNotEmpty &&
      (_dob.text.isEmpty || RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_dob.text.trim()));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dob.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // Already complete (e.g. second device): skip straight through.
    if (!auth.profileLoading && auth.profileComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your profile'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tell us who you are. This is shown to people you call.',
              style: TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
          TextField(controller: _first, onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'First name *', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _middle,
              decoration: const InputDecoration(labelText: 'Middle name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _last, onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Last name *', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _dob,
            readOnly: true,
            onTap: _pickDate,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
                labelText: 'Date of birth (tap to pick)', border: OutlineInputBorder(), hintText: 'YYYY-MM-DD'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _location, onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Location (city, country) *', border: OutlineInputBorder())),
          if (auth.error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(auth.error, style: const TextStyle(color: AppTokens.error, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (!_valid || _saving)
                  ? null
                  : () {
                      // Capture the router BEFORE the async gap: no BuildContext
                      // crosses the await, so there is nothing to guard.
                      final router = GoRouter.of(context);
                      () async {
                        setState(() => _saving = true);
                        await ref.read(authProvider.notifier).saveProfile(
                              first: _first.text,
                              middle: _middle.text,
                              last: _last.text,
                              dob: _dob.text.trim(),
                              location: _location.text,
                            );
                        if (!mounted) return;
                        setState(() => _saving = false);
                        if (ref.read(authProvider).profileComplete) router.go('/');
                      }();
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save and continue'),
            ),
          ),
        ]),
      ),
    );
  }
}
