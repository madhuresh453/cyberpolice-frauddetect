# MongoDB Atlas Setup

## Folder Structure

```text
backend/
  app.js
  server.js
  Dockerfile
  shared/
    database/
      database.config.js
      healthcheck.js
      mongodb.js
    middlewares/
      databaseHealth.middleware.js
      errorHandler.middleware.js
      requestLogger.middleware.js
    models/
      AdminUser.js
      AIPrediction.js
      AuditLog.js
      BlocklistNumber.js
      Call.js
      CallRecording.js
      Citizen.js
      Complaint.js
      DeviceToken.js
      FIRReport.js
      FraudPattern.js
      ISPReport.js
      Location.js
      Notification.js
      PoliceOfficer.js
      ScamAlert.js
      User.js
      Voiceprint.js
      WhitelistNumber.js
      base.js
      index.js
    repositories/
      base.repository.js
      index.js
    routes/
      health.routes.js
    services/
      auditLog.service.js
      index.js
      mongodb.service.js
      transaction.service.js
scripts/
  seeds/
    seed-demo-data.js
  verify-mongodb.js
```

## Installation Commands

```powershell
npm install
```

This installs `mongoose`, `dotenv`, and `express`.

## Environment

Create `.env` from `.env.example`:

```powershell
Copy-Item .env.example .env
```

Set:

```text
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster-host>/cyber-police?retryWrites=true&w=majority
DB_NAME=cyber-police
PORT=5000
JWT_SECRET=<strong-secret>
NODE_ENV=development
```

## Run Commands

```powershell
npm run db:verify
npm run seed
npm run dev
```

## Startup Sequence

The backend startup sequence in `backend/server.js` is:

1. Load environment variables.
2. Connect to MongoDB Atlas.
3. Verify indexes.
4. Verify collections.
5. Start Express server.

## MongoDB Connection Verification

```powershell
npm run db:verify
```

Expected response:

```json
{
  "status": "ok",
  "database": "cyber-police",
  "connected": true,
  "collections": []
}
```

## API Testing Examples

Health:

```powershell
Invoke-RestMethod http://localhost:5000/health
```

Expected response:

```json
{
  "status": "healthy",
  "database": "connected"
}
```

Database status:

```powershell
Invoke-RestMethod http://localhost:5000/database/status
```

Expected response:

```json
{
  "database": "cyber-police",
  "collections": [],
  "connected": true
}
```

## Seed Commands

```powershell
npm run seed
```

Seeds:

- admin user
- police user
- citizen user
- demo scam call
- demo FIR
- demo alert
- demo AI prediction
- demo complaint

## Docker Commands

```powershell
docker compose up --build backend
docker compose logs -f backend
docker compose down
```

## Troubleshooting

- `Missing required environment variable`: confirm `.env` contains `MONGODB_URI`, `DB_NAME`, and `JWT_SECRET`.
- `DB_NAME must be exactly cyber-police`: set `DB_NAME=cyber-police`.
- `MongoServerSelectionError`: verify Atlas network access, credentials, DNS, and cluster status.
- `authentication failed`: rotate the Atlas database password and update `MONGODB_URI`.
- Health endpoint returns `503`: check backend logs and run `pnpm db:verify`.
- Docker container exits immediately: confirm `MONGODB_URI` and `JWT_SECRET` are passed into Docker Compose.

## Security Best Practices

- Keep `MONGODB_URI` and `JWT_SECRET` out of source control.
- Use least-privilege Atlas users.
- Restrict Atlas access with IP allowlists or private networking.
- Require TLS for MongoDB connections.
- Rotate database credentials and JWT secrets.
- Store recordings and sensitive evidence encrypted outside the database; store only metadata and encrypted storage URIs.
- Never log secrets, tokens, raw OTPs, passwords, or full evidence content.
- Enable Atlas backups and audit logging for production clusters.
