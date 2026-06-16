"""
RAKSAAR (CyberShield AI) — AI Gateway Service
Unified API gateway for all AI services.
Routes requests to STT, Scam Classifier, Deepfake Detector, and Risk Scoring.
Provides a single endpoint for the backend to call.
"""
import asyncio
import json
import logging
import os
import time
from typing import Optional

import aiohttp
from fastapi import FastAPI, HTTPException, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("raksaar-ai-gateway")

app = FastAPI(title="RAKSAAR AI Gateway", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== MICROSERVICE ENDPOINTS =====
AI_SERVICES = {
    "stt": os.getenv("STT_SERVICE_URL", "http://localhost:8001"),
    "classifier": os.getenv("CLASSIFIER_SERVICE_URL", "http://localhost:8002"),
    "deepfake": os.getenv("DEEPFAKE_SERVICE_URL", "http://localhost:8003"),
}

SERVICE_START_TIME = time.time()

# ===== IN-MEMORY FRAUD DATABASE (temp until integrated with MongoDB) =====
FRAUD_NUMBERS_CACHE = {}  # phone -> { reports_count, risk_score, last_reported }
FRAUD_UPI_CACHE = {}
FRAUD_DOMAIN_CACHE = {}


class FullAnalysisRequest(BaseModel):
    text: Optional[str] = None
    phone_number: Optional[str] = None
    upi_id: Optional[str] = None
    url: Optional[str] = None
    language: str = "auto"
    include_deepfake: bool = False


class FullAnalysisResponse(BaseModel):
    scam_classification: dict = {}
    risk_score: dict = {}
    threat_intel: dict = {}
    phone_reputation: dict = {}
    url_analysis: dict = {}
    overall_verdict: str = "safe"
    processing_time_ms: int = 0


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    services: dict = {}
    uptime_seconds: float


async def check_service_health(service_name: str, url: str) -> dict:
    """Check if a microservice is healthy"""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{url}/health", timeout=5) as resp:
                if resp.status == 200:
                    return {"status": "healthy", "url": url}
                return {"status": "unhealthy", "url": url}
    except:
        return {"status": "unreachable", "url": url}


async def call_stt(audio_bytes: bytes, language: str = "auto") -> dict:
    """Call Speech-to-Text service"""
    try:
        async with aiohttp.ClientSession() as session:
            data = aiohttp.FormData()
            data.add_field("file", audio_bytes, filename="audio.wav", content_type="audio/wav")
            data.add_field("language", language)

            async with session.post(f"{AI_SERVICES['stt']}/transcribe", data=data, timeout=30) as resp:
                if resp.status == 200:
                    return await resp.json()
                return {"transcript": "", "language": "unknown", "confidence": 0.0, "error": f"STT service error: {resp.status}"}
    except Exception as e:
        logger.error(f"STT call failed: {e}")
        return {"transcript": "", "language": "unknown", "confidence": 0.0, "error": str(e)}


async def call_classifier(text: str, language: str = "auto") -> dict:
    """Call Scam Classification service"""
    if not text or len(text.strip()) < 3:
        return {"detected_scam_types": [], "primary_scam_type": None, "risk_score": 0}

    try:
        async with aiohttp.ClientSession() as session:
            payload = {"text": text, "language": language}
            async with session.post(f"{AI_SERVICES['classifier']}/classify", json=payload, timeout=10) as resp:
                if resp.status == 200:
                    return await resp.json()
                return {"detected_scam_types": [], "primary_scam_type": None, "risk_score": 0, "error": f"Classifier error: {resp.status}"}
    except Exception as e:
        logger.error(f"Classifier call failed: {e}")
        return {"detected_scam_types": [], "primary_scam_type": None, "risk_score": 0, "error": str(e)}


async def call_deepfake(audio_bytes: bytes) -> dict:
    """Call Deepfake Detection service"""
    try:
        async with aiohttp.ClientSession() as session:
            data = aiohttp.FormData()
            data.add_field("file", audio_bytes, filename="audio.wav", content_type="audio/wav")

            async with session.post(f"{AI_SERVICES['deepfake']}/analyze", data=data, timeout=30) as resp:
                if resp.status == 200:
                    return await resp.json()
                return {"is_deepfake": False, "confidence": 0.0, "error": f"Deepfake error: {resp.status}"}
    except Exception as e:
        logger.error(f"Deepfake call failed: {e}")
        return {"is_deepfake": False, "confidence": 0.0, "error": str(e)}


def check_phone_reputation(phone_number: str) -> dict:
    """Check phone number reputation from fraud database"""
    if not phone_number:
        return {"risk_score": 0, "reports_count": 0, "is_fraud": False, "sources": []}

    # Check in-memory cache
    cache_data = FRAUD_NUMBERS_CACHE.get(phone_number, {})
    reports_count = cache_data.get("reports_count", 0)
    risk_score = cache_data.get("risk_score", 0)

    # Pattern-based checks
    risk_score_calc = risk_score
    reasons = []

    # Known scam prefixes
    scam_prefixes = ["+91140", "+91130", "+92121", "+92123", "+92124", "+92125"]
    for prefix in scam_prefixes:
        if phone_number.startswith(prefix):
            risk_score_calc += 30
            reasons.append(f"Known scam prefix: {prefix}")

    # International high-risk countries
    high_risk_codes = ["+92", "+94", "+880", "+977", "+98", "+963"]
    for code in high_risk_codes:
        if phone_number.startswith(code):
            risk_score_calc += 20
            reasons.append("International number from high-risk region")

    # Virtual numbers (VoIP)
    voip_prefixes = ["+91180", "+91181", "+91182"]
    for prefix in voip_prefixes:
        if phone_number.startswith(prefix):
            risk_score_calc += 15
            reasons.append("Possible VoIP/Virtual number")

    risk_score_calc = min(risk_score_calc + reports_count * 5, 100)

    is_fraud = risk_score_calc >= 50 or reports_count >= 3

    return {
        "phone_number": phone_number,
        "risk_score": risk_score_calc,
        "reports_count": reports_count,
        "is_fraud": is_fraud,
        "sources": reasons,
        "recommendation": "BLOCK" if is_fraud else "MONITOR" if risk_score_calc >= 30 else "SAFE",
    }


def check_upi_reputation(upi_id: str) -> dict:
    """Check UPI ID reputation"""
    if not upi_id:
        return {"risk_score": 0, "is_fraud": False}

    cache_data = FRAUD_UPI_CACHE.get(upi_id, {})
    reports_count = cache_data.get("reports_count", 0)
    risk_score = cache_data.get("risk_score", 0)

    # Newly created UPI IDs (would need bank integration for real check)
    risk_score_calc = risk_score + reports_count * 10
    risk_score_calc = min(risk_score_calc, 100)

    return {
        "upi_id": upi_id,
        "risk_score": risk_score_calc,
        "reports_count": reports_count,
        "is_fraud": risk_score_calc >= 50,
        "recommendation": "BLOCK" if risk_score_calc >= 50 else "SAFE",
    }


def analyze_url_reputation(url: str) -> dict:
    """Analyze URL for phishing/malware indicators"""
    if not url:
        return {"risk_score": 0, "is_malicious": False}

    risk_score = 0
    indicators = []
    url_lower = url.lower()

    # Phishing domains
    phishing_domains = [
        "google.security.com", "paytm-safe.com", "phonepe-verify.com",
        "gpay-verify.com", "sbisecure.in", "hdfc-bank.in", "icici-verify.com",
        "www-icici.com", "www-hdfc.com", "www-sbi.com",
    ]
    for domain in phishing_domains:
        if domain in url_lower:
            risk_score += 50
            indicators.append(f"Known phishing domain: {domain}")

    # Suspicious TLDs
    suspicious_tlds = [".xyz", ".top", ".club", ".gq", ".ml", ".cf", ".tk", ".ga"]
    for tld in suspicious_tlds:
        if url_lower.endswith(tld):
            risk_score += 20
            indicators.append(f"Suspicious TLD: {tld}")

    # IP address instead of domain
    import re
    ip_pattern = r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
    if re.search(ip_pattern, url_lower):
        risk_score += 30
        indicators.append("Uses IP address instead of domain")

    # URL shorteners
    shorteners = ["bit.ly", "tinyurl", "tiny.cc", "goo.gl", "ow.ly", "is.gd", "t.co"]
    for s in shorteners:
        if s in url_lower:
            risk_score += 10
            indicators.append(f"URL shortened by {s}")

    # Suspicious keywords in URL
    suspicious_words = ["login", "verify", "secure", "account", "update", "confirm", "bank", "pay", "otp"]
    for word in suspicious_words:
        if word in url_lower:
            risk_score += 10
            indicators.append(f"Suspicious keyword in URL: {word}")
            break

    risk_score = min(risk_score, 100)

    return {
        "url": url,
        "risk_score": risk_score,
        "is_malicious": risk_score >= 50,
        "is_suspicious": 20 <= risk_score < 50,
        "indicators": indicators,
        "recommendation": "BLOCK" if risk_score >= 50 else "WARN" if risk_score >= 20 else "SAFE",
    }


def calculate_overall_risk(scam_result: dict, phone_result: dict, url_result: dict, upi_result: dict) -> dict:
    """
    Calculate overall risk score combining all analysis factors.
    Formula: Conversation Risk + Number Reputation + URL Risk + UPI Risk
    """
    scam_risk = scam_result.get("risk_score", 0)
    phone_risk = phone_result.get("risk_score", 0)
    url_risk = url_result.get("risk_score", 0)
    upi_risk = upi_result.get("risk_score", 0)

    # Weighted combination
    total_risk = (
        scam_risk * 0.35 +
        phone_risk * 0.30 +
        url_risk * 0.20 +
        upi_risk * 0.15
    )

    total_risk = round(min(total_risk, 100), 1)

    # Determine category
    if total_risk >= 70:
        category = "critical"
        verdict = "HIGH_RISK_SCAM"
        action = "IMMEDIATE_BLOCK"
    elif total_risk >= 50:
        category = "high"
        verdict = "SUSPICIOUS"
        action = "WARN_USER"
    elif total_risk >= 30:
        category = "medium"
        verdict = "CAUTION"
        action = "MONITOR"
    else:
        category = "safe"
        verdict = "SAFE"
        action = "NO_ACTION"

    return {
        "risk_score": total_risk,
        "category": category,
        "verdict": verdict,
        "action": action,
        "factors": {
            "scam_classification": scam_risk,
            "phone_reputation": phone_risk,
            "url_analysis": url_risk,
            "upi_analysis": upi_risk,
        },
    }


def report_fraud_number(phone_number: str, risk_score: int = 50):
    """Report a phone number as fraudulent (adds to fraud database)"""
    if phone_number not in FRAUD_NUMBERS_CACHE:
        FRAUD_NUMBERS_CACHE[phone_number] = {"reports_count": 0, "risk_score": risk_score}
    
    FRAUD_NUMBERS_CACHE[phone_number]["reports_count"] += 1
    FRAUD_NUMBERS_CACHE[phone_number]["risk_score"] = min(
        FRAUD_NUMBERS_CACHE[phone_number]["risk_score"] + 10, 100
    )
    FRAUD_NUMBERS_CACHE[phone_number]["last_reported"] = time.time()


def report_fraud_upi(upi_id: str, risk_score: int = 50):
    """Report a UPI ID as fraudulent"""
    if upi_id not in FRAUD_UPI_CACHE:
        FRAUD_UPI_CACHE[upi_id] = {"reports_count": 0, "risk_score": risk_score}
    
    FRAUD_UPI_CACHE[upi_id]["reports_count"] += 1
    FRAUD_UPI_CACHE[upi_id]["risk_score"] = min(
        FRAUD_UPI_CACHE[upi_id]["risk_score"] + 10, 100
    )


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Check health of all AI microservices"""
    services_health = {}
    for name, url in AI_SERVICES.items():
        services_health[name] = await check_service_health(name, url)

    all_healthy = all(s["status"] == "healthy" for s in services_health.values())

    return HealthResponse(
        status="healthy" if all_healthy else "degraded",
        service="raksaar-ai-gateway",
        version="1.0.0",
        services=services_health,
        uptime_seconds=time.time() - SERVICE_START_TIME,
    )


@app.post("/analyze/full", response_model=FullAnalysisResponse)
async def full_analysis(request: FullAnalysisRequest):
    """
    Complete analysis pipeline:
    1. Scam classification of text
    2. Phone number reputation check
    3. URL analysis
    4. UPI reputation check
    5. Combined risk score
    """
    start_time = time.time()

    # Run all analysis in parallel
    tasks = {}

    # Scam classification
    if request.text:
        tasks["scam"] = call_classifier(request.text, request.language)
    else:
        tasks["scam"] = asyncio.sleep(0, None)

    # Phone reputation (instant - local)
    phone_result = check_phone_reputation(request.phone_number or "")

    # URL analysis (instant - local)
    url_result = analyze_url_reputation(request.url or "")

    # UPI reputation (instant - local)
    upi_result = check_upi_reputation(request.upi_id or "")

    # Await classification
    scam_result = await tasks.get("scam", {}) or {}

    # Calculate overall risk
    overall = calculate_overall_risk(scam_result, phone_result, url_result, upi_result)

    processing_time = int((time.time() - start_time) * 1000)

    return FullAnalysisResponse(
        scam_classification=scam_result,
        risk_score=overall,
        threat_intel={
            "threat_score": overall["risk_score"],
            "sources_checked": ["scam_db", "phone_reputation", "url_analysis", "upi_db"],
            "recommendation": overall["action"],
        },
        phone_reputation=phone_result,
        url_analysis=url_result,
        overall_verdict=overall["verdict"],
        processing_time_ms=processing_time,
    )


@app.post("/analyze/call")
async def analyze_call(
    file: UploadFile = File(...),
    phone_number: str = Form(""),
    language: str = Form("auto"),
):
    """
    Complete call analysis:
    1. STT transcription
    2. Scam classification of transcript
    3. Phone reputation check
    4. Deepfake detection on audio
    5. Combined risk score
    """
    start_time = time.time()

    if not file.filename:
        raise HTTPException(status_code=400, detail="No audio file provided")

    audio_bytes = await file.read()
    if len(audio_bytes) == 0:
        raise HTTPException(status_code=400, detail="Empty audio file")

    # Step 1: Transcribe
    stt_result = await call_stt(audio_bytes, language)
    transcript = stt_result.get("transcript", "")

    # Step 2: Classify transcript
    scam_result = await call_classifier(transcript, stt_result.get("language", language))

    # Step 3: Check phone reputation
    phone_result = check_phone_reputation(phone_number)

    # Step 4: Deepfake detection
    deepfake_result = await call_deepfake(audio_bytes)

    # Step 5: Calculate risk
    risk_factors = {
        "scam_risk": scam_result.get("risk_score", 0),
        "phone_risk": phone_result.get("risk_score", 0),
        "deepfake_risk": deepfake_result.get("confidence", 0) * 100 if deepfake_result.get("is_deepfake") else 0,
    }

    total_risk = min(
        risk_factors["scam_risk"] * 0.4 +
        risk_factors["phone_risk"] * 0.3 +
        risk_factors["deepfake_risk"] * 0.3,
        100
    )

    # Determine risk level
    if total_risk >= 70:
        risk_level = "high_risk"
        risk_color = "red"
        user_message = "⚠️ HIGH RISK: This call is likely a scam!"
    elif total_risk >= 40:
        risk_level = "suspicious"
        risk_color = "yellow"
        user_message = "⚡ SUSPICIOUS: Exercise caution on this call."
    else:
        risk_level = "safe"
        risk_color = "green"
        user_message = "✅ SAFE: No scam indicators detected."

    processing_time = int((time.time() - start_time) * 1000)

    return {
        "risk_score": round(total_risk, 1),
        "risk_level": risk_level,
        "risk_color": risk_color,
        "user_message": user_message,
        "transcript": transcript,
        "transcript_confidence": stt_result.get("confidence", 0),
        "scam_classification": {
            "primary_type": scam_result.get("primary_scam_type"),
            "confidence": scam_result.get("primary_confidence", 0),
            "all_types": scam_result.get("detected_scam_types", []),
            "keywords_found": scam_result.get("keywords_found", []),
        },
        "phone_reputation": {
            "phone_number": phone_number,
            "risk_score": phone_result.get("risk_score", 0),
            "is_known_fraud": phone_result.get("is_fraud", False),
            "reports_count": phone_result.get("reports_count", 0),
        },
        "deepfake_analysis": {
            "is_deepfake": deepfake_result.get("is_deepfake", False),
            "confidence": deepfake_result.get("confidence", 0),
            "voice_clone_probability": deepfake_result.get("voice_clone_probability", 0),
        },
        "risk_factors_breakdown": risk_factors,
        "recommendation": "BLOCK and REPORT to police" if total_risk >= 70
            else "WARN user and MONITOR" if total_risk >= 40
            else "No action needed",
        "processing_time_ms": processing_time,
    }


@app.post("/analyze/sms")
async def analyze_sms(text: str = Form(...), sender: str = Form("")):
    """
    Analyze SMS message for scam indicators.
    """
    start_time = time.time()

    # Classify text
    scam_result = await call_classifier(text)

    # Check sender reputation
    phone_result = check_phone_reputation(sender)

    # Extract URLs from text
    import re
    urls = re.findall(r'https?://[^\s]+', text)
    url_results = [analyze_url_reputation(url) for url in urls]

    # Calculate risk
    scam_risk = scam_result.get("risk_score", 0)
    phone_risk = phone_result.get("risk_score", 0)
    url_risk = max((u.get("risk_score", 0) for u in url_results), default=0)

    total_risk = min(scam_risk * 0.4 + phone_risk * 0.2 + url_risk * 0.4, 100)

    processing_time = int((time.time() - start_time) * 1000)

    return {
        "risk_score": round(total_risk, 1),
        "is_scam": total_risk >= 50,
        "scam_type": scam_result.get("primary_scam_type"),
        "scam_confidence": scam_result.get("primary_confidence", 0),
        "sender_reputation": {
            "risk_score": phone_risk,
            "is_fraud": phone_result.get("is_fraud", False),
        },
        "urls_found": len(urls),
        "url_analysis": url_results,
        "keywords_found": scam_result.get("keywords_found", []),
        "recommendation": "DELETE message immediately" if total_risk >= 70
            else "Do not click any links" if total_risk >= 40
            else "Message appears safe",
        "processing_time_ms": processing_time,
    }


@app.post("/analyze/whatsapp")
async def analyze_whatsapp(text: str = Form(...), sender: str = Form("")):
    """
    Analyze WhatsApp message for scam indicators.
    Same as SMS but with additional WhatsApp-specific checks.
    """
    result = await analyze_sms(text, sender)

    # WhatsApp-specific checks
    whatsapp_indicators = []
    text_lower = text.lower()

    # Check for job/investment scam patterns common on WhatsApp
    if any(w in text_lower for w in ["part time", "work from home", "daily earning", "easy money"]):
        whatsapp_indicators.append("Employment scam pattern")
    if any(w in text_lower for w in ["crypto", "bitcoin", "investment", "guaranteed return"]):
        whatsapp_indicators.append("Investment scam pattern")
    if "lottery" in text_lower or "you won" in text_lower:
        whatsapp_indicators.append("Lottery scam pattern")

    result["whatsapp_indicators"] = whatsapp_indicators
    result["platform"] = "whatsapp"
    return result


@app.post("/report/fraud-number")
async def report_fraud_number_endpoint(phone_number: str = Form(...), risk_score: int = Form(50)):
    """Report a phone number as fraudulent"""
    report_fraud_number(phone_number, risk_score)
    return {
        "status": "reported",
        "phone_number": phone_number,
        "total_reports": FRAUD_NUMBERS_CACHE[phone_number]["reports_count"],
        "current_risk_score": FRAUD_NUMBERS_CACHE[phone_number]["risk_score"],
    }


@app.post("/report/fraud-upi")
async def report_fraud_upi_endpoint(upi_id: str = Form(...), risk_score: int = Form(50)):
    """Report a UPI ID as fraudulent"""
    report_fraud_upi(upi_id, risk_score)
    return {
        "status": "reported",
        "upi_id": upi_id,
        "total_reports": FRAUD_UPI_CACHE[upi_id]["reports_count"],
        "current_risk_score": FRAUD_UPI_CACHE[upi_id]["risk_score"],
    }


@app.get("/threat-intel/phone/{phone_number}")
async def get_phone_threat_intel(phone_number: str):
    """Get complete threat intelligence for a phone number"""
    reputation = check_phone_reputation(phone_number)
    return {
        "phone_number": phone_number,
        "reputation": reputation,
        "fraud_database": {
            "in_database": phone_number in FRAUD_NUMBERS_CACHE,
            "reports_count": FRAUD_NUMBERS_CACHE.get(phone_number, {}).get("reports_count", 0),
            "risk_score": FRAUD_NUMBERS_CACHE.get(phone_number, {}).get("risk_score", 0),
        },
    }


@app.get("/threat-intel/stats")
async def get_threat_intel_stats():
    """Get statistics about the threat intelligence database"""
    return {
        "total_fraud_numbers": len(FRAUD_NUMBERS_CACHE),
        "total_fraud_upis": len(FRAUD_UPI_CACHE),
        "total_fraud_domains": len(FRAUD_DOMAIN_CACHE),
        "high_risk_numbers": sum(1 for v in FRAUD_NUMBERS_CACHE.values() if v.get("risk_score", 0) >= 70),
        "recent_reports": sum(1 for v in FRAUD_NUMBERS_CACHE.values() if v.get("last_reported", 0) > time.time() - 86400),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)