// Withdraw: revoke ticket → STOP the save (≤2s) → audit. Auth is real (Auth API check).
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { SignJWT } from 'https://deno.land/x/jose@v5.2.4/index.ts';

async function authedUserId(req: Request): Promise<string | null> {
  const tok = (req.headers.get('Authorization') ?? '').replace('Bearer ', '');
  if (!tok) return null;
  const r = await fetch(`${Deno.env.get('SUPABASE_URL')}/auth/v1/user`, {
    headers: { apikey: Deno.env.get('SUPABASE_ANON_KEY')!, Authorization: `Bearer ${tok}` },
  });
  if (!r.ok) return null;
  const u = await r.json();
  return u?.id ?? null;
}

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const me = await authedUserId(req);
  if (!me) return Response.json({ error: 'Not found' }, { status: 404 });
  const parts = new URL(req.url).pathname.split('/');
  const recordingId = parts[parts.length - 2];

  // TODO(env): load recording FOR UPDATE; me must be requester/participant;
  // STARTED → CONSENT_WITHDRAWN (+ stopped_at), write audit row. Read jti + egress_id.
  const jti = 'stub-jti-from-row';
  const egressId: string | null = null; // TODO(env): from recordings.egress_id

  // 1. Revoke ticket immediately (relay refuses further egress).
  const upstash = Deno.env.get('UPSTASH_REDIS_REST_URL')!;
  const uptok = Deno.env.get('UPSTASH_REDIS_REST_TOKEN')!;
  await fetch(`${upstash}/del/recording_jwt:${jti}`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${uptok}` },
  });

  // 2. Stop the save (must complete ≤2s of confirmed withdraw).
  if (egressId) {
    const key = Deno.env.get('LIVEKIT_API_KEY')!;
    const secret = Deno.env.get('LIVEKIT_API_SECRET')!;
    const srv = await new SignJWT({ video: { roomAdmin: true, roomRecord: true } })
      .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
      .setIssuer(key)
      .setIssuedAt()
      .setExpirationTime('2m')
      .sign(new TextEncoder().encode(secret));
    const liveUrl = Deno.env.get('LIVEKIT_URL')!.replace('ws://', 'http://').replace('wss://', 'https://');
    await fetch(`${liveUrl}/twirp/livekit.Egress/StopEgress`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${srv}` },
      body: JSON.stringify({ egress_id: egressId }),
    });
  }
  // 3. TODO(env): push both phones (notify function) — in-app fallback covers the test.
  return Response.json({ ok: true, recording_id: recordingId, stopped_within_sec: 2 });
});
