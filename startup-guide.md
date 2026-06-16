# CyberShield AI - Backend Startup Fix Guide

## 1. ROOT CAUSE OF `ModuleNotFoundError: No module named 'app'`

**The command is wrong for this project.**

When you run:
```bash
cd E:\cybershield-ai\backend
uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload
```

Uvicorn looks for `backend/app/main.py`. **This file does not exist.**

The `backend/` directory contains:
```
backend/
├── server.js        ← Node.js Express server (actual entry point)
├── app.js           ← Express app factory
├── routes/          ← Express routes
├── services/        ← FastAPI microservices
│   ├── auth-service/main.py
│   ├── bank-integration-service/main.py
│   ├── deepfake-detection-service/main.py
│   ├── emergency-response-service/main.py
│   └── graph-intelligence-service/main.py
├── shared/          ← Shared Node.js/Python utilities
└── tests/
```

There is **no** `backend/app/main.py`. The backend is a **Node.js Express** server, NOT a FastAPI app.

## 2. CORRECT STARTUP ARCHITECTURE

```
┌─────────────────────────────────────────────────────┐
│                  CYBERSHIELD AI                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  BACKEND GATEWAY (Node.js Express)            │   │
│  │  └── server.js → app.js                      │   │
│  │  Port: 5000                                  │   │
│  │  Command: node backend/server.js              │   │
│  ├──────────────────────────────────────────────┤   │
│  │  AI GATEWAY (Python FastAPI)                  │   │
│  │  └── ai/ai-gateway.py                        │   │
│  │  Port: 8000                                  │   │
│  │  Command: uvicorn ai.ai_gateway:app          │   │
│  ├──────────────────────────────────────────────┤   │
│  │  FASTAPI MICROSERVICES                       │   │
│  │  ├── Auth Service        → Port 5001         │   │
│  │  ├── Bank Integration    → Port 8002         │   │
│  │  ├── Deepfake Detection  → Port 8003         │   │
│  │  ├── Emergency Response  → Port 8004         │   │
│  │  └── Graph Intelligence → Port 8005         │   │
│  ├──────────────────────────────────────────────┤   │
│  │  FRONTENDS                                   │   │
│  │  ├── Police Portal       → Port 3000         │   │
│  │  ├── ISP Portal          → Port 3001         │   │
│  │  └── Citizen Flutter App → Port vary         │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### How Each Service Starts:

| Service | Type | Entry File | How Started |
|---------|------|-----------|-------------|
| Backend Gateway | Node.js Express | `backend/server.js` | `node backend/server.js` (or `npm start` from root) |
| AI Gateway | Python FastAPI | `ai/ai-gateway.py` | `uvicorn ai.ai_gateway:app` |
| Auth Service | Python FastAPI | `backend/services/auth-service/main.py` | `uvicorn` with module path |
| Bank Service | Python FastAPI | `backend/services/bank-integration-service/main.py` | `uvicorn` with module path |
| Deepfake Service | Python FastAPI | `backend/services/deepfake-detection-service/main.py` | `uvicorn` with module path |
| Emergency Service | Python FastAPI | `backend/services/emergency-response-service/main.py` | `uvicorn` with module path |
| Graph Service | Python FastAPI | `backend/services/graph-intelligence-service/main.py` | `uvicorn` with module path |

## 3. EXACT STARTUP COMMANDS

### A) Backend Gateway (Node.js Express) — WORKS

```powershell
cd E:\cybershield-ai
npm start
# OR
node backend/server.js
```

**Health check:** `http://localhost:5000` → `{"name":"CYBERSHIELD-AI","status":"running","database":"connected"}`

### B) AI Gateway (FastAPI) — WORKS

```powershell
cd E:\cybershield-ai
uvicorn ai.ai_gateway:app --reload --host 0.0.0.0 --port 8000
```

**Health check:** `http://localhost:8000/health` → `{"status":"healthy","service":"raksaar-ai-gateway"}`

### C) Auth Service (FastAPI)

```powershell
cd E:\cybershield-ai
python -m uvicorn backend.services.auth-service.main:app --reload --host 0.0.0.0 --port 5001
```

### D) Bank Integration (FastAPI)

```powershell
cd E:\cybershield-ai
python -m uvicorn backend.services.bank-integration-service.main:app --reload --host 0.0.0.0 --port 8002
```

### E) Deepfake Detection (FastAPI)

```powershell
cd E:\cybershield-ai
python -m uvicorn backend.services.deepfake-detection-service.main:app --reload --host 0.0.0.0 --port 8003
```

### F) Emergency Response (FastAPI)

```powershell
cd E:\cybershield-ai
python -m uvicorn backend.services.emergency-response-service.main:app --reload --host 0.0.0.0 --port 8004
```

### G) Graph Intelligence (FastAPI)

```powershell
cd E:\cybershield-ai
python -m uvicorn backend.services.graph-intelligence-service.main:app --reload --host 0.0.0.0 --port 8005
```

## 4. PORT MAPPING TABLE

| Service | Port | Startup Command |
|---------|------|-----------------|
| Backend Gateway | 5000 | `node backend/server.js` or `npm start` |
| AI Gateway | 8000 | `uvicorn ai.ai_gateway:app --port 8000` |
| Auth Service | 5001 | `uvicorn backend.services.auth-service.main:app --port 5001` |
| Bank Integration | 8002 | `uvicorn backend.services.bank-integration-service.main:app --port 8002` |
| Deepfake Detection | 8003 | `uvicorn backend.services.deepfake-detection-service.main:app --port 8003` |
| Emergency Response | 8004 | `uvicorn backend.services.emergency-response-service.main:app --port 8004` |
| Graph Intelligence | 8005 | `uvicorn backend.services.graph-intelligence-service.main:app --port 8005` |
| Police Portal | 3000 | `npm run dev` in `portals/police-admin/` |
| ISP Portal | 3001 | `npm run dev` in `portals/isp-portal/` |

## 5. UNIFIED AUTOMATION

Use the provided `start-all.ps1` script:

```powershell
cd E:\cybershield-ai
.\start-all.ps1
```

This launches all 7 services in separate PowerShell windows automatically.

## 6. REQUIRED FIXES (ALREADY APPLIED)

### Created missing `__init__.py` files:
- `backend/__init__.py`
- `backend/shared/__init__.py`
- `backend/shared/database/__init__.py`
- `backend/shared/middlewares/__init__.py`
- `backend/shared/models/__init__.py`
- `backend/shared/routes/__init__.py`
- `backend/shared/security/__init__.py`
- `backend/shared/services/__init__.py`
- `backend/shared/utils/__init__.py`
- `backend/routes/__init__.py`
- `ai/__init__.py`

These ensure Python can resolve module paths like `backend.shared.database.mongodb`.

### Created:
- `start-all.ps1` — Unified startup script

## 7. AWS DEPLOYMENT COMMANDS

```bash
# Build and push Docker images
docker build -t cybershield-backend -f backend/Dockerfile .
docker build -t cybershield-ai-gateway -f ai/Dockerfile.ai .

# ECR push
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.ap-south-1.amazonaws.com
docker tag cybershield-backend:latest <account>.dkr.ecr.ap-south-1.amazonaws.com/cybershield-backend:latest
docker push <account>.dkr.ecr.ap-south-1.amazonaws.com/cybershield-backend:latest

# ECS Fargate
aws ecs run-task --cluster cybershield-cluster --task-definition cybershield-backend
```

## 8. PRODUCTION RECOMMENDATIONS

1. **Never run `uvicorn app.main:app` from `backend/`** — the backend is Node.js
2. **Use `npm start` from project root** for the Node.js backend
3. **Run FastAPI services from project root** with `python -m uvicorn backend.services.<name>.main:app`
4. **Add `__init__.py`** to all Python package directories (done above)
5. **Use PM2** for production Node.js: `pm2 start backend/server.js --name cybershield-backend`
6. **Use systemd or Docker** for production FastAPI services
7. **Set `PYTHONPATH`** to project root: `$env:PYTHONPATH="E:\cybershield-ai"` on Windows