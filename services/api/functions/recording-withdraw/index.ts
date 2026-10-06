// Edge Function: withdraw consent — stops the save within 2 seconds.
// Plain language: tear up the permission slip, tell the relay to stop, tell both phones, write it in the notebook.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const parts = new URL(req.url).pathname.split('/');
  const recordingId = parts[parts.length - 2]; // .../recordings/:id/withdraw
  const actorId = req.headers.get('x-user-id'); // TODO: derive from verified JWT
  if (!actorId || !recordingId) return Response.json({ error: 'Invalid request' }, { status: 400 });

  // TODO in one transaction (SELECT FOR UPDATE on recordings row):
  //  - recording exists and actor is requester or participant (else identical 404 — no hints)
  //  - status is STARTED (APPROVED without STARTED → CANCELLED instead; terminal states → 409 identical)
  //  - UPDATE status to CONSENT_WITHDRAWN, stopped_at = now()
  //  - INSERT audit_events row (CONSENT_WITHDRAWN, actor hash, content_sha256 of partial file)
  // Then, outside the transaction, in order:
  //  1. DEL recording_jwt:<jti> in Upstash (relay refuses further egress immediately)
  //  2. POST LiveKit stop-egress for the room (must complete ≤2s of the confirmed withdraw)
  //  3. Push to both phones: recording stopped — consent withdrawn (FCM + APNs, in-app fallback)
  return Response.json({ ok: true, stopped_within_sec: 2, note: 'stub — wire Postgres/Upstash/LiveKit in Stage D env' });
});
