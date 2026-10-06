// Stage C: call state in plain language.
// The referee (backend) creates the room + hands each phone a token.
// This file only joins with that token, shows video, and handles mic/camera/speaker.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

enum CallStatus { idle, joining, inCall, reconnecting, left, failed }

class CallState {
  final CallStatus status;
  final bool micOn;
  final bool cameraOn;
  final bool speakerOn;
  final String note;
  const CallState({
    this.status = CallStatus.idle,
    this.micOn = true,
    this.cameraOn = true,
    this.speakerOn = true,
    this.note = '',
  });

  CallState copyWith({CallStatus? status, bool? micOn, bool? cameraOn, bool? speakerOn, String? note}) {
    return CallState(
      status: status ?? this.status,
      micOn: micOn ?? this.micOn,
      cameraOn: cameraOn ?? this.cameraOn,
      speakerOn: speakerOn ?? this.speakerOn,
      note: note ?? this.note,
    );
  }
}

class CallService extends StateNotifier<CallState> {
  Room? _room;
  CallService() : super(const CallState());

  // TODO(Stage C env): fetch url+token from POST /calls (calls function mints LiveKit token).
  Future<void> join({required String url, required String token}) async {
    state = state.copyWith(status: CallStatus.joining, note: 'Joining…');
    try {
      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );
      room.addListener(_onRoomUpdate);
      await room.connect(url, token);
      _room = room;
      state = state.copyWith(status: CallStatus.inCall, note: '');
    } catch (e) {
      state = state.copyWith(status: CallStatus.failed, note: 'Could not join: $e');
    }
  }

  void _onRoomUpdate() {
    // Weak net / switch: LiveKit fires reconnecting/reconnected; we mirror it, never drop silently.
    final r = _room;
    if (r == null) return;
    if (r.connectionState == ConnectionState.reconnecting) {
      state = state.copyWith(status: CallStatus.reconnecting, note: 'Reconnecting…');
    } else if (r.connectionState == ConnectionState.connected && state.status == CallStatus.reconnecting) {
      state = state.copyWith(status: CallStatus.inCall, note: '');
    }
  }

  Future<void> toggleMic() async {
    final next = !state.micOn;
    await _room?.localParticipant?.setMicrophoneEnabled(next);
    state = state.copyWith(micOn: next);
  }

  Future<void> toggleCamera() async {
    final next = !state.cameraOn;
    await _room?.localParticipant?.setCameraEnabled(next);
    state = state.copyWith(cameraOn: next);
  }

  Future<void> toggleSpeaker() async {
    final next = !state.speakerOn;
    await AudioManager.instance.setSpeakerOutputPreferred(next);
    state = state.copyWith(speakerOn: next);
  }

  bool _frontCamera = true;

  Future<void> switchCamera() async {
    final pubs = _room?.localParticipant?.videoTrackPublications;
    final track = (pubs != null && pubs.isNotEmpty) ? pubs.first.track : null;
    if (track == null) return;
    _frontCamera = !_frontCamera;
    await track.setCameraPosition(_frontCamera ? CameraPosition.front : CameraPosition.back);
  }

  Future<void> leave() async {
    await _room?.disconnect();
    _room?.removeListener(_onRoomUpdate);
    _room = null;
    state = state.copyWith(status: CallStatus.left, note: '');
  }
}

final callServiceProvider = StateNotifierProvider<CallService, CallState>((ref) => CallService());
