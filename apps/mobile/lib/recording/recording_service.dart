// Stage D app side: recording indicator + countdown.
// Plain language: the server owns the clock. This file only shows what the server said:
// how many seconds are left, and whether saving is on. It never decides to keep saving.
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecStatus { idle, requested, recording, ending, ended, withdrawn }

class RecState {
  final RecStatus status;
  final int secondsLeft;
  final String ticketExp; // server timestamp text for display only
  const RecState({this.status = RecStatus.idle, this.secondsLeft = 0, this.ticketExp = ''});

  // Indicator rule from T0: text + timer, never color alone.
  String get indicatorLabel {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '● RECORDING $m:$s';
  }

  RecState copyWith({RecStatus? status, int? secondsLeft, String? ticketExp}) {
    return RecState(
      status: status ?? this.status,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      ticketExp: ticketExp ?? this.ticketExp,
    );
  }
}

class RecordingService extends StateNotifier<RecState> {
  Timer? _timer;
  RecordingService() : super(const RecState());

  // Server says: approved with N seconds. We count down for display; server enforces the stop.
  void onApproved({required int durationSec, required String ticketExp}) {
    _timer?.cancel();
    state = RecState(status: RecStatus.recording, secondsLeft: durationSec, ticketExp: ticketExp);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.secondsLeft - 1;
      if (left <= 0) {
        t.cancel();
        state = state.copyWith(status: RecStatus.ending, secondsLeft: 0);
      } else {
        state = state.copyWith(secondsLeft: left, status: left <= 60 ? RecStatus.ending : RecStatus.recording);
      }
    });
  }

  void onWithdrawn() {
    _timer?.cancel();
    state = state.copyWith(status: RecStatus.withdrawn, secondsLeft: 0);
  }

  void onEnded() {
    _timer?.cancel();
    state = state.copyWith(status: RecStatus.ended, secondsLeft: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final recordingServiceProvider = StateNotifierProvider<RecordingService, RecState>((ref) => RecordingService());
