// Directory search (real backend) + dial-by-email/phone for unsaved people.
// Strangers all look identical: empty list. Nothing leaks who is registered.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client_provider.dart';
import '../../calls/pending_call.dart';
import '../../contacts/favorites_service.dart';
import '../../core/app_tokens.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _q = TextEditingController();
  bool _searching = false;
  bool _searched = false;
  String _error = '';
  List<Map<String, dynamic>> _results = const [];

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _q.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _searching = true;
      _searched = false;
      _error = '';
    });
    try {
      final res = await ref.read(apiClientProvider).searchPeople(q);
      if (!mounted) return;
      setState(() {
        _results = res;
        _searching = false;
        _searched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searched = true;
        _error = 'Could not search — Retry';
      });
    }
  }

  Future<void> _call(Map<String, dynamic> person) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await ref.read(apiClientProvider).createCall(person['id'] as String);
      ref.read(pendingCallProvider.notifier).state = PendingCall(
        url: res['livekit_url'] as String,
        token: res['caller_token'] as String,
        callId: res['call_id'] as String,
      );
      if (!mounted) return;
      context.go('/call/${res['call_id']}');
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not start call — Retry')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Find people')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _q,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  hintText: 'Name or email — saved or not',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _searching ? null : _search,
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
              child: _searching
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Find'),
            ),
          ]),
          const SizedBox(height: 8),
          const Text('Only registered people appear. Strangers always show as Not found.',
              style: TextStyle(fontSize: 12, color: AppTokens.secondary)),
          const SizedBox(height: 8),
          Expanded(
            child: _error.isNotEmpty
                ? Center(child: Text(_error))
                : !_searched
                    ? const Center(
                        child: Text('Search by name or email to call anyone — saved or not',
                            style: TextStyle(color: AppTokens.secondary)))
                    : _results.isEmpty
                        ? const Center(child: Text('Not found'))
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final p = _results[i];
                              final id = p['id'] as String;
                              final saved = favs.isFav(id);
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text((p['display_name'] as String?)?.isNotEmpty == true
                                    ? p['display_name'] as String
                                    : 'CallGuard user'),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: Icon(saved ? Icons.star : Icons.star_border,
                                        color: AppTokens.primary),
                                    onPressed: () =>
                                        ref.read(favoritesProvider.notifier).toggle(id),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _call(p),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTokens.primary),
                                    child: const Text('Call'),
                                  ),
                                ]),
                              );
                            },
                          ),
          ),
        ]),
      ),
    );
  }
}
