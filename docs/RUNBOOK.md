# Runbook — CYBERSHIELD-AI

## Quick Start

### Prerequisites

- Node.js >= 20.0.0
- Python >= 3.11
- MongoDB Atlas account (or local MongoDB)
- Redis (optional, required for auth-service rate limiting)

### Environment Setup

1. **Clone the repository**

```powershell
git clone <repository-url>
cd e:\cybershield-ai
```

2. **Configure environment variables**

Copy `.env` from the repository root and configure:

```text
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster-host>/cyber-police?retryWrites=true&w=majority
DB_NAME=cyber-police
JWT_SECRET=<your-secret-key>
PORT=5000
NODE_ENV=development
```

3. **Install dependencies**

```powershell
npm install
```

---

## Starting the Backend

### Express Backend (primary)

```powershell
# Start with file watching (development)
npm run dev

# Start without file watching
node backend/server.js
```

The server starts on **port 5000** and outputs:

```json
{"level":"info","message":"MongoDB connected"}
{"level":"info","message":"CyberShield-AI backend started","port":5000,"database":"cyber-police","environment":"development"}
```

### Verify Backend is Running

```powershell
# Root status
Invoke-RestMethod -Uri 'http://localhost:5000/'

# Health check
Invoke-RestMethod -Uri 'http://localhost:5000/health'

# API route listing
Invoke-RestMethod -Uri 'http://localhost:5000/api'

# System status dashboard
Invoke-RestMethod -Uri 'http://localhost:5000/system/status'

# Database collections
Invoke-RestMethod -Uri 'http://localhost:5000/database/collections'
```

### FastAPI Auth Service (separate process)

```powershell
# Set Python path
$env:PYTHONPATH="E:\cybershield-ai"

# Install Python dependencies
cd backend/services/auth-service
pip install -r requirements.txt

# Start auth service on port 5001
uvicorn main:app --reload --port 5001
```

---

## Connecting MongoDB

### Configuration

The backend connects to MongoDB Atlas using the `MONGODB_URI` environment variable.

**Connection details** (from `backend/shared/database/database.config.js`):

| Parameter | Default | Environment Variable |
|---|---|---|
| MongoDB URI | (required) | `MONGODB_URI` |
| Database Name | `cyber-police` | `DB_NAME` |
| Max Pool Size | 50 | `MONGO_MAX_POOL_SIZE` |
| Min Pool Size | 5 | `MONGO_MIN_POOL_SIZE` |
| Server Selection Timeout | 10000ms | `MONGO_SERVER_SELECTION_TIMEOUT_MS` |
| Socket Timeout | 45000ms | `MONGO_SOCKET_TIMEOUT_MS` |
| Connect Timeout | 10000ms | `MONGO_CONNECT_TIMEOUT_MS` |

### Verify MongoDB Connection

```powershell
node scripts/verify-mongodb.js
```

Expected output:
```json
{"status":"connected","database":"cyber-police","collections":[...]}
```

### Database Status Endpoint

```
GET /database/status
```

Returns:
```json
{
  "database": "cyber-police",
  "collections": ["users", "citizens", ...],
  "connected": true
}
```

---

## API Endpoints

### System

| Method | Path | Description |
|---|---|---|
| GET | `/` | Root status |
| GET | `/health` | Health check |
| GET | `/api` | API route listing |
| GET | `/system/status` | System health dashboard |

### Database

| Method | Path | Description |
|---|---|---|
| GET | `/database/status` | Database connection status |
| GET | `/database/collections` | Collection list with counts |

### Authentication

| Method | Path | Description |
|---|---|---|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login (returns JWT) |
| POST | `/api/auth/logout` | Logout |
| POST | `/api/auth/refresh` | Refresh access token |
| GET | `/api/auth/me` | Get user profile (requires JWT) |

---

## Running Tests

### Node.js Backend Tests

```powershell
# Run all backend tests
npm test

# Or run directly with node for startup tests
node --test backend/tests/
```

### Python Auth Service Tests

```powershell
cd backend/services/auth-service
$env:PYTHONPATH="E:\cybershield-ai"
python -m pytest tests/ -v
```

Expected output:
```
test_auth.py::test_auth_router_exposes_required_routes     PASSED
test_auth.py::test_argon2_and_jwt_are_used                  PASSED
test_mfa.py::test_mfa_service_uses_totp_and_recovery_codes  PASSED
test_mfa.py::test_mfa_routes_exist                          PASSED
test_rbac.py::test_rbac_middleware_checks_permissions_and_roles PASSED
test_rbac.py::test_default_permissions_are_documented       PASSED
test_sessions.py::test_session_service_supports_revocation  PASSED
test_sessions.py::test_refresh_token_rotation_exists        PASSED
```

**8/8 tests passed**

### Verification Scripts

```powershell
# Phase 1 verification
npm run phase1:verify

# Phase 2 verification (MongoDB)
npm run phase2:verify

# Phase 3 verification
powershell -ExecutionPolicy Bypass -File scripts/verify-phase3.ps1
```

---

## Troubleshooting

### Port Already in Use

```
Error: listen EADDRINUSE: address already in use :::5000
```

**Fix:**
```powershell
# Find process using port 5000
netstat -ano | findstr :5000

# Kill the process
taskkill /PID <PID> /F
```

### MongoDB Connection Failed

```
MongoDB disconnected
```

**Check:**
1. MongoDB URI in `.env` is correct
2. Network allows outbound connections to MongoDB Atlas
3. IP whitelist in MongoDB Atlas includes your IP

### Missing Environment Variables

```
Error: Missing required environment variable: MONGODB_URI
```

**Fix:** Ensure `.env` file exists in project root with all required variables.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                     Express Backend                  │
│                    (port 5000)                       │
│                                                      │
│  app.js                         server.js            │
│  ├── GET /                      ├── startServer()    │
│  ├── GET /health                ├── connectMongoDB() │
│  ├── GET /api                   ├── verifyIndexes()  │
│  ├── GET /system/status         └── verifyColls()    │
│  ├── POST /api/auth/register                         │
│  ├── POST /api/auth/login                            │
│  ├── POST /api/auth/refresh                          │
│  ├── GET /api/auth/me                                │
│  └── GET /database/collections                       │
│                                                      │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                  MongoDB Atlas                       │
│                (cyber-police)                        │
│                                                      │
│  Mongoose Models          Beanie Documents           │
│  ├── User                 ├── UserDocument           │
│  ├── Citizen              ├── RoleDocument           │
│  ├── PoliceOfficer        ├── SessionDocument        │
│  ├── AuditLog             ├── ApiKeyDocument         │
│  ├── Call                 ├── CallAnalysisDocument   │
│  └── ... (19 models)      └── ... (21 documents)     │
└─────────────────────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│              FastAPI Auth Service                    │
│               (port 5001)                           │
│                                                      │
│  JWT Authentication                                   │
│  MFA (TOTP)                                           │
│  RBAC                                                 │
│  API Keys                                             │
│  Audit Logging                                        │
└─────────────────────────────────────────────────────┘
```

## Project Structure

```
e:\cybershield-ai\
├── backend/
│   ├── server.js                    # Express entry point
│   ├── app.js                       # Express app + routes
│   ├── shared/
│   │   ├── database/                # MongoDB connection
│   │   ├── models/                  # Mongoose models (19)
│   │   ├── middlewares/             # Express middlewares
│   │   ├── routes/                  # Route handlers
│   │   ├── services/               # Business logic
│   │   └── security/               # Security utilities
│   └── services/
│       ├── auth-service/            # FastAPI auth (Phase 3)
│       └── *-service/               # 20 stub services
├── apps/
│   ├── citizen-android/            # Android app scaffold
│   ├── police-portal/              # Next.js scaffold
│   └── isp-portal/                 # Next.js scaffold
├── ai/
│   └── *-engine/                   # 9 AI service stubs
├── databases/
│   ├── mongo/                       # MongoDB configs
│   ├── neo4j/                       # Neo4j configs
│   └── redis/                       # Redis configs
├── infrastructure/
│   ├── docker/                      # Docker configs
│   ├── kubernetes/                  # K8s manifests
│   ├── terraform/                   # IaC configs
│   └── monitoring/                  # Prometheus/Grafana
├── docs/
│   ├── PROJECT_ANALYSIS.md          # Repository analysis
│   ├── API_ROUTES.md                # API documentation
│   ├── DATABASE_REPORT.md           # Database validation
│   ├── RUNBOOK.md                   # This file
│   └── PHASE3_VERIFICATION_REPORT.md
├── scripts/
│   └── verify-*.ps1/ts              # Verification scripts
└── .env                             # Environment variables