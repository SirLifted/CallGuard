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

  Future<void> approveRequest(String requestId) async {
    // Server returns the 5-min recording ticket (JWT). App never creates it.
    await http.post(Uri.parse('$baseUrl/recording-requests/$requestId/approve'), headers: await _headers());
  }

  Future<void> withdraw(String recordingId) async {
    // Server revokes ticket + tells relay to stop within 2s.
    await http.post(Uri.parse('$baseUrl/recordings/$recordingId/withdraw'), headers: await _headers());
  }

  Future<String> playbackUrl(String recordingId) async {
    final r = await http.get(Uri.parse('$baseUrl/recordings/$recordingId/playback-url'), headers: await _headers());
    return (jsonDecode(r.body) as Map)['url'] as String; // 5-min link, logged server-side
  }
}
