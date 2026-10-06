// Stage Q: call starts idle and muted-neutral; join needs a real server token (no fake bypass).
import 'package:flutter_test/flutter_test.dart';
import 'package:callguard/calls/call_service.dart';

void main() {
  test('fresh call is idle with mic+camera+speaker on', () {
    final svc = CallService();
    expect(svc.state.status, CallStatus.idle);
    expect(svc.state.micOn, isTrue);
    expect(svc.state.cameraOn, isTrue);
    expect(svc.state.speakerOn, isTrue);
  });
}
