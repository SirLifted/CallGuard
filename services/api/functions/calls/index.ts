// Calls: open a relay room + mint each phone's entry ticket. Auth is real (Auth API check).
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
  const { callee_id } = await req.json();
  if (!callee_id || callee_id === me) return Response.json({ error: 'Not found' }, { status: 404 });

  // TODO(env): is_blocked(me, callee) → identical 404; INSERT calls + participants rows.
  const callId = crypto.randomUUID();
  const room = `call_${callId.replaceAll('-', '')}`;
  const key = Deno.env.get('LIVEKIT_API_KEY')!;
  const secret = Deno.env.get('LIVEKIT_API_SECRET')!;
  const grants = { roomJoin: true, canPublish: true, canSubscribe: true };
  const mint = (identity: string) =>
    new SignJWT({ video: { room, ...grants } })
      .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
      .setIssuer(key)
      .setSubject(identity)
      .setIssuedAt()
      .setExpirationTime('2h')
      .sign(new TextEncoder().encode(secret));

  return Response.json({
    call_id: callId,
    livekit_url: Deno.env.get('LIVEKIT_URL'),
    caller_token: await mint(me),
    // TODO(env): push callee via notify (their token minted on accept), in-app pull covers the test.
  });
});
