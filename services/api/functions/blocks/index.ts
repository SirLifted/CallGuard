// Edge Function: block / unblock.
// Plain language: blocking is a wall both ways — no calls, requests, or popups either direction.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

serve(async (req) => {
  const url = new URL(req.url);
  const blockerId = req.headers.get('x-user-id'); // TODO(Stage B): derive from verified JWT, never trust header
  if (!blockerId) return Response.json({ error: 'Unauthorized' }, { status: 401 });

  if (req.method === 'POST') {
    const { blocked_id } = await req.json();
    if (!blocked_id || blocked_id === blockerId) {
      return Response.json({ error: 'Invalid user' }, { status: 400 }); // same message either way: no hints
    }
    // TODO: INSERT INTO blocks + revoke any live recording_auth_jwt between the pair + notify silently (no leak to blocked party)
    return Response.json({ ok: true, note: 'stub — wire Postgres in Stage B env' });
  }

  if (req.method === 'DELETE') {
    // TODO: DELETE FROM blocks WHERE blocker_id = blockerId AND blocked_id = ?
    return Response.json({ ok: true, note: 'stub — wire Postgres in Stage B env' });
  }

  return new Response('Method not allowed', { status: 405 });
});
