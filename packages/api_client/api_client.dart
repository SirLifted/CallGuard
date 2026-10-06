// Simple wrapper matching openapi.yaml. Plain language: every function = one referee check.
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Future<String?> Function() getToken;
  ApiClient({required this.baseUrl, required this.getToken});

  Future<Map<String, String>> _headers() async {
    final t = await getToken();
    return {'Content-Type': 'application/json', if (t != null) 'Authorization': 'Bearer $t'};
  }

  Future<void> requestOtp(String email) async {
    await http.post(Uri.parse('$baseUrl/auth/otp/request'), headers: await _headers(), body: jsonEncode({'email': email}));
  }

  Future<void> requestRecording(String callId, {required String purpose, required int durationSec, String quality = '720p'}) async {
    // Ask the other side. Server stores REQUESTED and pushes them to review.
    await http.post(Uri.parse('$baseUrl/calls/$callId/recording-requests'),
        headers: await _headers(), body: jsonEncode({'purpose': purpose, 'duration_sec': durationSec, 'quality': quality}));
  }

  Future<void> approveRequest(String requestId) async {
    // Server returns the 5-min recording ticket (JWT). App never creates it.
    await http.post(Uri.parse('$baseUrl/recording-requests/$requestId/approve'), headers: await _headers());
  }

  Future<void> withdraw(String recordingId) async {
    // Server revokes ticket + tells relay to stop within 2s.
    await http.post(Uri.parse('$baseUrl/recordings/$recordingId/withdraw'), headers: await _headers());
  }

  Future<void> requestExtension(String recordingId, int extraSec) async {
    // Extra minutes need a fresh yes. Server pushes the participant to review.
    await http.post(Uri.parse('$baseUrl/recordings/$recordingId/extension-requests'),
        headers: await _headers(), body: jsonEncode({'extra_sec': extraSec}));
  }

  Future<void> approveExtension(String extensionId) async {
    // Server revokes the old ticket and signs a fresh one. Decline keeps the old stop time.
    await http.post(Uri.parse('$baseUrl/extension-requests/$extensionId/approve'), headers: await _headers());
  }

  Future<List<Map<String, dynamic>>> listRecordings() async {
    // History page. Server only returns rows the viewer may see, newest first.
    final r = await http.get(Uri.parse('$baseUrl/recordings'), headers: await _headers());
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<void> deleteRecording(String recordingId) async {
    // Shreds bytes now (Delete button + Delete-forever confirm). Log entry stays per policy.
    await http.delete(Uri.parse('$baseUrl/recordings/$recordingId'), headers: await _headers());
  }

  Future<String> playbackUrl(String recordingId) async {
    final r = await http.get(Uri.parse('$baseUrl/recordings/$recordingId/playback-url'), headers: await _headers());
    return (jsonDecode(r.body) as Map)['url'] as String; // 5-min link, logged server-side
  }
}
