// A call the server just opened for us: relay address + our entry ticket + room id.
// Set right before navigating to /call/:id; the call screen joins once, then clears it.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingCall {
  final String url;
  final String token;
  final String callId;
  const PendingCall({required this.url, required this.token, required this.callId});
}

final pendingCallProvider = StateProvider<PendingCall?>((_) => null);
