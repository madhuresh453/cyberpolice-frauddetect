# Phase 3 Verification Checklist

- MongoDB migration report exists in `docs/MONGODB_ARCHITECTURE.md`.
- Collection schema exists in `docs/COLLECTION_SCHEMA.md`.
- Index strategy exists in `docs/INDEXING_STRATEGY.md`.
- Auth service includes FastAPI app, routers, services, schemas, middleware, tests, Dockerfile, requirements, and README.
- JWT access tokens expire in 15 minutes.
- Refresh sessions expire in 30 days and rotate on refresh.
- MFA supports TOTP and recovery codes.
- RBAC checks roles and permissions.
- Redis rate limits by role.
- Audit service records security actions.
- Static verification passes with `scripts/verify-phase3.ps1`.
