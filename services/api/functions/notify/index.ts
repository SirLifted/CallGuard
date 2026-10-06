// Edge Function: notify both phones, same words everywhere.
// Plain language: the town crier. Push first (FCM/APNs), in-app message as backup.
// Same event → same sentence on Android and iOS, so nobody is misled.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

// Fixed wording per event (T0 parity rule). Changing copy means changing this one map.
const WORDING: Record<string, string> = {
  'incoming-call': 'Incoming call',
  'recording-request': 'Recording request — review purpose, minutes, quality',
  'recording-approved': 'Recording approved — saving starts',
  'recording-declined': 'Recording declined — no saving',
  'recording-started': 'Saving started',
  'recording-ending': 'Saving ends in 60 seconds',
  'recording-ended': 'Saving stopped',
  'extension-request': 'Extension request — review extra minutes',
  'consent-withdrawn': 'Recording stopped — consent withdrawn',
  'capture-detected': 'Screen capture noticed on the other phone — logged',
};

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const { user_id, type, data } = await req.json();
  const text = WORDING[type];
  if (!user_id || !text) return Response.json({ error: 'Not found' }, { status: 404 }); // uniform
  // TODO: INSERT notifications row (queued); try FCM (Android full-screen intent) / APNs PushKit;
  // on push failure keep row as queued → app pulls it over socket on next foreground (in-app fallback).
  // Blocked pairs never reach here: callers check is_blocked() first.
  return Response.json({ queued: true, text, data: data ?? {} });
});
