import time

import redis.asyncio as redis
from fastapi import HTTPException, Request, status

from backend.shared.database.database import get_settings

ROLE_LIMITS = {"citizen": 100, "police": 300, "isp": 500, "admin": 1000, "super_admin": 1000}
_redis: redis.Redis | None = None


async def get_redis() -> redis.Redis:
    global _redis
    if _redis is None:
        _redis = redis.from_url(get_settings().redis_url, decode_responses=True)
    return _redis


async def rate_limit_middleware(request: Request, call_next):
    if request.url.path in {"/health", "/database/status"}:
        return await call_next(request)
    role = getattr(getattr(request.state, "user", None), "user_type", "citizen")
    role_value = role.value if hasattr(role, "value") else str(role)
    limit = ROLE_LIMITS.get(role_value, 100)
    identity = request.headers.get("authorization") or (request.client.host if request.client else "unknown")
    bucket = int(time.time() // 60)
    key = f"rate:{role_value}:{identity}:{bucket}"
    client = await get_redis()
    count = await client.incr(key)
    if count == 1:
        await client.expire(key, 65)
    if count > limit:
        raise HTTPException(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail="Rate limit exceeded")
    return await call_next(request)
