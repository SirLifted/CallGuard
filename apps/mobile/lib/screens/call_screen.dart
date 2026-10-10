import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_tokens.dart';
import '../../calls/call_service.dart';
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

  @override
  void dispose() {
    _purposeCtrl.dispose();
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
                    setState(() => _phase = ok ? RecordingPhase.active : RecordingPhase.none);
                    if (ok) recSvc.onApproved(durationSec: _minutes * 60, ticketExp: 'server ticket');
                  },
                ),
              if (_phase == RecordingPhase.active || _phase == RecordingPhase.ending)
                CgRecordingPill(timeText: _timeText),

              if (_phase == RecordingPhase.request)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
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
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _phase = RecordingPhase.review),
                            child: const Text('Ask to record'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () => setState(() => _phase = RecordingPhase.none), child: const Text('Cancel')),
                        ),
                      ]),
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
                      if (ok) {
                        recSvc.onWithdrawn();
                        setState(() => _phase = RecordingPhase.withdrawn);
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
