import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client_provider.dart';
import '../../calls/pending_call.dart';
import '../../contacts/favorites_service.dart';
import '../../core/app_tokens.dart';
import '../../data/demo_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CallGuard'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/search'), icon: const Icon(Icons.person_add)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person)),
        ],
      ),
      body: Column(children: [
        const _OfflineBanner(),
        Expanded(child: _tab == 0 ? const _CallsTab() : const _HistoryTab()),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.call), label: 'Calls'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
        onDestinationSelected: (i) => setState(() => _tab = i),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/call/demo'),
        backgroundColor: AppTokens.primary,
        child: const Icon(Icons.video_call),
      ),
    );
  }
}

class _CallsTab extends ConsumerStatefulWidget {
  const _CallsTab();
  @override
  ConsumerState<_CallsTab> createState() => _CallsTabState();
}

class _CallsTabState extends ConsumerState<_CallsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(favoritesProvider.notifier).refresh());
  }

  Future<void> _call(String favUserId, String label) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await ref.read(apiClientProvider).createCall(favUserId);
      ref.read(pendingCallProvider.notifier).state = PendingCall(
        url: res['livekit_url'] as String,
        token: res['caller_token'] as String,
        callId: res['call_id'] as String,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, '/call/${res['call_id']}');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('Could not call $label — Retry')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = ref.watch(favoritesProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesProvider.notifier).refresh(),
      child: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.dialpad)),
            title: const Text('Dial a number or email'),
            subtitle: const Text('Works for unsaved people too'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/dial'),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Saved contacts', style: TextStyle(fontSize: 12, color: AppTokens.secondary)),
          ),
          if (favs.loading && favs.items.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
          else if (favs.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No saved contacts yet — find someone in Search and tap ☆',
                  style: TextStyle(color: AppTokens.secondary)),
            )
          else
            for (final f in favs.items)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text((f['display_name'] as String?)?.isNotEmpty == true
                    ? f['display_name'] as String
                    : 'CallGuard user'),
                trailing: IconButton(
                  onPressed: () => _call(f['id'] as String, 'contact'),
                  icon: const Icon(Icons.video_call, color: AppTokens.primary),
                ),
              ),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: demoHistory.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = demoHistory[i];
        return ListTile(
          title: Text('${r.who} — ${r.purpose}'),
          subtitle: Text('${r.minutes} min · ${r.quality} · ${r.status} · ${r.date} · deletes in ${r.deletesIn}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/history/${r.id}'),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
