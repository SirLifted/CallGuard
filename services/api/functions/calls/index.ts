// Edge Function: create call + mint LiveKit room token.
// Plain language: the referee opens a relay room and hands each phone a ticket to enter.
// Recording tickets are separate (consent-ticket) — this one only lets you talk.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const { callee_id } = await req.json();
  const callerId = req.headers.get('x-user-id'); // TODO: derive from verified JWT
  if (!callerId || !callee_id) return Response.json({ error: 'Invalid call' }, { status: 400 });

  // TODO: is_blocked(caller, callee) → identical 404; INSERT calls + call_participants;
  // mint LiveKit AccessToken (room `call_<uuid>`, ttl 2h) via LIVEKIT_API_KEY/SECRET;
  // send FCM high-priority (Android full-screen intent) + APNs PushKit (iOS CallKit).
  const callId = 'stub-call-id';
  return Response.json({
    call_id: callId,
    livekit_url: 'wss://livekit.example',
    token: 'stub — mint via LiveKit AccessToken in Stage C env',
    note: 'callee gets push with same call_id',
  });
});
