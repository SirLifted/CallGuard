// Edge Function: issue the 5-minute recording ticket after approval.
// Plain language: only this referee writes permission slips. The relay checks every slip.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { SignJWT } from 'https://deno.land/x/jose@v5.2.4/index.ts';

const TTL_SEC = 300; // 5 minutes, renewed only on approved extension

// Allowed moves. Anything else (double-approve, approve-after-withdraw) is rejected.
const ALLOWED: Record<string, string[]> = {
  REQUESTED: ['APPROVED', 'DECLINED', 'CANCELLED'],
  APPROVED: ['STARTED', 'CANCELLED'],
  STARTED: ['STOPPED', 'EXPIRED', 'CONSENT_WITHDRAWN', 'FAILED'],
};

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const parts = new URL(req.url).pathname.split('/');
  const requestId = parts[parts.length - 2]; // .../recording-requests/:id/approve
  const approverId = req.headers.get('x-user-id'); // TODO: derive from verified JWT
  if (!approverId || !requestId) return Response.json({ error: 'Invalid request' }, { status: 400 });

  // TODO: load recording_request + consent state in one transaction (SELECT FOR UPDATE):
  //  - request exists, status REQUESTED, not expired, approver is the participant (not requester)
  //  - is_blocked(requester, participant) is false
  //  - INSERT consents row, UPDATE status to APPROVED, INSERT recordings row (status APPROVED)
  //  - transition check: old status must be in ALLOWED[new] (mirror of 004 trigger)
  const jti = crypto.randomUUID();
  // TODO: sign with RECORDING_JWT_SECRET from Vault; claims below are the contract (see openapi.yaml)
  const jwt = await new SignJWT({ scope: { audio: true, video: true }, quality: '720p', duration_sec: 600 })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(requestId)
    .setJti(jti)
    .setIssuedAt()
    .setExpirationTime(`${TTL_SEC}s`)
    .sign(new TextEncoder().encode('stub-secret-replace-from-vault'));
  // TODO: SETEX recording_jwt:<jti> TTL_SEC "valid" in Upstash (withdraw deletes it; relay checks it)
  return Response.json({ recording_auth_jwt: jwt, jti, expires_in_sec: TTL_SEC });
});
