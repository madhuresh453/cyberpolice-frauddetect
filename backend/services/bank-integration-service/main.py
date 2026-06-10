"""CyberShield AI - Bank Integration Service"""
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.shared.database.mongodb import connect_mongodb, close_mongodb
from backend.shared.security.security_headers import SecurityHeadersMiddleware
from routers import bank_routes, freeze_routes, upi_routes, npci_routes


@asynccontextmanager
async def lifespan(_app: FastAPI):
    await connect_mongodb()
    yield
    await close_mongodb()


app = FastAPI(title="CyberShield AI - Bank Integration Service", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(SecurityHeadersMiddleware)

app.include_router(bank_routes.router, prefix="/api/v1/bank", tags=["Bank Integration"])
app.include_router(freeze_routes.router, prefix="/api/v1/freeze", tags=["Account Freeze"])
app.include_router(upi_routes.router, prefix="/api/v1/upi", tags=["UPI Verification"])
app.include_router(npci_routes.router, prefix="/api/v1/npci", tags=["NPCI Integration"])


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "bank-integration-service"}


@app.get("/api/v1")
async def api_root():
    return {
        "service": "Bank Integration Service",
        "version": "1.0.0",
        "endpoints": [
            "GET  /health",
            "POST /api/v1/bank/accounts/lookup",
            "POST /api/v1/bank/accounts/freeze",
            "POST /api/v1/bank/accounts/unfreeze",
            "GET  /api/v1/bank/accounts/{account_id}/transactions",
            "POST /api/v1/bank/complaints",
            "GET  /api/v1/bank/complaints/{complaint_id}",
            "POST /api/v1/freeze/emergency-hold",
            "POST /api/v1/freeze/approve/{request_id}",
            "POST /api/v1/freeze/reject/{request_id}",
            "POST /api/v1/upi/verify",
            "GET  /api/v1/upi/{upi_id}/risk",
            "POST /api/v1/npci/register",
            "POST /api/v1/npci/fraud-report",
        ],
    }