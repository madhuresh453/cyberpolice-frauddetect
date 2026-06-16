from __future__ import annotations

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response: Response = await call_next(request)

        # Skip strict CSP for API docs routes so Swagger UI can load
        path = request.url.path
        is_docs_route = path.startswith("/docs") or path.startswith("/redoc") or path.startswith("/openapi.json")

        # Transport & clickjacking protections
        response.headers.setdefault("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload")
        response.headers.setdefault("X-Frame-Options", "DENY")

        # MIME sniffing protections
        response.headers.setdefault("X-Content-Type-Options", "nosniff")

        # Content security policy
        if is_docs_route:
            # Relaxed CSP for Swagger UI / ReDoc to load CDN assets
            response.headers.setdefault(
                "Content-Security-Policy",
                "default-src 'self' 'unsafe-inline' 'unsafe-eval' https:; "
                "img-src 'self' data: https:; "
                "font-src 'self' https: data:; "
                "style-src 'self' 'unsafe-inline' https:; "
                "script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; "
                "base-uri 'self'; frame-ancestors 'self'; form-action 'self';",
            )
        else:
            # Strict baseline CSP for API routes
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

