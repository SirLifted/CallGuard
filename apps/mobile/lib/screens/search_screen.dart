import 'package:flutter/material.dart';
import '../../core/app_tokens.dart';
import '../../data/demo_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';

  // Privacy rule (Stage B): missing OR blocked OR over-limit look identical — "Not found".
  List<DemoContact> get _results {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return demoContacts.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find people')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: const InputDecoration(
              hintText: 'Name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _q.trim().isEmpty
                ? const CgEmpty(text: 'Search by name to start a call')
                : _results.isEmpty
                    ? const CgEmpty(text: 'Not found')
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = _results[i];
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(c.name),
                            subtitle: Text('Recording purpose preset: ${c.purposeHint}'),
                            trailing: ElevatedButton(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/call/demo'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
                              child: const Text('Call'),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}

class CgEmpty extends StatelessWidget {
  final String text;
  const CgEmpty({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(fontSize: 14, color: AppTokens.secondary)));
  }
}
