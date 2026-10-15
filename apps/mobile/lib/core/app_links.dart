// Where email links land after Supabase confirms them.
// Must also be listed in Supabase → Authentication → URL Configuration → Redirect URLs.
class AppLinks {
  static const baseUrl = 'https://callguard-app.netlify.app';
  static const postLoginCallPath = '/call/demo';
  static String get postLoginCallUrl => '$baseUrl$postLoginCallPath';
}
