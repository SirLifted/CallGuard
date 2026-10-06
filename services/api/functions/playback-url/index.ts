// Edge Function: permission-checked play link.
// Plain language: every watch asks the referee. 5-minute link, every view written in the notebook.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

const LINK_TTL_SEC = 300; // 5 minutes

serve(async (req) => {
  if (req.method !== 'GET') return new Response('Method not allowed', { status: 405 });
  const parts = new URL(req.url).pathname.split('/');
  const recordingId = parts[parts.length - 2]; // .../recordings/:id/playback-url
  const viewerId = req.headers.get('x-user-id'); // TODO: derive from verified JWT
  if (!viewerId || !recordingId) return Response.json({ error: 'Not found' }, { status: 404 }); // uniform: no hints

  // TODO in order:
  //  1. Load recording; viewer must be requester or participant (else identical 404).
  //  2. Status must be STOPPED (or ENDED equivalent); REQUESTED/APPROVED/STARTED → 409 identical.
  //     Deleted/expired (past delete_at) → 410 identical shape (no leak of which).
  //  3. Sign R2 URL with LINK_TTL_SEC expiry tied to viewer id (URL sharing fails for others).
  //  4. INSERT audit_events (REC_ACCESSED, viewer hash, content_sha256) — before returning the link.
  return Response.json({ url: 'stub-signed-r2-url', expires_in_sec: LINK_TTL_SEC });
});
