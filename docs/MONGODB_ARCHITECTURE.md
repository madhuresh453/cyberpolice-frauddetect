# MongoDB Architecture

CyberShield AI uses MongoDB Atlas as the primary database for all future phases.

## Runtime

- Driver: Motor async client
- ODM: Beanie
- Validation: Pydantic v2
- Database: `cyber-police`
- Redis is retained only for rate limiting, JWT blacklist/cache, OTP cache, session cache, and WebSocket state.

## Transaction Use

Use MongoDB transactions for multi-document auth changes such as session revocation plus password changes, API key rotation plus audit log creation, and role/permission assignment plus audit log creation.

## Migration Report

Legacy SQL storage is no longer used by new services. Phase 3 uses MongoDB document models and shared repositories. Existing relational artifacts are not a dependency for auth-service.
