// Edge Function: recording extension — extra minutes need a fresh yes, never silent.
// Plain language: when time runs low the asker begs for more; only a new approval extends the slip.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { SignJWT } from 'https://deno.land/x/jose@v5.2.4/index.ts';

const TTL_SEC = 300;

serve(async (req) => {
  const url = new URL(req.url);
  const actorId = req.headers.get('x-user-id'); // TODO: derive from verified JWT
  if (!actorId) return Response.json({ error: 'Invalid request' }, { status: 400 });

  if (req.method === 'POST' && url.pathname.endsWith('/extension-requests')) {
    const recordingId = url.pathname.split('/').slice(-3, -2)[0];
    const { extra_sec } = await req.json();
    // TODO: recording is STARTED, asker is requester, extra_sec within cap (e.g. ≤600);
    // INSERT extension request (status REQUESTED), push participant to review.
    return Response.json({ ok: true, recording_id: recordingId, note: 'stub — wire Postgres in Stage D env' });
  }

  if (req.method === 'POST' && url.pathname.includes('/extension-requests/')) {
    const extId = url.pathname.split('/').pop();
    // TODO: approver is participant, request still REQUESTED and recording still STARTED;
    // approve → revoke old jti, sign new JWT (fresh jti + TTL), update recordings.delete_at/expires.
    // decline → recording keeps its original stop time, both notified.
    const jwt = await new SignJWT({ extended: true })
      .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
      .setSubject(extId!)
      .setJti(crypto.randomUUID())
      .setIssuedAt()
      .setExpirationTime(`${TTL_SEC}s`)
      .sign(new TextEncoder().encode('stub-secret-replace-from-vault'));
    return Response.json({ recording_auth_jwt: jwt, expires_in_sec: TTL_SEC });
  }

  return new Response('Method not allowed', { status: 405 });
});
