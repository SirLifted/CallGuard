// Edge Function (cron): retention sweep — delete what's due, keep the notebook.
// Plain language: the janitor runs hourly. Old videos (bytes + thumbnails) are shredded,
// old play links die instantly, but the log entry (who/when/hash) stays ~12 months.
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';

serve(async (req) => {
  if (req.headers.get('x-cron-secret') !== 'stub-replace-in-vault') {
    return Response.json({ error: 'Not found' }, { status: 404 }); // uniform even here
  }

  // TODO per due recording (delete_at <= now(), status STOPPED, media_deleted_at IS NULL):
  //  1. DELETE R2 object + thumbnails (s3_key + derived keys).
  //  2. UPDATE recordings SET s3_key = NULL, media_deleted_at = now() (row stays: metadata + audit link survive).
  //     Old playback URLs were 5-min anyway; nothing cached server-side, so nothing to revoke.
  //  3. INSERT audit_events (REC_DELETED, system actor, content_sha256 of what was shredded).
  // Second sweep (daily): DELETE audit_events older than audit policy (e.g. 12 months).
  // Second sweep (daily): DELETE audit_events older than audit policy (e.g. 12 months).
  return Response.json({ swept: 0, note: 'stub — wire R2 + Postgres in Stage E env' });
});
