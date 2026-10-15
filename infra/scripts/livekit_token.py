#!/usr/bin/env python3
"""Mint a LiveKit access token (dev). No dependencies.

Usage:
    python3 infra/scripts/livekit_token.py --room test123 --identity alice [--ttl 3600]

The app's call screen has a dev panel where this token gets pasted. Real deployments
mint this server-side (services/api/functions/calls) — never in the client.
"""
import argparse
import base64
import hashlib
import hmac
import json
import os
import time

# Dev defaults match infra/livekit.yaml (self-hosted box). Override with env for Cloud:
#   LIVEKIT_API_KEY / LIVEKIT_API_SECRET
API_KEY = os.environ.get('LIVEKIT_API_KEY', 'devkey')
API_SECRET = os.environ.get('LIVEKIT_API_SECRET', 'devsecretdevsecretdevsecretdevsecret')


def b64url(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b'=').decode()


def token(room: str, identity: str, name: str, ttl: int) -> str:
    now = int(time.time())
    header = {'alg': 'HS256', 'typ': 'JWT'}
    claims = {
        'iss': API_KEY,
        'nbf': now,
        'exp': now + ttl,
        'sub': identity,
        'name': name,
        'video': {'room': room, 'roomJoin': True, 'canPublish': True, 'canSubscribe': True},
    }
    signing = f'{b64url(json.dumps(header, separators=(",", ":")).encode())}.' \
              f'{b64url(json.dumps(claims, separators=(",", ":")).encode())}'
    sig = hmac.new(API_SECRET.encode(), signing.encode(), hashlib.sha256).digest()
    return f'{signing}.{b64url(sig)}'


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--room', required=True)
    p.add_argument('--identity', required=True)
    p.add_argument('--name', default='')
    p.add_argument('--ttl', type=int, default=3600)
    a = p.parse_args()
    print(token(a.room, a.identity, a.name or a.identity, a.ttl))
