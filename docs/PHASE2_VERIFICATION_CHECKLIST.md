# Phase 2 Verification Checklist

## Scope

Phase 2 now uses MongoDB Atlas as the only database.

## Verification

- `MONGODB_URI` is loaded from `.env`.
- `DB_NAME` is exactly `cyber-police`.
- Backend connects through Mongoose.
- Indexes are verified with `syncIndexes`.
- Collections are verified at startup.
- Health endpoints exist:
  - `GET /health`
  - `GET /database/status`
- Seed script exists under `scripts/seeds/`.
- Docker Compose runs only the backend service and uses Atlas through environment variables.

## Test

```powershell
npm run db:verify
```

## Run

```powershell
npm install
npm run seed
npm run dev
```
