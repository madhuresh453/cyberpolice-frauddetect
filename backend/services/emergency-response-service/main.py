"""CyberShield AI - Emergency Response SOS Service"""
import uuid
from contextlib import asynccontextmanager
from datetime import UTC, datetime

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.shared.database.mongodb import connect_mongodb, close_mongodb
from backend.shared.security.security_headers import SecurityHeadersMiddleware
from routers import emergency_routes


@asynccontextmanager
async def lifespan(_app: FastAPI):
    await connect_mongodb()
    yield
    await close_mongodb()


app = FastAPI(title="CyberShield AI - Emergency Response Service", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(SecurityHeadersMiddleware)

app.include_router(emergency_routes.router, prefix="/api/v1/emergency", tags=["Emergency Response"])


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "emergency-response-service"}


@app.get("/api/v1")
async def api_root():
    return {
        "service": "Emergency Response Service",
        "version": "1.0.0",
        "endpoints": [
            "POST /api/v1/emergency/sos - Trigger SOS",
            "GET  /api/v1/emergency/sos/{session_id} - Get SOS status",
            "POST /api/v1/emergency/sos/{session_id}/resolve - Resolve SOS",
            "POST /api/v1/emergency/contacts - Add emergency contact",
            "GET  /api/v1/emergency/contacts - List contacts",
            "DELETE /api/v1/emergency/contacts/{contact_id} - Remove contact",
            "POST /api/v1/emergency/evidence - Upload offline evidence",
            "GET  /api/v1/emergency/evidence/{session_id} - Get session evidence",
            "POST /api/v1/emergency/notify - Notify emergency contacts",
            "GET  /api/v1/emergency/history/{citizen_id} - Get emergency history",
        ],
    }