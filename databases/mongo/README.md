# MONGO

MongoDB Atlas configuration notes for the `cyber-police` database.

The production connection layer lives in:

- `backend/shared/database/mongodb.js`
- `backend/shared/database/database.config.js`
- `backend/shared/database/healthcheck.js`

All application schemas live in:

- `backend/shared/models/`

Atlas requirements:

- Use a dedicated database user with least-privilege access to `cyber-police`.
- Enable TLS.
- Restrict network access with Atlas IP access lists or private networking.
- Rotate credentials regularly.

## Phase Status

- Phase 1: directory created.
- Current: MongoDB Atlas-only integration implemented.

