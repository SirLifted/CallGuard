// Backend client wired to the deployed Edge Functions + the signed-in session.
// Plain language: every call carries the user's login token, so the referee knows who asks.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_client.dart';

const functionsBaseUrl = 'https://iwmdibdddgxdaxqmugif.supabase.co/functions/v1';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: functionsBaseUrl,
    getToken: () async => Supabase.instance.client.auth.currentSession?.accessToken,
  );
});
