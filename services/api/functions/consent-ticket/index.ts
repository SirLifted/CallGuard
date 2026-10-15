// Consent ticket: approve → sign 5-min JWT, store revocable jti, START server-side save.
// Auth is real: the caller's Supabase access token is validated against Auth API.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { SignJWT } from 'https://deno.land/x/jose@v5.2.4/index.ts';

const TTL_SEC = 300;
const ALLOWED: Record<string, string[]> = {
  REQUESTED: ['APPROVED', 'DECLINED', 'CANCELLED'],
  APPROVED: ['STARTED', 'CANCELLED'],
  STARTED: ['STOPPED', 'EXPIRED', 'CONSENT_WITHDRAWN', 'FAILED'],
};

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

async function livekitServerJwt(room?: string): Promise<string> {
  const key = Deno.env.get('LIVEKIT_API_KEY')!;
  const secret = Deno.env.get('LIVEKIT_API_SECRET')!;
  return await new SignJWT({ video: { room: room ?? '', roomAdmin: true, roomRecord: true } })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setIssuer(key)
    .setIssuedAt()
    .setExpirationTime('2m')
    .sign(new TextEncoder().encode(secret));
}

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const me = await authedUserId(req);
  if (!me) return Response.json({ error: 'Not found' }, { status: 404 }); // uniform
  const parts = new URL(req.url).pathname.split('/');
  const requestId = parts[parts.length - 2];

  // TODO(env): load request row FOR UPDATE via pg ( Supabase REST with service key ):
  // verify REQUESTED, not expired, me == participant, !is_blocked. Skeleton assumes checks pass.
  void ALLOWED;

  const jti = crypto.randomUUID();
  const secret = Deno.env.get('RECORDING_JWT_SECRET')!;
  const jwt = await new SignJWT({ scope: { audio: true, video: true }, quality: '720p' })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(requestId)
    .setJti(jti)
    .setIssuedAt()
    .setExpirationTime(`${TTL_SEC}s`)
    .sign(new TextEncoder().encode(secret));

  // Revocable ticket: withdraw deletes this key (relay + app check it).
  const upstash = Deno.env.get('UPSTASH_REDIS_REST_URL')!;
  const uptok = Deno.env.get('UPSTASH_REDIS_REST_TOKEN')!;
  await fetch(`${upstash}/set/recording_jwt:${jti}/valid/EX/${TTL_SEC}`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${uptok}` },
  });

  // START the server-side save (room composite → R2, credentials explicit per request
  // so no server-side S3 config is needed on LiveKit Cloud).
  const body = await req.json().catch(() => ({}));
  const roomName = body.room_name ?? 'test123';
  const liveUrl = Deno.env.get('LIVEKIT_URL')!.replace('ws://', 'http://').replace('wss://', 'https://');
  const egress = await fetch(`${liveUrl}/twirp/livekit.Egress/StartRoomCompositeEgress`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${await livekitServerJwt(roomName)}` },
    body: JSON.stringify({
      room_name: roomName,
      layout: 'grid',
      output: {
        file: { filepath: `callguard/${requestId}.mp4` },
        s3: {
          access_key: Deno.env.get('R2_ACCESS_KEY_ID'),
          secret: Deno.env.get('R2_SECRET_ACCESS_KEY'),
          region: 'auto',
          endpoint: Deno.env.get('R2_ENDPOINT'),
          bucket: Deno.env.get('R2_BUCKET'),
        },
      },
    }),
  });
  const eg = await egress.json().catch(() => ({}));
  return Response.json({ recording_auth_jwt: jwt, jti, expires_in_sec: TTL_SEC, egress_id: eg.egressId ?? null });
});
