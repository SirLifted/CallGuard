// Stage F app side: in-app notice queue.
// Plain language: the backup crier. If a push never arrived (killed app, no net),
// the app pulls queued notices on foreground and shows the same sentences as push.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Notice {
  final String type;
  final String text;
  final String at;
  const Notice({required this.type, required this.text, required this.at});
}

class NoticeService extends StateNotifier<List<Notice>> {
  final Future<List<Notice>> Function() puller;
  NoticeService({required this.puller}) : super(const []);

  Future<void> sync() async {
    // Called on every foreground + after each call event. Server marks pulled rows delivered.
    state = await puller();
  }

  void dismiss(String at) {
    state = [for (final n in state) if (n.at != at) n];
  }
}
