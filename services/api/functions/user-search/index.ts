// Edge Function: private user search.
// Plain language: strangers must not learn who uses CallGuard. Missing, blocked, and
// over-limit all look identical from outside: 404 with the same body.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

const LIMIT_PER_MIN = 30;
const IDENTICAL_MISS = { error: 'Not found' };

serve(async (req) => {
  const url = new URL(req.url);
  const q = (url.searchParams.get('q') ?? '').trim().slice(0, 64);
  const searcherId = req.headers.get('x-user-id'); // TODO: derive from verified JWT
  if (!searcherId) return Response.json(IDENTICAL_MISS, { status: 404 }); // uniform: no hint that auth failed
  if (!q) return Response.json(IDENTICAL_MISS, { status: 404 });

  // TODO: check rate_limits (30/min per user); on exceed return IDENTICAL_MISS 404 (not 429 — 429 leaks existence timing)
  // TODO: SELECT * FROM search_users(searcher_id, q) — block-filtered, max 10 rows
  return Response.json({ results: [], note: 'stub — wire Postgres in Stage B env' });
});
