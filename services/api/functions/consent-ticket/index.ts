// Supabase Edge Function (Deno): issues the 5-minute recording ticket after approval.
// Plain language: only this referee can write permission slips. The app and relay both trust it.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

const TTL_SEC = 300; // 5 minutes, renewed only on approved extension

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const { call_id, request_id, participants, scope, quality, duration_sec } = await req.json();

  // TODO(Stage D): verify in Postgres that request is APPROVED, caller is participant,
  // no block exists between parties, then sign a real JWT (jose) with jti + exp.
  // TODO: store jti in Upstash Redis with 5-min TTL so withdraw can revoke it.
  const ticket = { call_id, request_id, participants, scope, quality, duration_sec, exp_in_sec: TTL_SEC, note: 'stub — sign JWT in Stage D' };
  return Response.json({ recording_auth_jwt: ticket });
});
