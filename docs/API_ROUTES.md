# API Routes — CYBERSHIELD-AI Backend

## Base URL

```
http://localhost:5000
```

---

## System Routes

| Method | Path | Description | Auth |
|---|---|---|---|
| GET | `/` | Root status — returns service name, version, database status | ❌ |
| GET | `/health` | Health check — returns healthy/unhealthy status | ❌ |
| GET | `/api` | Route listing — returns all registered routes | ❌ |
| GET | `/system/status` | System health dashboard — returns status of all components | ❌ |

### `GET /`

**Response:**
```json
{
  "name": "CYBERSHIELD-AI",
  "status": "running",
  "database": "connected",
  "version": "0.1.0"
}
```

### `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

### `GET /api`

**Response:**
```json
{
  "service": "CYBERSHIELD-AI Backend",
  "version": "0.1.0",
  "routes": [
    { "method": "GET", "path": "/", "description": "Root status" },
    { "method": "GET", "path": "/health", "description": "Health check" },
    { "method": "GET", "path": "/api", "description": "API route listing" },
    { "method": "GET", "path": "/system/status", "description": "System health dashboard" },
    { "method": "POST", "path": "/api/auth/register", "description": "Register new user" },
    { "method": "POST", "path": "/api/auth/login", "description": "User login" },
    { "method": "POST", "path": "/api/auth/logout", "description": "User logout" },
    { "method": "POST", "path": "/api/auth/refresh", "description": "Refresh access token" },
    { "method": "GET", "path": "/api/auth/me", "description": "Get current user profile" },
    { "method": "GET", "path": "/database/collections", "description": "List all collections" }
  ]
}
```

### `GET /system/status`

**Response:**
```json
{
  "backend": { "status": "online", "port": 5000, "environment": "development", "uptime": 82.89 },
  "database": { "status": "online", "name": "cyber-police", "readyState": "connected", "collections": [...] },
  "auth_service": { "status": "online", "type": "fastapi" },
  "ai_services": { "status": "not_implemented", "services": [...] }
}
```

---

## Database Routes

| Method | Path | Description | Auth |
|---|---|---|---|
| GET | `/database/status` | Database connection status and collection list | ❌ |
| GET | `/database/collections` | List all collections with document counts | ❌ |

### `GET /database/status`

**Response:**
```json
{
  "database": "cyber-police",
  "collections": ["users", "citizens", "audit_logs", ...],
  "connected": true
}
```

### `GET /database/collections`

**Response:**
```json
{
  "database": "cyber-police",
  "collections": [
    { "name": "users", "count": 0 },
    { "name": "citizens", "count": 0 }
  ]
}
```

---

## Authentication Routes

| Method | Path | Description | Auth |
|---|---|---|---|
| POST | `/api/auth/register` | Register a new user | ❌ |
| POST | `/api/auth/login` | Login and receive JWT tokens | ❌ |
| POST | `/api/auth/logout` | Logout current session | ❌ |
| POST | `/api/auth/refresh` | Refresh access token | ❌ |
| GET | `/api/auth/me` | Get current user profile | ✅ JWT |

### `POST /api/auth/register`

**Request:**
```json
{
  "email": "user@example.com",
  "phone_number": "+911234567890",
  "password": "strongPassword123!",
  "full_name": "John Doe",
  "user_type": "citizen"
}
```

**Response (201):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "phone_number": "+911234567890",
  "full_name": "John Doe",
  "role": "citizen",
  "status": "active",
  "created_at": "2026-06-10T14:00:00.000Z"
}
```

**Errors:**
- `400` — Missing required fields
- `409` — User already exists

### `POST /api/auth/login`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "strongPassword123!"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Errors:**
- `400` — Missing email or password
- `401` — Invalid credentials

### `POST /api/auth/refresh`

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Errors:**
- `400` — Missing refresh token
- `401` — Invalid or expired token

### `POST /api/auth/logout`

**Response (200):**
```json
{
  "status": "logged_out"
}
```

### `GET /api/auth/me`

**Headers Required:**
```
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "phone_number": "+911234567890",
  "full_name": "John Doe",
  "role": "citizen",
  "status": "active",
  "last_login_at": "2026-06-10T14:00:00.000Z"
}
```

**Errors:**
- `401` — Invalid or expired token
- `404` — User not found

---

## FastAPI Auth Service (separate)

The auth-service at `backend/services/auth-service/` runs as a standalone FastAPI service.

### Run Command
```powershell
cd backend/services/auth-service
uvicorn main:app --reload --port 5001
```

### FastAPI Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/auth/register` | Register with email/phone/password |
| POST | `/auth/login` | Login with MFA support |
| POST | `/auth/logout` | Logout (requires auth) |
| POST | `/auth/refresh` | Rotate refresh token |
| POST | `/auth/change-password` | Change password (requires auth) |
| POST | `/auth/forgot-password` | Request password reset |
| POST | `/auth/reset-password` | Reset password with token |
| POST | `/auth/mfa/setup` | Setup TOTP MFA (requires auth) |
| POST | `/auth/mfa/verify` | Verify and enable MFA (requires auth) |
| GET | `/auth/me` | Get current user (requires auth) |
| GET | `/sessions` | List active sessions (requires auth) |
| DELETE | `/sessions/{id}` | Revoke session (requires auth) |
| DELETE | `/sessions` | Revoke all sessions (requires auth) |
| GET | `/health` | Health check |
| GET | `/database/status` | Database status |

---

## Full Route Map

### Express Backend (port 5000)

```
GET  /
GET  /health
GET  /api
GET  /system/status
GET  /database/status
GET  /database/collections
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
GET  /api/auth/me
```

### FastAPI Auth Service (port 5001)

```
GET  /health
GET  /database/status
POST /auth/register
POST /auth/login
POST /auth/logout
POST /auth/refresh
POST /auth/change-password
POST /auth/forgot-password
POST /auth/reset-password
POST /auth/mfa/setup
POST /auth/mfa/verify
GET  /auth/me
GET  /sessions
DELETE /sessions/{id}
DELETE /sessions