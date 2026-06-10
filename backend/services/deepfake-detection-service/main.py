"""CyberShield AI - Deepfake Voice Detection Service"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import detection_routes

from backend.shared.database.mongodb import connect_mongodb, close_mongodb
from backend.shared.security.security_headers import SecurityHeadersMiddleware


@asynccontextmanager
async def lifespan(_app: FastAPI):
    await connect_mongodb()
    yield
    await close_mongodb()


app = FastAPI(title="CyberShield AI - Deepfake Detection Service", version="1.0.0", lifespan=lifespan)

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
app.add_middleware(SecurityHeadersMiddleware)

app.include_router(detection_routes.router, prefix="/api/v1/deepfake", tags=["Deepfake Detection"])


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "deepfake-detection", "model": "wav2vec-ecapa"}


@app.get("/api/v1")
async def api_root():
    return {
        "service": "Deepfake Detection Service",
        "version": "1.0.0",
        "endpoints": [
            "POST /api/v1/deepfake/analyze/voice   - Analyze voice recording for deepfake",
            "POST /api/v1/deepfake/analyze/video   - Analyze video for deepfake",
            "POST /api/v1/deepfake/analyze/stream  - Analyze real-time audio stream",
            "GET  /api/v1/deepfake/analysis/{id}   - Get analysis result",
            "GET  /api/v1/deepfake/stats            - Detection statistics",
        ],
    }