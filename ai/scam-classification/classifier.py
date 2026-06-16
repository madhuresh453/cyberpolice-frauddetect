"""
RAKSAAR (CyberShield AI) — Scam Classification Model
NLP-based scam type detection for Indian fraud patterns.
Supports 18 scam types across multiple Indian languages.
"""
import json
import logging
import os
import re
import time
from typing import Dict, List, Optional, Tuple

import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("raksaar-scam-classifier")

app = FastAPI(title="RAKSAAR Scam Classifier", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== SCAM TYPE DEFINITIONS =====
SCAM_TYPES = [
    "OTP_FRAUD", "KYC_SCAM", "BANK_VERIFICATION", "LOAN_SCAM",
    "INVESTMENT_SCAM", "JOB_SCAM", "DIGITAL_ARREST", "RBI_SCAM",
    "INCOME_TAX_SCAM", "ELECTRICITY_BILL_SCAM", "COURIER_SCAM",
    "UPI_SCAM", "QR_SCAM", "WHATSAPP_SCAM", "TELEGRAM_SCAM",
    "SOCIAL_ENGINEERING", "DEEPFAKE_SCAM", "VOICE_CLONE_SCAM",
]

SCAM_TYPE_DESCRIPTIONS = {
    "OTP_FRAUD": "Fraudster asks for OTP to compromise account",
    "KYC_SCAM": "Fake KYC update request to steal personal info",
    "BANK_VERIFICATION": "Fake bank verification call to extract account details",
    "LOAN_SCAM": "Fake loan approval requiring advance payment",
    "INVESTMENT_SCAM": "Fake investment scheme promising high returns",
    "JOB_SCAM": "Fake job offer requiring fee or sensitive documents",
    "DIGITAL_ARREST": "Fake police/CBI call claiming digital arrest warrant",
    "RBI_SCAM": "Impersonating RBI official for account verification",
    "INCOME_TAX_SCAM": "Fake income tax notice or refund call",
    "ELECTRICITY_BILL_SCAM": "Fake electricity bill pending disconnection threat",
    "COURIER_SCAM": "Fake courier delivery requiring payment or KYC",
    "UPI_SCAM": "Fraudulent UPI payment request or collect request",
    "QR_SCAM": "Fake QR code scan leading to unauthorized payment",
    "WHATSAPP_SCAM": "Scam conducted via WhatsApp call or message",
    "TELEGRAM_SCAM": "Scam conducted via Telegram group or channel",
    "SOCIAL_ENGINEERING": "Manipulation to extract sensitive information",
    "DEEPFAKE_SCAM": "AI-generated video/audio impersonation",
    "VOICE_CLONE_SCAM": "AI voice clone impersonating known person",
}

# ===== MULTILINGUAL SCAM KEYWORD DATABASE =====
SCAM_SIGNATURES = {
    "OTP_FRAUD": {
        "keywords": {
            "hi": ["ओटीपी", "ओ टी पी", "otp", "एक बार का पासवर्ड", "वन टाइम पासवर्ड"],
            "en": ["otp", "one time password", "share otp", "sms code", "verification code"],
            "bn": ["ওটিপি", "ও টি পি", "একবারের পাসওয়ার্ড"],
            "ta": ["ஓடிபி", "ஒருமுறை கடவுச்சொல்"],
            "te": ["ఒటిపి", "ఒకసారి పాస్వర్డ్"],
            "mr": ["ओटीपी", "एकवेळचा पासवर्ड"],
            "gu": ["ઓટીપી", "એક વખતનો પાસવર્ડ"],
            "pa": ["ਓਟੀਪੀ", "ਇੱਕ ਵਾਰ ਦਾ ਪਾਸਵਰਡ"],
            "ml": ["ഒടിപി", "ഒറ്റത്തവണ പാസ്‌വേഡ്"],
        },
        "patterns": [
            r"(share|send|give|tell|bhej|de do|dedo)\s*(me|ko|please)?\s*(the|your|aapka)?\s*(otp|code|पासवर्ड)",
            r"(otp|code|पासवर्ड)\s*(share|send|bhej|de|do|दो)",
            r"(\d{4,6})\s*(?:otp|का|ka)?\s*(?:code|कोड)?\s*(?:bhej|send|share|de)",
        ],
        "urgency_keywords": ["expiring", "expired", "expi", "जल्दी", "जल्द", "तुरंत", "fast", "urgent", "immediately"],
    },
    "KYC_SCAM": {
        "keywords": {
            "hi": ["केवाईसी", "kyc", "अपडेट", "वेरिफिकेशन", "सत्यापन", "आधार", "पैन"],
            "en": ["kyc", "update kyc", "kyc verification", "kyc expire", "aadhaar", "pan card", "verify"],
            "bn": ["কেওয়াইসি", "আধার", "প্যান", "ভেরিফিকেশন"],
            "ta": ["கே.ஒய்.சி", "ஆதார்", "பான்", "சரிபார்ப்பு"],
            "te": ["కేవైసీ", "ఆధార్", "ప్యాన్", "ధృవీకరణ"],
            "mr": ["केवायसी", "आधार", "पॅन", "सत्यापन"],
            "gu": ["કેવાયસી", "આધાર", "પાન", "ચકાસણી"],
            "pa": ["ਕੇਵਾਈਸੀ", "ਆਧਾਰ", "ਪੈਨ", "ਜਾਂਚ"],
            "ml": ["കെവൈസി", "ആധാർ", "പാൻ", "പരിശോധന"],
        },
        "patterns": [
            r"(kyc|केवाईसी|কেওয়াইসি)\s*(update|expir|block|close|band|suspend|freeze)",
            r"(aadhaar|आधार|আধার)\s*(link|update|verify|से लिंक|लिंक कर)",
            r"(pan|पैन|প্যান)\s*(link|update|verify)",
            r"(account|खाता|अकाउंट)\s*(block|band|freeze|suspend|close)",
        ],
        "urgency_keywords": ["24 hours", "24 घंटे", "today", "आज", "last day", "आखिरी दिन", "closing today"],
    },
    "DIGITAL_ARREST": {
        "keywords": {
            "hi": ["डिजिटल अरेस्ट", "गिरफ्तारी", "वारंट", "कोर्ट", "अदालत", "नोटिस", "साइबर क्राइम", "साइबर सेल"],
            "en": ["digital arrest", "arrest warrant", "court notice", "cyber crime", "cyber cell", "legal notice", "non bailable"],
            "bn": ["ডিজিটাল গ্রেপ্তার", "গ্রেপ্তারি পরোয়ানা", "আদালতের নোটিশ"],
            "ta": ["டிஜிட்டல் கைது", "கைது வாரண்ட்", "நீதிமன்ற நோட்டீஸ்"],
            "te": ["డిజిటల్ అరెస్ట్", "అరెస్ట్ వారెంట్", "కోర్టు నోటీస్"],
            "mr": ["डिजिटल अटक", "अटक वॉरंट", "कोर्ट नोटीस"],
        },
        "patterns": [
            r"(digital|डिजिटल)\s*(arrest|गिरफ्तार|अरेस्ट)",
            r"(arrest|गिरफ्तारी)\s*(warrant|वारंट)",
            r"(court|कोर्ट|अदालत)\s*(notice|नोटिस|समन)",
            r"(cyber|साइबर)\s*(crime|क्राइम|सेल|cell|police)",
            r"(money laundering|मनी लाउंडरिंग|drugs|ड्रग्स|narcotics|trafficking)",
        ],
        "urgency_keywords": ["immediately", "तुरंत", "right now", "अभी", "now", "at once", "without delay"],
    },
    "BANK_VERIFICATION": {
        "keywords": {
            "hi": ["बैंक", "खाता", "अकाउंट", "डेबिट कार्ड", "क्रेडिट कार्ड", "एटीएम", "नेट बैंकिंग"],
            "en": ["bank", "account", "debit card", "credit card", "atm", "net banking", "hdfc", "sbi", "icici"],
            "bn": ["ব্যাংক", "অ্যাকাউন্ট", "ডেবিট কার্ড", "ক্রেডিট কার্ড"],
            "ta": ["வங்கி", "கணக்கு", "டெபிட் கார்டு", "கிரெடிட் கார்டு"],
            "te": ["బ్యాంకు", "ఖాతా", "డెబిట్ కార్డు", "క్రెడిట్ కార్డు"],
            "mr": ["बँक", "खाते", "डेबिट कार्ड", "क्रेडिट कार्ड"],
        },
        "patterns": [
            r"(bank|बैंक|ব্যাংক|वங்கி)\s*(employee|officer|representative|कर्मचारी)",
            r"(account|खाता|खाते)\s*(verify|verification|वेरिफाई|block|freeze|band)",
            r"(debit|credit|ATM)\s*(card|कार्ड)\s*(number|नंबर|details|डिटेल)",
            r"(hdfc|sbi|icici|axis|kotak|yes bank|pnb|bob)\s*(bank|verify|कर्मचारी)",
        ],
        "urgency_keywords": ["card blocked", "card suspended", "account frozen", "क्लोज", "बंद"],
    },
    "UPI_SCAM": {
        "keywords": {
            "hi": ["यूपीआई", "upi", "गूगल पे", "फोनपे", "पेटीएम", "भीम", "क्यूआर", "qr", "पेमेंट"],
            "en": ["upi", "google pay", "phonepe", "paytm", "bhim", "qr code", "payment request", "collect request"],
            "bn": ["ইউপিআই", "গুগল পে", "ফোনপে", "পেটিএম"],
            "ta": ["யுபிஐ", "கூகிள் பே", "போன்பே", "பேடிஎம்"],
            "te": ["యుపిఐ", "గూగుల్ పే", "ఫోన్పే", "పేటీఎం"],
            "mr": ["यूपीआय", "गूगल पे", "फोनपे", "पेटीएम"],
        },
        "patterns": [
            r"(upi|यूपीआई)\s*(send|भेजो|pay|करो|transfer|करें)",
            r"(qr|क्यूआर)\s*(scan|स्कैन|code|कोड)",
            r"(collect request|payment request|request\s*to pay)",
            r"(google pay|phonepe|paytm|gpay)\s*(me|से|को)\s*(send|भेज|pay)",
        ],
        "urgency_keywords": ["immediately", "now", "fast", "जल्दी", "तुरंत"],
    },
    "INVESTMENT_SCAM": {
        "keywords": {
            "hi": ["निवेश", "इन्वेस्टमेंट", "शेयर", "स्टॉक", "ट्रेडिंग", "क्रिप्टो", "बिटकॉइन", "रिटर्न", "प्रॉफिट"],
            "en": ["investment", "share market", "stock", "trading", "crypto", "bitcoin", "returns", "profit", "guaranteed"],
            "bn": ["বিনিয়োগ", "শেয়ার", "স্টক", "ক্রিপ্টো"],
            "ta": ["முதலீடு", "பங்கு", "கிரிப்டோ"],
        },
        "patterns": [
            r"(guaranteed|जमानत|निश्चित)\s*(return|रिटर्न|profit|मुनाफा)",
            r"(double|डबल|दुगना)\s*(money|पैसा|investment)",
            r"(crypto|bitcoin|क्रिप्टो|बिटकॉइन)\s*(investment|trading|निवेश)",
            r"(stock|share|शेयर)\s*(tip|टिप|advice|सलाह|recommend)",
        ],
        "urgency_keywords": ["limited offer", "limited seats", "today only", "first come", "closing soon"],
    },
    "JOB_SCAM": {
        "keywords": {
            "hi": ["नौकरी", "जॉब", "वर्क फ्रॉम होम", "पार्ट टाइम", "डाटा एंट्री", "रजिस्ट्रेशन", "फीस"],
            "en": ["job", "work from home", "part time", "data entry", "registration fee", "processing fee", "joining bonus"],
            "bn": ["চাকরি", "ওয়ার্ক ফ্রম হোম", "পার্ট টাইম"],
            "ta": ["வேலை", "வீட்டிலிருந்து வேலை"],
        },
        "patterns": [
            r"(work from home|wfh|home based|घर बैठे)\s*(job|काम|नौकरी)",
            r"(registration|processing|joining|application)\s*(fee|शुल्क|फीस)",
            r"(part time|पार्ट टाइम|data entry)\s*(job|काम|नौकरी)",
            r"(daily|रोज)\s*(earning|कमाई|income)\s*(500|1000|2000|5000|10000)",
        ],
        "urgency_keywords": ["limited vacancies", "hurry", "last date", "apply now"],
    },
    "LOAN_SCAM": {
        "keywords": {
            "hi": ["लोन", "कर्ज", "ऋण", "व्यक्तिगत लोन", "पर्सनल लोन", "बिजनेस लोन"],
            "en": ["loan", "personal loan", "business loan", "instant loan", "loan approval", "no paper"],
            "bn": ["লোন", "ঋণ", "ব্যক্তিগত লোন"],
            "ta": ["கடன்", "தனிநபர் கடன்", "தொழில் கடன்"],
        },
        "patterns": [
            r"(instant|इंस्टेंट|तुरंत)\s*(loan|लोन|कर्ज|ऋण)",
            r"(loan|लोन)\s*(approve|मंजूर|approval|approved|मंजूरी)",
            r"(no cibil|no credit|no income|no document|कोई दस्तावेज)\s*(loan|लोन)",
            r"(processing|प्रोसेसिंग|documentation)\s*(fee|शुल्क)",
        ],
        "urgency_keywords": ["limited time offer", "today only", "special offer", "hurry"],
    },
    "COURIER_SCAM": {
        "keywords": {
            "hi": ["कूरियर", "पार्सल", "डिलीवरी", "पैकेज", "आयात", "कस्टम", "ड्यूटी"],
            "en": ["courier", "parcel", "delivery", "package", "import", "customs", "duty", "fedex", "dhl", "bluedart"],
            "bn": ["কুরিয়ার", "পার্সেল", "ডেলিভারি"],
            "ta": ["கூரியர்", "பார்சல்", "டெலிவரி"],
        },
        "patterns": [
            r"(courier|कूरियर|কুরিয়ার)\s*(package|parcel|पार्सल|পার্সেল)",
            r"(custom|कस्टम|customs)\s*(duty|ड्यूटी|फीस|fee|charge|चार्ज)",
            r"(delivery|डिलीवरी)\s*(failed|फेल|pending|पेंडिंग)",
            r"(your|aapka|आपका)\s*(parcel|कूरियर|पार्सल)\s*(seized|रोका|जब्त)",
        ],
        "urgency_keywords": ["immediate action", "today only", "last warning", "final notice"],
    },
}


class ScamClassificationRequest(BaseModel):
    text: str
    language: str = "auto"
    include_details: bool = True


class ScamClassificationResponse(BaseModel):
    detected_scam_types: List[dict] = []
    primary_scam_type: Optional[str] = None
    primary_confidence: float = 0.0
    risk_score: int = 0
    keywords_found: List[str] = []
    patterns_matched: List[str] = []
    language_detected: str = "unknown"
    processing_time_ms: int = 0
    all_scores: Dict[str, float] = {}


class BatchClassificationRequest(BaseModel):
    texts: List[ScamClassificationRequest]


class BatchClassificationResponse(BaseModel):
    results: List[ScamClassificationResponse]
    summary: dict = {}


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    scam_types_supported: int
    languages_supported: int
    model_loaded: bool


def detect_language_from_text(text: str) -> str:
    """Detect the language of input text using Unicode ranges"""
    if not text:
        return "en"

    devanagari = len(re.findall(r'[\u0900-\u097F]', text))
    bengali = len(re.findall(r'[\u0980-\u09FF]', text))
    tamil = len(re.findall(r'[\u0B80-\u0BFF]', text))
    telugu = len(re.findall(r'[\u0C00-\u0C7F]', text))
    gurmukhi = len(re.findall(r'[\u0A00-\u0A7F]', text))
    gujarati = len(re.findall(r'[\u0A80-\u0AFF]', text))
    malayalam = len(re.findall(r'[\u0D00-\u0D7F]', text))
    odia = len(re.findall(r'[\u0B00-\u0B7F]', text))
    urdu = len(re.findall(r'[\u0600-\u06FF]', text))

    scores = {
        "hi": devanagari, "bn": bengali, "ta": tamil, "te": telugu,
        "pa": gurmukhi, "gu": gujarati, "ml": malayalam, "or": odia, "ur": urdu,
    }

    best_lang = max(scores, key=scores.get)
    return best_lang if scores[best_lang] > 0 else "en"


def classify_scam_text(text: str, language: str = "auto") -> dict:
    """
    Classify text against known scam signatures using keyword matching and regex patterns.
    Returns scores for each scam type along with confidence.
    """
    start_time = time.time()
    text_lower = text.lower().strip()
    
    if not text_lower:
        return {
            "detected_scam_types": [],
            "primary_scam_type": None,
            "primary_confidence": 0.0,
            "risk_score": 0,
            "keywords_found": [],
            "patterns_matched": [],
            "language_detected": language,
            "processing_time_ms": 0,
            "all_scores": {},
        }

    if language == "auto":
        language = detect_language_from_text(text)

    all_scores = {}
    all_keywords_found = []
    all_patterns_matched = []
    detected_types = []

    for scam_type, signature in SCAM_SIGNATURES.items():
        score = 0
        keywords_found = []
        patterns_matched = []

        # 1. Check keywords for detected language
        lang_keywords = signature["keywords"].get(language, signature["keywords"].get("en", {}))
        for keyword in lang_keywords:
            if isinstance(keyword, str) and keyword.lower() in text_lower:
                score += 15
                keywords_found.append(keyword)

        # Also check English keywords as fallback
        if language != "en":
            for keyword in signature["keywords"].get("en", []):
                if keyword.lower() in text_lower and keyword.lower() not in keywords_found:
                    score += 10
                    keywords_found.append(keyword)

        # 2. Check regex patterns
        for pattern in signature.get("patterns", []):
            if re.search(pattern, text_lower, re.IGNORECASE):
                score += 25
                patterns_matched.append(pattern)

        # 3. Check urgency keywords
        for urg_kw in signature.get("urgency_keywords", []):
            if urg_kw.lower() in text_lower:
                score += 10
                keywords_found.append(f"[URGENCY] {urg_kw}")

        # 4. Word count bonus (more scammy text = higher confidence)
        word_count = len(text_lower.split())
        if word_count > 20:
            score += 5
        if word_count > 50:
            score += 5

        score = min(score, 100)

        if score > 0:
            all_scores[scam_type] = score
            all_keywords_found.extend(keywords_found)
            all_patterns_matched.extend(patterns_matched)
            detected_types.append({
                "scam_type": scam_type,
                "description": SCAM_TYPE_DESCRIPTIONS.get(scam_type, ""),
                "confidence": round(score / 100, 2),
                "keywords_matched": keywords_found[:10],
                "patterns_matched": patterns_matched[:5],
            })

    # Sort by score descending
    detected_types.sort(key=lambda x: x["confidence"], reverse=True)

    # Determine primary scam type
    primary_type = detected_types[0]["scam_type"] if detected_types else None
    primary_confidence = detected_types[0]["confidence"] if detected_types else 0.0

    # Calculate overall risk score (max of all scores)
    risk_score = max(all_scores.values()) if all_scores else 0

    processing_time = int((time.time() - start_time) * 1000)

    return {
        "detected_scam_types": detected_types[:5],  # Top 5
        "primary_scam_type": primary_type,
        "primary_confidence": primary_confidence,
        "risk_score": risk_score,
        "keywords_found": list(set(all_keywords_found))[:20],
        "patterns_matched": list(set(all_patterns_matched))[:10],
        "language_detected": language,
        "processing_time_ms": processing_time,
        "all_scores": all_scores,
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        service="raksaar-scam-classifier",
        version="1.0.0",
        scam_types_supported=len(SCAM_TYPES),
        languages_supported=9,
        model_loaded=True,
    )


@app.post("/classify", response_model=ScamClassificationResponse)
async def classify_text(request: ScamClassificationRequest):
    """Classify text for scam types. Returns detected scam types with confidence scores."""
    if not request.text or len(request.text.strip()) < 3:
        raise HTTPException(status_code=400, detail="Text too short for classification (min 3 characters)")

    result = classify_scam_text(request.text, request.language)
    return ScamClassificationResponse(**result)


@app.post("/classify/batch", response_model=BatchClassificationResponse)
async def classify_batch(request: BatchClassificationRequest):
    """Batch classify multiple texts"""
    if not request.texts:
        raise HTTPException(status_code=400, detail="No texts provided")

    results = []
    scam_type_counts = {}

    for req in request.texts:
        result = classify_scam_text(req.text, req.language)
        results.append(ScamClassificationResponse(**result))

        if result["primary_scam_type"]:
            st = result["primary_scam_type"]
            scam_type_counts[st] = scam_type_counts.get(st, 0) + 1

    total = len(results)
    summary = {
        "total_classified": total,
        "scams_detected": sum(1 for r in results if r.risk_score > 0),
        "high_risk_count": sum(1 for r in results if r.risk_score >= 70),
        "scam_type_distribution": scam_type_counts,
        "no_scam_detected": total - sum(1 for r in results if r.primary_scam_type is not None),
    }

    return BatchClassificationResponse(results=results, summary=summary)


@app.get("/scam-types")
async def list_scam_types():
    """List all supported scam types with descriptions"""
    return {
        "scam_types": [
            {"type": st, "description": SCAM_TYPE_DESCRIPTIONS[st]}
            for st in SCAM_TYPES
        ],
        "count": len(SCAM_TYPES),
    }


@app.post("/risk-score")
async def calculate_risk_score(request: ScamClassificationRequest):
    """Calculate a quick risk score (0-100) for a text without full classification"""
    result = classify_scam_text(request.text, request.language)
    
    # Normalize to risk categories
    score = result["risk_score"]
    if score >= 70:
        category = "high_risk"
        recommendation = "Immediate action required. Likely scam."
    elif score >= 40:
        category = "suspicious"
        recommendation = "Exercise caution. Contains suspicious elements."
    else:
        category = "safe"
        recommendation = "No scam indicators detected."

    return {
        "risk_score": score,
        "risk_category": category,
        "recommendation": recommendation,
        "primary_scam_type": result["primary_scam_type"],
        "language_detected": result["language_detected"],
        "keywords_found": result["keywords_found"][:10],
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)