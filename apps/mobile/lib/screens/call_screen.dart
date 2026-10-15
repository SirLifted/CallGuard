import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client_provider.dart';
import '../../calls/call_service.dart';
import '../../calls/pending_call.dart';
import '../../core/app_tokens.dart';
import '../../recording/recording_service.dart';
import '../../widgets/cg_dialogs.dart';
import '../../widgets/cg_widgets.dart';

enum RecordingPhase { none, request, review, active, ending, ended, withdrawn }

class CallScreen extends ConsumerStatefulWidget {
  final String callId;
  const CallScreen({super.key, required this.callId});
  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  RecordingPhase _phase = RecordingPhase.none;
  int _minutes = 10;
  String _quality = '720p';
  final _purposeCtrl = TextEditingController(text: 'Meeting notes');
  // DEV defaults: LiveKit Cloud project. Real flow mints these server-side.
  final _urlCtrl = TextEditingController(text: 'wss://callguard-4itf8l4t.livekit.cloud');
  final _roomCtrl = TextEditingController(text: 'test123');
  final _tokenCtrl = TextEditingController();
  // DEV test plumbing: request id typed by tester, egress id returned by server.
  final _reqIdCtrl = TextEditingController(text: 'dev-req-1');
  String? _egressId;
  String _apiNote = '';

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _urlCtrl.dispose();
    _roomCtrl.dispose();
    _tokenCtrl.dispose();
    _reqIdCtrl.dispose();
    super.dispose();
  }

  String get _timeText {
    final s = ref.watch(recordingServiceProvider).secondsLeft;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(callServiceProvider);
    final callSvc = ref.read(callServiceProvider.notifier);
    final recSvc = ref.read(recordingServiceProvider.notifier);

    // Server-opened call (Search/Dial/Favorites): join once with its ticket, then clear it.
    ref.listen<PendingCall?>(pendingCallProvider, (_, next) {
      if (next != null && ref.read(callServiceProvider).status == CallStatus.idle) {
        callSvc.join(url: next.url, token: next.token);
        ref.read(pendingCallProvider.notifier).state = null;
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Call ${widget.callId}')),
      body: Column(children: [
        const CgOfflineBanner(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text('Status: ${call.status.name}${call.note.isEmpty ? '' : ' — ${call.note}'}'),
              if (_phase == RecordingPhase.review)
                CgNotice(
                  text: 'Recording request — review purpose, minutes, quality',
                  actionLabel: 'Review',
                  onAction: () async {
                    final ok = await cgRequestDialog(context,
                        who: 'Ada Obi',
                        purpose: _purposeCtrl.text,
                        minutes: _minutes,
                        quality: _quality,
                        audio: true,
                        video: true);
                    if (!mounted) return;
                    if (!ok) {
                      setState(() => _phase = RecordingPhase.none);
                      return;
                    }
                    // REAL approve: server signs ticket + starts the server-side save.
                    setState(() {
                      _phase = RecordingPhase.active;
                      _apiNote = 'Asking server…';
                    });
                    try {
                      final api = ref.read(apiClientProvider);
                      final res = await api.approveRequest(
                          _reqIdCtrl.text.trim().isEmpty ? 'dev-req-1' : _reqIdCtrl.text.trim(),
                          roomName: _roomCtrl.text.trim().isEmpty ? 'test123' : _roomCtrl.text.trim());
                      if (!mounted) return;
                      setState(() {
                        _egressId = res['egress_id'] as String?;
                        _apiNote = 'Server saving → egress ${_egressId ?? 'pending'}';
                      });
                      recSvc.onApproved(
                          durationSec: (res['expires_in_sec'] as int?) ?? _minutes * 60,
                          ticketExp: 'server ticket ${(res['jti'] as String?) ?? ''}');
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        _phase = RecordingPhase.none;
                        _apiNote = 'Server refused: $e';
                      });
                    }
                  },
                ),
              if (_apiNote.isNotEmpty) Text(_apiNote, style: const TextStyle(fontSize: 12, color: AppTokens.secondary)),
              if (_phase == RecordingPhase.active || _phase == RecordingPhase.ending)
                CgRecordingPill(timeText: _timeText),

              if (_phase == RecordingPhase.request)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('DEV JOIN — paste a LiveKit token (URL prefilled)',
                            style: TextStyle(fontSize: 12, color: AppTokens.secondary)),
                      ),
                      TextField(
                        controller: _urlCtrl,
                        decoration: const InputDecoration(labelText: 'Server URL', border: OutlineInputBorder()),
                      ),
                      TextField(
                        controller: _roomCtrl,
                        decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder()),
                      ),
                      TextField(
                        controller: _tokenCtrl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Token', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => callSvc.join(url: _urlCtrl.text.trim(), token: _tokenCtrl.text.trim()),
                            child: const Text('Join room'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () => setState(() => _phase = RecordingPhase.none), child: const Text('Cancel')),
                        ),
                      ]),
                      const Divider(height: 32),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('RECORDING REQUEST (demo dialog)',
                            style: TextStyle(fontSize: 12, color: AppTokens.secondary)),
                      ),
                      TextField(
                        controller: _purposeCtrl,
                        decoration: const InputDecoration(labelText: 'Purpose', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Text('Minutes: $_minutes')),
                        Slider(
                          value: _minutes.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          onChanged: (v) => setState(() => _minutes = v.round()),
                        ),
                      ]),
                      DropdownButtonFormField<String>(
                        initialValue: _quality,
                        items: const [
                          DropdownMenuItem(value: '480p', child: Text('480p')),
                          DropdownMenuItem(value: '720p', child: Text('720p')),
                          DropdownMenuItem(value: '1080p', child: Text('1080p')),
                        ],
                        onChanged: (v) => setState(() => _quality = v ?? '720p'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reqIdCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Request ID (dev test plumbing)',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _phase = RecordingPhase.review),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
                          child: const Text('Ask to record'),
                        ),
                      ),
                    ]),
                  ),
                ),

              if (_phase == RecordingPhase.none)
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _tog('Mic', call.micOn, callSvc.toggleMic),
                  _tog('Cam', call.cameraOn, callSvc.toggleCamera),
                  _tog('Spk', call.speakerOn, callSvc.toggleSpeaker),
                ]),
              TextButton(onPressed: callSvc.switchCamera, child: const Text('Switch camera')),
              if (_phase == RecordingPhase.none || _phase == RecordingPhase.request)
                ElevatedButton(
                  onPressed: () => setState(() => _phase = RecordingPhase.request),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
                  child: const Text('Start recording request'),
                ),
              if (_phase == RecordingPhase.active)
                Column(children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _phase = RecordingPhase.ending),
                    child: const Text('Extend (+5 min)'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final ok = await cgWithdrawDialog(context);
                      if (!mounted) return;
                      if (!ok) return;
                      // REAL withdraw: server revokes ticket + stops the save ≤2s.
                      setState(() => _apiNote = 'Stopping save…');
                      try {
                        final api = ref.read(apiClientProvider);
                        final rid = _reqIdCtrl.text.trim().isEmpty ? 'dev-req-1' : _reqIdCtrl.text.trim();
                        await api.withdraw(rid, egressId: _egressId);
                        if (!mounted) return;
                        recSvc.onWithdrawn();
                        setState(() {
                          _phase = RecordingPhase.withdrawn;
                          _apiNote = 'Server stopped the save';
                        });
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => _apiNote = 'Stop failed: $e');
                      }
                    },
                    child: const Text('Withdraw consent'),
                  ),
                ]),
              if (_phase == RecordingPhase.withdrawn || _phase == RecordingPhase.ended)
                const Text('Recording saved or stopped — check History.'),
              TextButton(
                onPressed: () {
                  callSvc.leave();
                  context.go('/');
                },
                child: const Text('Leave call'),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _tog(String label, bool on, VoidCallback fn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(onPressed: fn, child: Text('$label ${on ? 'on' : 'off'}')),
    );
  }
}
