// Stage Q: recording countdown follows the server clock (display only, never decides).
import 'package:flutter_test/flutter_test.dart';
import 'package:callguard/recording/recording_service.dart';

void main() {
  test('starts idle with no label time', () {
    const s = RecState();
    expect(s.status, RecStatus.idle);
    expect(s.secondsLeft, 0);
  });

  test('approval sets countdown and label text (never color-only)', () {
    final svc = RecordingService();
    svc.onApproved(durationSec: 125, ticketExp: 'server-says-5-min');
    expect(svc.state.status, RecStatus.recording);
    expect(svc.state.secondsLeft, 125);
    expect(svc.state.indicatorLabel, '● RECORDING 02:05');
    expect(svc.state.ticketExp, 'server-says-5-min');
    svc.dispose();
  });

  test('withdraw and end clear the timer immediately', () {
    final svc = RecordingService();
    svc.onApproved(durationSec: 60, ticketExp: 'x');
    svc.onWithdrawn();
    expect(svc.state.status, RecStatus.withdrawn);
    expect(svc.state.secondsLeft, 0);
    svc.onEnded();
    expect(svc.state.status, RecStatus.ended);
    svc.dispose();
  });
}
