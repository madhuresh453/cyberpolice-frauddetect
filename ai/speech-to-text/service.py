"""
RAKSAAR (CyberShield AI) — Speech-to-Text Service
Real-time multilingual transcription for Indian languages.
Integrates with Bhashini API (MeitY Government of India).
"""
import io
import json
import logging
import os
import tempfile
import time
import traceback
from typing import Optional

import aiohttp
import numpy as np
from fastapi import FastAPI, File, UploadFile, HTTPException, Form, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("raksaar-stt")

app = FastAPI(title="RAKSAAR Speech-to-Text", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== BHASHINI API CONFIGURATION =====
# Bhashini is the Government of India's National Language Translation Mission
# API Documentation: https://bhashini.gov.in/api-documentation
BHASHINI_API_URL = os.getenv("BHASHINI_API_URL", "https://api.bhashini.gov.in/v1")
BHASHINI_API_KEY = os.getenv("BHASHINI_API_KEY", "")
BHASHINI_USER_ID = os.getenv("BHASHINI_USER_ID", "")

# Supported languages per Bhashini
SUPPORTED_LANGUAGES = {
    "hi": "Hindi", "en": "English", "pa": "Punjabi", "gu": "Gujarati",
    "mr": "Marathi", "bn": "Bengali", "ta": "Tamil", "te": "Telugu",
    "kn": "Kannada", "ml": "Malayalam", "or": "Odia", "as": "Assamese",
    "ur": "Urdu", "mai": "Maithili", "sat": "Santali", "ks": "Kashmiri",
    "sd": "Sindhi", "kok": "Konkani", "ne": "Nepali", "brx": "Bodo",
    "doi": "Dogri", "mni": "Manipuri",
}

# Language detection patterns for code-mixed speech (Hinglish, Tanglish, etc.)
CODE_MIXED_PATTERNS = {
    "hinglish": ["yaar", "achha", "kya", "nahi", "hai", "matlab", "wahi", "bas", "theek hai"],
    "tangling": ["da", "poda", "iruku", "machaan", "enga", "epdi"],
    "banglish": ["ki", "ami", "bhalo", "kolkata", "dada"],
}


class TranscriptionRequest(BaseModel):
    audio_base64: Optional[str] = None
    audio_url: Optional[str] = None
    language: str = "auto"
    enable_diarization: bool = False
    enable_punctuation: bool = True
    enable_timestamps: bool = True


class TranscriptionResponse(BaseModel):
    transcript: str
    language: str
    language_name: str
    confidence: float
    segments: list = []
    duration_seconds: float = 0.0
    processing_time_ms: int = 0


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    bhashini_configured: bool
    supported_languages: int
    uptime_seconds: float


# Track service start time
SERVICE_START_TIME = time.time()


async def transcribe_with_bhashini(audio_bytes: bytes, language: str = "auto") -> dict:
    """
    Transcribe audio using Bhashini API.
    Falls back to a robust local model if Bhashini is unavailable.
    """
    if not BHASHINI_API_KEY:
        logger.warning("Bhashini API key not configured, using local fallback")
        return await local_fallback_transcription(audio_bytes, language)

    try:
        headers = {
            "Authorization": f"Bearer {BHASHINI_API_KEY}",
            "Content-Type": "application/json",
            "User-ID": BHASHINI_USER_ID,
        }

        # Bhashini STT pipeline expects audio as base64
        import base64
        audio_b64 = base64.b64encode(audio_bytes).decode("utf-8")

        payload = {
            "pipelineTasks": [
                {
                    "taskType": "asr",
                    "config": {
                        "language": language if language != "auto" else "hi",
                        "audioFormat": "wav",
                        "samplingRate": 16000,
                        "enablePunctuation": True,
                        "enableTimestamps": True,
                    },
                }
            ],
            "inputData": {
                "audio": [{"audioContent": audio_b64}],
            },
        }

        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{BHASHINI_API_URL}/asr",
                headers=headers,
                json=payload,
                timeout=aiohttp.ClientTimeout(total=30),
            ) as resp:
                if resp.status == 200:
                    result = await resp.json()
                    transcript = result.get("output", [{}])[0].get("source", "")
                    confidence = result.get("output", [{}])[0].get("confidence", 0.95)
                    detected_lang = result.get("output", [{}])[0].get("language", language)
                    return {
                        "transcript": transcript,
                        "language": detected_lang,
                        "language_name": SUPPORTED_LANGUAGES.get(detected_lang, detected_lang),
                        "confidence": confidence,
                        "segments": result.get("output", [{}])[0].get("segments", []),
                    }

                logger.error(f"Bhashini API error: {resp.status} - {await resp.text()}")
                return await local_fallback_transcription(audio_bytes, language)

    except Exception as e:
        logger.error(f"Bhashini API exception: {e}")
        return await local_fallback_transcription(audio_bytes, language)


async def local_fallback_transcription(audio_bytes: bytes, language: str = "auto") -> dict:
    """
    Local Whisper-based transcription fallback.
    Uses whisper-tiny for speed, runs on CPU.
    """
    try:
        import whisper

        model = whisper.load_model("tiny")
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            tmp.write(audio_bytes)
            tmp_path = tmp.name

        try:
            result = model.transcribe(
                tmp_path,
                language=None if language == "auto" else language,
                task="transcribe",
                verbose=False,
            )

            detected_lang = result.get("language", language)
            return {
                "transcript": result.get("text", ""),
                "language": detected_lang,
                "language_name": SUPPORTED_LANGUAGES.get(detected_lang, detected_lang),
                "confidence": max(result.get("segments", [{}])[0].get("confidence", 0.8) if result.get("segments") else 0.8, 0.8),
                "segments": [
                    {
                        "start": seg.get("start", 0),
                        "end": seg.get("end", 0),
                        "text": seg.get("text", ""),
                        "confidence": seg.get("confidence", 0.0),
                    }
                    for seg in result.get("segments", [])
                ],
            }
        finally:
            os.unlink(tmp_path)

    except Exception as e:
        logger.error(f"Local fallback error: {e}")
        return {
            "transcript": "",
            "language": "hi",
            "language_name": "Hindi",
            "confidence": 0.0,
            "segments": [],
            "error": str(e),
        }


def detect_language_from_text(text: str) -> str:
    """Detect language/code-mix from transcript text"""
    if not text:
        return "unknown"

    text_lower = text.lower()
    scores = {}

    # Check code-mixed patterns
    for mix, words in CODE_MIXED_PATTERNS.items():
        score = sum(1 for w in words if w in text_lower)
        if score > 0:
            scores[mix] = score

    # Check Unicode ranges for Indian languages
    import re
    devanagari = len(re.findall(r'[\u0900-\u097F]', text))
    bengali = len(re.findall(r'[\u0980-\u09FF]', text))
    tamil = len(re.findall(r'[\u0B80-\u0BFF]', text))
    telugu = len(re.findall(r'[\u0C00-\u0C7F]', text))
    gurmukhi = len(re.findall(r'[\u0A00-\u0A7F]', text))
    gujarati = len(re.findall(r'[\u0A80-\u0AFF]', text))
    malayalam = len(re.findall(r'[\u0D00-\u0D7F]', text))

    lang_scores = {
        "hi": devanagari,
        "bn": bengali,
        "ta": tamil,
        "te": telugu,
        "pa": gurmukhi,
        "gu": gujarati,
        "ml": malayalam,
    }

    # Also check for script-specific markers
    if devanagari > 0 and any(w in text_lower for w in CODE_MIXED_PATTERNS["hinglish"]):
        return "hinglish"

    best_lang = max(lang_scores, key=lang_scores.get)
    return best_lang if lang_scores[best_lang] > 0 else "en"


@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        service="raksaar-stt",
        version="1.0.0",
        bhashini_configured=bool(BHASHINI_API_KEY),
        supported_languages=len(SUPPORTED_LANGUAGES),
        uptime_seconds=time.time() - SERVICE_START_TIME,
    )


@app.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe_audio(
    file: UploadFile = File(...),
    language: str = Form("auto"),
    enable_diarization: bool = Form(False),
    enable_punctuation: bool = Form(True),
    enable_timestamps: bool = Form(True),
):
    """Transcribe audio file to text. Supports multiple Indian languages."""
    start_time = time.time()

    # Validate file type
    if not file.filename or not any(
        file.filename.lower().endswith(ext) for ext in [".wav", ".mp3", ".m4a", ".ogg", ".flac", ".webm", ".amr"]
    ):
        raise HTTPException(
            status_code=400,
            detail="Unsupported audio format. Supported: wav, mp3, m4a, ogg, flac, webm, amr",
        )

    # Read audio file
    audio_bytes = await file.read()
    if len(audio_bytes) == 0:
        raise HTTPException(status_code=400, detail="Empty audio file")

    if len(audio_bytes) > 50 * 1024 * 1024:  # 50MB limit
        raise HTTPException(status_code=400, detail="Audio file too large. Max 50MB")

    # Process transcription
    result = await transcribe_with_bhashini(audio_bytes, language)

    # Detect language if auto
    detected_lang = result.get("language", language)
    if language == "auto" and detected_lang == "auto":
        detected_lang = detect_language_from_text(result.get("transcript", ""))

    processing_time = int((time.time() - start_time) * 1000)

    # Estimate duration from audio size (rough estimate for PCM 16kHz mono)
    duration_seconds = len(audio_bytes) / (16000 * 2)  # 16-bit mono at 16kHz

    return TranscriptionResponse(
        transcript=result.get("transcript", ""),
        language=detected_lang,
        language_name=SUPPORTED_LANGUAGES.get(detected_lang, detected_lang),
        confidence=result.get("confidence", 0.0),
        segments=result.get("segments", []),
        duration_seconds=round(duration_seconds, 2),
        processing_time_ms=processing_time,
    )


@app.post("/transcribe/text")
async def transcribe_text(request: TranscriptionRequest):
    """
    Alternative endpoint for text-based transcription request.
    Accepts base64 audio or audio URL.
    """
    if not request.audio_base64 and not request.audio_url:
        raise HTTPException(status_code=400, detail="Either audio_base64 or audio_url is required")

    start_time = time.time()

    if request.audio_base64:
        import base64
        audio_bytes = base64.b64decode(request.audio_base64)
    else:
        # Download from URL
        async with aiohttp.ClientSession() as session:
            async with session.get(request.audio_url) as resp:
                if resp.status != 200:
                    raise HTTPException(status_code=400, detail="Failed to download audio from URL")
                audio_bytes = await resp.read()

    result = await transcribe_with_bhashini(audio_bytes, request.language)
    processing_time = int((time.time() - start_time) * 1000)

    return TranscriptionResponse(
        transcript=result.get("transcript", ""),
        language=result.get("language", request.language),
        language_name=SUPPORTED_LANGUAGES.get(result.get("language", ""), "Unknown"),
        confidence=result.get("confidence", 0.0),
        segments=result.get("segments", []),
        duration_seconds=len(audio_bytes) / (16000 * 2),
        processing_time_ms=processing_time,
    )


@app.post("/detect-language")
async def detect_language(file: UploadFile = File(...)):
    """Detect the language of spoken audio without full transcription"""
    audio_bytes = await file.read()
    result = await transcribe_with_bhashini(audio_bytes, "auto")
    transcript = result.get("transcript", "")

    detected = detect_language_from_text(transcript)
    return {
        "detected_language": detected,
        "language_name": SUPPORTED_LANGUAGES.get(detected, "Unknown"),
        "confidence": result.get("confidence", 0.0),
        "transcript_preview": transcript[:200] if transcript else "",
    }


@app.get("/languages")
async def list_languages():
    """List all supported languages"""
    return {
        "languages": [{"code": code, "name": name} for code, name in SUPPORTED_LANGUAGES.items()],
        "count": len(SUPPORTED_LANGUAGES),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)