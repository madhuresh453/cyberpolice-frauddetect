# CyberShield AI Authentication

Phase 3 implements FastAPI authentication over MongoDB Atlas with Redis for rate limiting and cache state.

## Install

```powershell
cd backend/services/auth-service
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
```

## Run

```powershell
$env:PYTHONPATH="E:\cybershield-ai"
uvicorn main:app --reload --port 5000
```

## Test Examples

Register:

```powershell
Invoke-RestMethod -Method Post http://localhost:5000/auth/register -ContentType application/json -Body '{"email":"citizen@example.com","phone_number":"+919999999999","password":"CyberShield@2026","full_name":"Demo Citizen","user_type":"citizen"}'
```

Login:

```powershell
Invoke-RestMethod -Method Post http://localhost:5000/auth/login -ContentType application/json -Body '{"email":"citizen@example.com","password":"CyberShield@2026"}'
```

Health:

```powershell
Invoke-RestMethod http://localhost:5000/health
```
