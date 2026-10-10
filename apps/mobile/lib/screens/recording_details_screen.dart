import 'package:flutter/material.dart';
import '../../core/app_tokens.dart';
import '../../data/demo_data.dart';

class RecordingDetailsScreen extends StatelessWidget {
  final String recordingId;
  const RecordingDetailsScreen({super.key, required this.recordingId});

  @override
  Widget build(BuildContext context) {
    final rec = demoHistory.firstWhere((r) => r.id == recordingId, orElse: () => demoHistory.first);

    return Scaffold(
      appBar: AppBar(title: const Text('Recording details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${rec.who} — ${rec.purpose}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${rec.minutes} min · ${rec.quality} · ${rec.status}'),
          Text('${rec.date} · Deletes in ${rec.deletesIn}'),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // DEMO: real flow signs a 5-min viewer-bound link (playback-url function).
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Play link arrives with backend wiring')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
                child: const Text('Play'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTokens.secondary),
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Delete — confirm dialog wired with backend'))),
                child: const Text('Delete'),
              ),
            ),
          ]),
          TextButton(onPressed: () {}, child: const Text('Report user')),
        ]),
      ),
    );
  }
}
