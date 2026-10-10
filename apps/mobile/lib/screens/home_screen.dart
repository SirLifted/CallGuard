import 'package:flutter/material.dart';
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

class _CallsTab extends StatelessWidget {
  const _CallsTab();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: demoContacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(demoContacts[i].name),
        subtitle: const Text('Last call: yesterday'),
        trailing: IconButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/call/demo'),
          icon: const Icon(Icons.video_call, color: AppTokens.primary),
        ),
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
