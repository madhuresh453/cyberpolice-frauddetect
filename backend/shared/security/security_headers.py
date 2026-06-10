from __future__ import annotations

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response: Response = await call_next(request)

        # Transport & clickjacking protections
        response.headers.setdefault("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload")
        response.headers.setdefault("X-Frame-Options", "DENY")

        # MIME sniffing protections
        response.headers.setdefault("X-Content-Type-Options", "nosniff")

        # Content security policy (strict baseline)
        # Adjust CSP for frontend needs in Phase 4+ if required.
        response.headers.setdefault(
            "Content-Security-Policy",
            "default-src 'none'; base-uri 'none'; frame-ancestors 'none'; form-action 'none';",
        )

        # Permissions policy (disable powerful features by default)
        response.headers.setdefault("Permissions-Policy", "geolocation=(), microphone=(), camera=(), payment=()")

        # Referrer policy + caching
        response.headers.setdefault("Referrer-Policy", "no-referrer")
        response.headers.setdefault("Cache-Control", "no-store")

        # Prevent basic information leakage
        response.headers.setdefault("X-DNS-Prefetch-Control", "off")

        return response

