# Auth Service

FastAPI authentication and authorization service for CyberShield AI Phase 3.

## Database

MongoDB Atlas is the primary database. This service uses Motor, Beanie, and Pydantic v2 for persistence.

Required environment:

```text
MONGODB_URI=
DB_NAME=cyber-police
REDIS_URL=redis://localhost:6379/0
JWT_SECRET=
JWT_ALGORITHM=HS256
ACCESS_TOKEN_MINUTES=15
REFRESH_TOKEN_DAYS=30
PORT=5000
NODE_ENV=development
```

## Run

```powershell
cd backend/services/auth-service
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
$env:PYTHONPATH="E:\cybershield-ai"
uvicorn main:app --reload --port 5000
```

## Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`
- `POST /auth/refresh`
- `POST /auth/change-password`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/mfa/setup`
- `POST /auth/mfa/verify`
- `GET /auth/me`
- `GET /sessions`
- `DELETE /sessions/{session_id}`
- `DELETE /sessions`
- `GET /health`
- `GET /database/status`
