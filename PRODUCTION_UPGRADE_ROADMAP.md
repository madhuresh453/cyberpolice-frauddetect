# RAKSAAR (CyberShield AI) — Production-Grade Upgrade Roadmap

## Executive Summary

This document provides a complete strategic review of the CyberShield AI project and a step-by-step upgrade roadmap to transform it into a production-ready, government-implementable national cyber fraud prevention ecosystem.

### Current State Assessment

| Layer | Status | Details |
|-------|--------|---------|
| **Backend (Node.js/Express)** | ✅ Working | Auth, health, risk-scoring engine, route registry |
| **Database (MongoDB Atlas)** | ✅ Working | 18 Mongoose models, collections verified |
| **Auth System** | ✅ Complete | JWT, Google OAuth, Phone/OTP, MFA, RBAC, sessions |
| **Risk Scoring Engine** | ✅ Complete | Keyword analysis, phone/URL/transaction scoring |
| **Microservice Stubs** | ❌ 21/21 stubs | Only auth-service has real implementation |
| **AI Services** | ❌ 9/9 stubs | No actual ML models deployed |
| **Frontend (Flutter/Android)** | ❌ Stub | Scaffold only, no runnable code |
| **Police Portal (Next.js)** | ❌ Stub | No package.json, no code |
| **Government Integrations** | ❌ All stubs | Sanchar Saathi, TRAI, NCPI, CERT-In not connected |
| **Real-time System** | ❌ Missing | No WebSockets, Kafka, event streaming |
| **Legal Compliance** | ❌ Missing | No DPDP Act, IT Act, CERT-In compliance docs |

---

## PHASE 1: Core Backend Upgrades (Weeks 1-4)

### 1.1 Fix Port Conflicts & Monorepo Architecture

**Problem**: Express (port 5000) and FastAPI auth-service (port 5000) conflict.

**Solution**:
```
- Express backend → port 5000
- FastAPI auth-service → port 5001
- Python AI inference → port 5002
- WebSocket server → port 5003
```

Create a proper API Gateway (already stubbed at `backend/services/api-gateway/`) that routes:
- `/api/v1/auth/*` → auth-service (port 5001)
- `/api/v1/citizen/*` → citizen-service
- `/api/v1/police/*` → police-service
- `/api/v1/ai/*` → AI inference engine (port 5002)
- `/ws/*` → WebSocket server (port 5003)

### 1.2 Implement All 20 Microservices

Currently 21/21 services are stubs. The **priority order** for implementation:

| Priority | Service | Why Critical |
|----------|---------|--------------|
| **P0** | citizen-service | User management, permissions, profile |
| **P0** | police-service | Case management, officer workflows |
| **P0** | evidence-service | Cryptographic evidence vault |
| **P1** | scam-analysis-service | Real-time call/SMS/WhatsApp analysis |
| **P1** | notification-service | Push alerts to citizens & police |
| **P1** | websocket-service | Real-time sync citizen ↔ police ↔ AI |
| **P2** | upi-fraud-service | UPI transaction monitoring |
| **P2** | sms-analysis-service | SMS phishing detection |
| **P2** | whatsapp-analysis-service | WhatsApp scam detection |
| **P3** | deepfake-detection-service | Voice clone & deepfake detection |
| **P3** | threat-intelligence-service | National fraud database |
| **P3** | campaign-correlation-service | Scam network detection |
| **P4** | bank-integration-service | Bank API bridge |
| **P4** | emergency-response-service | 1930 integration |
| **P4** | analytics-service | National dashboards |
| **P4** | reporting-service | FIR generation |
| **P5** | audit-service | SIEM, audit logs |
| **P5** | file-storage-service | Evidence file storage |
| **P5** | graph-intelligence-service | Network graphs |
| **P5** | isp-service | ISP integration |

### 1.3 Add Missing Critical Routes

The current `app.js` has auth routes but no citizen/police operational routes:

```
POST /api/v1/citizen/report-fraud        → File a complaint
GET  /api/v1/citizen/cases               → My cases list
GET  /api/v1/citizen/cases/:id           → Case details + evidence
POST /api/v1/citizen/emergency/sos       → SOS alert to police + family
POST /api/v1/citizen/family/add          → Add family member to dashboard
GET  /api/v1/citizen/family/alerts       → Family scam alerts

POST /api/v1/police/cases                → List all cases (filtered by jurisdiction)
GET  /api/v1/police/cases/:id            → Case with full evidence
PATCH /api/v1/police/cases/:id/status    → Update case status
POST /api/v1/police/cases/:id/assign     → Assign officer
POST /api/v1/police/osint/number         → Number intelligence lookup
POST /api/v1/police/osint/email          → Email intelligence lookup
POST /api/v1/police/osint/domain         → Domain intelligence lookup
GET  /api/v1/police/link-analysis/:id    → Network graph data

GET  /api/v1/government/heatmap          → National fraud heatmap data
GET  /api/v1/government/stats            → National statistics
GET  /api/v1/government/cases            → All cases (MHA/CERT-In view)
```

---

## PHASE 2: AI Engine Implementation (Weeks 3-8)

### 2.1 Speech-to-Text Pipeline (Highest Priority)

The entire system depends on real-time call analysis. Without STT, nothing works.

**Implementation Plan**:

```python
# ai/speech-to-text/service.py — Production architecture

# Tier 1: On-device (privacy-first, low-latency)
# Use: Whisper-tiny (quantized) via ONNX Runtime
# For: Real-time transcription on citizen's phone
# Privacy: Audio NEVER leaves device
# Only: Transcription text sent to cloud for analysis

# Tier 2: Cloud (for evidence and police cases)
# Use: Bhashini API (Government of India - FREE)
#   - Supports 22 Indian languages
#   - Code-mixed detection (Hinglish, Tanglish)
#   - MeitY-approved, government-compliant
# For: Full transcript generation for evidence packages

# Flow:
# 1. Audio stream from phone microphone
# 2. On-device Whisper → real-time transcription (inference every 2 seconds)
# 3. Transcription chunks sent to risk-scoring-engine via WebSocket
# 4. If scam detected → full audio saved locally → sent to evidence service
# 5. Evidence service calls Bhashini API for full multilingual transcript
# 6. Transcript + risk score → evidence package
```

**Files to create**:
```
ai/speech-to-text/
  ├── ondevice/
  │   ├── whisper_tiny_onnx.py    # Quantized model for Flutter/Android
  │   └── model_converter.py       # Script to convert/quantize models
  ├── cloud/
  │   ├── bhashini_client.py       # Bhashini API integration
  │   └── multilingual_stt.py      # Language detection + STT routing
  ├── service.py                   # FastAPI inference service (port 5002)
  ├── Dockerfile
  └── requirements.txt
```

### 2.2 Multilingual Keyword Engine (Critical Upgrade)

The current `risk-scoring.service.js` only has **English keywords**. For India, you need keywords in all major languages.

**Upgrade to**:

```javascript
// backend/services/risk-scoring.service.js — Multilingual upgrade

const SCAM_KEYWORDS_MULTILINGUAL = {
  // Hindi scam keywords
  "ओटीपी": { weight: 20, lang: "hi", category: "OTP_FRAUD" },
  "खाता नंबर": { weight: 18, lang: "hi", category: "BANK_FRAUD" },
  "बैंक खाता": { weight: 15, lang: "hi", category: "BANK_FRAUD" },
  "आधार नंबर": { weight: 15, lang: "hi", category: "KYC_FRAUD" },
  "वेरिफिकेशन": { weight: 15, lang: "hi", category: "KYC_FRAUD" },
  "KYC अपडेट": { weight: 20, lang: "hi", category: "KYC_FRAUD" },
  "पुलिस": { weight: 18, lang: "hi", category: "IMPERSONATION" },
  "डिजिटल अरेस्ट": { weight: 30, lang: "hi", category: "DIGITAL_ARREST" },
  "पैसा ट्रांसफर": { weight: 25, lang: "hi", category: "FRAUD" },
  "लॉटरी": { weight: 20, lang: "hi", category: "PRIZE_SCAM" },
  "नौकरी": { weight: 15, lang: "hi", category: "JOB_SCAM" },
  "कस्टमर केयर": { weight: 10, lang: "hi", category: "IMPERSONATION" },

  // Bengali
  "অ্যাকাউন্ট নম্বর": { weight: 18, lang: "bn", category: "BANK_FRAUD" },
  "ওটিপি": { weight: 20, lang: "bn", category: "OTP_FRAUD" },
  "ভেরিফিকেশন": { weight: 15, lang: "bn", category: "KYC_FRAUD" },

  // Tamil
  "கணக்கு எண்": { weight: 18, lang: "ta", category: "BANK_FRAUD" },
  "பணம் அனுப்பு": { weight: 25, lang: "ta", category: "FRAUD" },
  "OTC": { weight: 20, lang: "ta", category: "OTP_FRAUD" },

  // Telugu
  "ఖాతా నంబర్": { weight: 18, lang: "te", category: "BANK_FRAUD" },
  "ధృవీకరణ": { weight: 15, lang: "te", category: "KYC_FRAUD" },

  // Marathi
  "खाते क्रमांक": { weight: 18, lang: "mr", category: "BANK_FRAUD" },
  "पैसे पाठवा": { weight: 25, lang: "mr", category: "FRAUD" },

  // More languages...
  "ખાતા નંબર": { weight: 18, lang: "gu", category: "BANK_FRAUD" },
  "ਖਾਤਾ ਨੰਬਰ": { weight: 18, lang: "pa", category: "BANK_FRAUD" },
  "അക്കൗണ്ട് നമ്പർ": { weight: 18, lang: "ml", category: "BANK_FRAUD" },
};
```

### 2.3 Scam Classification Model

Create a proper ML model trained on Indian scam patterns:

```python
# ai/scam-classification/model.py

import torch
import torch.nn as nn
from transformers import AutoModelForSequenceClassification, AutoTokenizer

class ScamClassifier:
    """
    Fine-tuned BERT-based model for Indian scam detection.
    
    Training Data Sources:
    - NCRB cybercrime reports (public dataset)
    - CyberPeace Foundation scam transcripts
    - I4C (Indian Cyber Crime Coordination Centre) data
    - User-reported scam transcripts (anonymized)
    
    Scam Types (18 classes):
    OTP_FRAUD, KYC_SCAM, BANK_VERIFICATION, LOAN_SCAM,
    INVESTMENT_SCAM, JOB_SCAM, DIGITAL_ARREST, RBI_SCAM,
    INCOME_TAX_SCAM, ELECTRICITY_BILL_SCAM, COURIER_SCAM,
    UPI_SCAM, QR_SCAM, WHATSAPP_SCAM, TELEGRAM_SCAM,
    SOCIAL_ENGINEERING, DEEPFAKE_SCAM, VOICE_CLONE_SCAM
    """
    
    def __init__(self, model_name="ai4bharat/indic-bert"):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSequenceClassification.from_pretrained(
            model_name,
            num_labels=18  # 18 scam types
        )
    
    def predict(self, text, language="hi"):
        """Predict scam type and confidence"""
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
        outputs = self.model(**inputs)
        probabilities = torch.nn.functional.softmax(outputs.logits, dim=-1)
        predicted_class = torch.argmax(probabilities, dim=-1).item()
        confidence = probabilities[0][predicted_class].item()
        return {
            "scam_type": self.SCAM_TYPES[predicted_class],
            "confidence": confidence,
            "all_scores": {self.SCAM_TYPES[i]: probabilities[0][i].item() 
                          for i in range(18)}
        }
```

### 2.4 Voice Risk Analysis & Deepfake Detection

```python
# ai/deepfake-detection/service.py

"""
Deepfake voice detection pipeline:

Layer 1: Spectrogram Analysis
  - Convert audio to Mel-spectrogram
  - CNN-based classifier (ResNet-18 pretrained)
  - Detect synthetic voice artifacts

Layer 2: Liveness Detection
  - Analyze breath patterns, natural pauses
  - Detect robotic/synthetic cadence
  - Voice clone detection (mismatch with real human patterns)

Layer 3: Cross-reference
  - Compare with known voice samples in database
  - If caller claims to be official → match with verified voiceprint

Output:
{
  "is_deepfake": false,
  "confidence": 0.95,
  "detection_layers": [
    {"layer": "spectrogram", "score": 0.98, "verdict": "real"},
    {"layer": "liveness", "score": 0.92, "verdict": "real"}
  ],
  "voice_clone_probability": 0.01
}
"""
```

### 2.5 AI Investigator & Report Generator

```python
# ai/intent-analysis/investigator.py

"""
AI Investigator — Automated case analysis and report generation.

When scam is detected:
1. Collect all evidence (transcript, risk score, number data)
2. Run OSINT on phone number (social media, UPI linked, etc.)
3. Cross-reference with national fraud database
4. Build suspect profile
5. Generate case summary for police
6. Draft FIR using template (CrPC format)
7. Calculate fraud network connections
8. Estimate financial damage

Output: Complete investigation package ready for police action
"""
```

---

## PHASE 3: Flutter Citizen App (Weeks 5-10)

### 3.1 Core Architecture

The current Flutter app is a scaffold. It needs a complete rebuild with:

```
apps/citizen-mobile/
├── lib/
│   ├── main.dart                    # Entry point with background service init
│   ├── app.dart                     # MaterialApp with routing
│   ├── core/
│   │   ├── theme.dart               # Raksaar design system (govt-grade UI)
│   │   ├── constants.dart           # API URLs, colors, strings
│   │   ├── auth/
│   │   │   ├── auth_provider.dart    # State management for auth
│   │   │   ├── token_storage.dart    # Secure token storage (flutter_secure_storage)
│   │   │   └── auth_service.dart     # API calls for auth
│   │   ├── services/
│   │   │   ├── websocket_service.dart # Real-time event streaming
│   │   │   ├── background_service.dart # Always-on monitoring (flutter_background_service)
│   │   │   ├── call_detector.dart    # Phone call state detection
│   │   │   ├── sms_monitor.dart      # SMS reading (permission-based)
│   │   │   └── notification_service.dart # Firebase push notifications
│   │   └── utils/
│   │       ├── permissions.dart      # Permission request manager
│   │       └── evidence_export.dart  # Generate evidence package
│   ├── features/
│   │   ├── splash/
│   │   ├── onboarding/              # 3-step onboarding screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # Email + Google + Phone login
│   │   │   ├── register_screen.dart
│   │   │   ├── otp_screen.dart
│   │   │   └── biometric_screen.dart # Fingerprint/Face unlock
│   │   ├── home/                    # Dashboard with live protection status
│   │   ├── call-protection/         # Real-time call analysis screens
│   │   ├── sms-protection/          # SMS analysis
│   │   ├── whatsapp-protection/     # WhatsApp link/message scanning
│   │   ├── upi-protection/          # UPI transaction monitoring
│   │   ├── family-protection/       # Family dashboard
│   │   ├── emergency/               # SOS, cyber emergency
│   │   ├── learning/                # Scam awareness training
│   │   ├── reports/                 # Case history, evidence viewer
│   │   └── profile/                 # Settings, permissions, security
│   └── widgets/                     # Reusable UI components
```

### 3.2 Critical Android Permissions

The app requires these permissions for full functionality:

| Permission | Purpose | Legal Basis |
|------------|---------|-------------|
| `RECORD_AUDIO` | Real-time call analysis | User consent (DPDP Act) |
| `READ_PHONE_STATE` | Detect incoming calls | Telecom licence condition |
| `READ_CALL_LOG` | Caller identification | User consent |
| `READ_SMS` | SMS scam detection | User consent |
| `FOREGROUND_SERVICE` | Always-on monitoring | User consent |
| `ACCESS_FINE_LOCATION` | Evidence geotagging, heatmap | User consent |
| `READ_CONTACTS` | Identify known vs unknown callers | User consent |
| `CAMERA` | QR code scanner | User consent |
| `INTERNET` | API communication | Required |
| `POST_NOTIFICATIONS` | Scam alerts | Required |
| `SYSTEM_ALERT_WINDOW` | Overlay scam warning during calls | User consent |
| `BIND_ACCESSIBILITY_SERVICE` | WhatsApp message reading | User consent |

**Implementation**: Create a granular permission flow:
1. On first launch → request essential permissions only
2. Feature-by-feature → request when first needed
3. Permission dashboard → show status, allow user to revoke

### 3.3 Real-time Call Interception Flow

This is the **core feature**. The complete flow:

```
1. Phone receives call from unknown number
2. Flutter background service detects incoming call
3. Service checks number against:
   a. User's contacts → if known, STOP
   b. Official number database → if verified, STOP
   c. National fraud database → if flagged, IMMEDIATE RED ALERT
4. If unknown → start recording (with user's consent)
5. Audio stream sent to on-device Whisper STT
6. Text chunks sent to risk-scoring-engine via WebSocket
7. Real-time risk score updates displayed on screen
8. If risk > 70% → auto-activate full analysis
9. If scam confirmed → generate evidence, show alert
10. Options: Block call, report to police, save evidence
```

### 3.4 Real-time UI Updates via WebSocket

```dart
// apps/citizen-mobile/lib/core/services/websocket_service.dart

class WebSocketService {
  WebSocketChannel? _channel;
  
  void connect(String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://api.raksaar.gov.in/ws/citizen?token=$token'),
    );
    
    _channel!.stream.listen((message) {
      final event = jsonDecode(message);
      switch (event['type']) {
        case 'call_analysis_update':
          // Update risk score in real-time
          break;
        case 'sms_scam_detected':
          // Show SMS alert
          break;
        case 'upi_fraud_alert':
          // Block transaction warning
          break;
        case 'family_alert':
          // Family member scam detected
          break;
        case 'police_case_update':
          // Your reported case status changed
          break;
        case 'emergency_broadcast':
          // Government fraud alert broadcast
          break;
      }
    });
  }
}
```

---

## PHASE 4: Police Portal (Weeks 6-10)

### 4.1 Next.js Police Dashboard

Create a full-featured Next.js portal at `apps/police-portal/`:

```
police-portal/
├── app/
│   ├── layout.tsx              # App shell with sidebar navigation
│   ├── page.tsx                # Login page (MFA required)
│   ├── dashboard/
│   │   ├── page.tsx            # Live complaint queue
│   │   ├── high-risk.tsx       # High-risk cases priority view
│   │   └── stats.tsx           # Officer performance metrics
│   ├── cases/
│   │   ├── page.tsx            # All cases with filters
│   │   ├── [id]/
│   │   │   ├── page.tsx        # Case detail view
│   │   │   ├── evidence.tsx    # Evidence viewer (transcript, audio, OSINT)
│   │   │   └── timeline.tsx    # Case timeline reconstruction
│   ├── osint/
│   │   ├── page.tsx            # OSINT investigation dashboard
│   │   ├── number.tsx          # Phone number intelligence
│   │   ├── email.tsx           # Email intelligence
│   │   ├── domain.tsx          # Domain intelligence
│   │   └── social.tsx          # Social media intelligence
│   ├── network/
│   │   ├── page.tsx            # Link analysis & network graphs
│   │   └── clusters.tsx        # Fraud cluster detection
│   ├── report/
│   │   ├── fir.tsx             # AI-generated FIR drafts
│   │   └── export.tsx          # Evidence package export (court-ready)
│   └── admin/
│       ├── officers.tsx        # Officer management
│       └── jurisdictions.tsx   # Jurisdiction configuration
├── components/
│   ├── ui/                     # Shadcn UI components
│   ├── charts/                 # Fraud heatmap, trend charts
│   ├── graphs/                 # Force-directed network graphs (D3.js)
│   └── evidence/               # Audio player, transcript viewer
└── lib/
    ├── api.ts                  # API client with JWT auth
    └── websocket.ts            # Real-time WebSocket client
```

---

## PHASE 5: Government Integrations (Weeks 8-14)

### 5.1 Sanchar Saathi Integration (TRAI)

The government's telecom fraud portal. Needed for:
- Report fraudulent numbers
- Check number ownership
- Request SIM blocking
- Access DND violation data

```python
# government-integrations/sanchar-saathi/client.py

import requests
from typing import Optional

class SancharSaathiClient:
    """
    Sanchar Saathi - Department of Telecommunications, Government of India
    API for telecom fraud reporting and number intelligence.
    
    Note: Requires official partnership with DoT/TRAI for API access.
    For demo/prototype: Use manual fallback (web scraping with permission).
    """
    
    def __init__(self, api_key: str, api_secret: str):
        self.base_url = "https://api.sancharsaathi.gov.in/v1"
        self.api_key = api_key
        self.api_secret = api_secret
    
    def check_number_reputation(self, phone_number: str) -> dict:
        """
        Check if a number has been reported for fraud.
        Returns: { is_reported, reports_count, categories, last_reported_date }
        """
        pass  # Implement when API access is granted
    
    def report_number(self, phone_number: str, complaint_id: str, evidence_hash: str):
        """
        Report a confirmed fraudulent number for SIM blocking.
        Used by police after investigation.
        """
        pass
```

### 5.2 Bhashini API Integration (MeitY)

Government's AI language translation service. CRITICAL for multilingual support.

```python
# government-integrations/bhashini/client.py

class BhashiniClient:
    """
    Bhashini - National Language Translation Mission, MeitY
    Free API for Indian language AI services.
    """
    
    def __init__(self, api_key: str, user_id: str):
        self.base_url = "https://api.bhashini.gov.in/v1"
        self.api_key = api_key
    
    def speech_to_text(self, audio_bytes: bytes, source_language: str = "auto") -> dict:
        """
        Convert speech to text in Indian languages.
        Supports all 22 scheduled languages + English.
        Auto-detects language in code-mixed speech.
        """
        pass
    
    def translate(self, text: str, source_lang: str, target_lang: str) -> str:
        """
        Translate between Indian languages.
        Used to convert scam transcripts to Hindi/English for police.
        """
        pass
    
    def text_to_speech(self, text: str, language: str) -> bytes:
        """
        Convert text to speech for emergency alerts in regional languages.
        """
        pass
```

### 5.3 CERT-In Integration

```python
# government-integrations/cert-in/client.py

class CertInClient:
    """
    CERT-In - Indian Computer Emergency Response Team
    For threat intelligence sharing and incident reporting.
    """
    
    def report_incident(self, incident_data: dict):
        """Report cyber fraud incident to CERT-In"""
        pass
    
    def fetch_threat_intel(self, indicators: list) -> dict:
        """Fetch threat intelligence on IPs, domains, hashes"""
        pass
```

### 5.4 1930 Emergency Number Integration

```python
# government-integrations/emergency-1930/client.py

class Emergency1930Client:
    """
    National Cyber Crime Reporting Portal (1930)
    For real-time financial fraud reporting and account freezing.
    """
    
    def report_fraud(self, citizen_data: dict, transaction_data: dict) -> str:
        """
        Submit financial fraud report for immediate account freezing.
        Returns: 1930 complaint reference number.
        """
        pass
    
    def check_freeze_status(self, reference_id: str) -> dict:
        """Check if account freeze has been actioned"""
        pass
```

---

## PHASE 6: Evidence Vault (Week 8-10)

### 6.1 Cryptographic Evidence Package

Every piece of evidence must be court-admissible:

```javascript
// backend/services/evidence-service/evidence-chain.js

const crypto = require('crypto');

class EvidenceChain {
    constructor() {
        this.chain = [];
    }
    
    /**
     * Create a legally admissible evidence package
     * 
     * Package structure:
     * {
     *   case_id: "RAK-2024-001234",
     *   evidence_id: "EVID-2024-567890",
     *   timestamp: "2024-01-15T10:30:00+05:30",
     *   device_info: { imei, android_version, app_version },
     *   location: { lat, lng, accuracy },
     *   chain: [
     *     { hash: "abc...", prev_hash: null, data: "original_recording.wav", timestamp: "..." },
     *     { hash: "def...", prev_hash: "abc...", data: "transcript.json", timestamp: "..." },
     *     { hash: "ghi...", prev_hash: "def...", data: "ai_analysis.json", timestamp: "..." },
     *     { hash: "jkl...", prev_hash: "ghi...", data: "risk_score.json", timestamp: "..." },
     *     { hash: "mno...", prev_hash: "jkl...", data: "osint_report.json", timestamp: "..." }
     *   ],
     *   final_hash: "mno...",
     *   digital_signature: "base64_signed_hash",
     *   signer: "RAKSAAR_SYSTEM_v1.0"
     * }
     */
    
    addToChain(data) {
        const prevHash = this.chain.length > 0 
            ? this.chain[this.chain.length - 1].hash 
            : null;
        
        const entry = {
            hash: crypto.createHash('sha256')
                .update(JSON.stringify(data) + (prevHash || ''))
                .digest('hex'),
            prev_hash: prevHash,
            data: data,
            timestamp: new Date().toISOString()
        };
        
        this.chain.push(entry);
        return entry;
    }
    
    verifyIntegrity() {
        for (let i = 0; i < this.chain.length; i++) {
            const entry = this.chain[i];
            const expectedPrevHash = i > 0 ? this.chain[i-1].hash : null;
            
            if (entry.prev_hash !== expectedPrevHash) return false;
            
            const computedHash = crypto.createHash('sha256')
                .update(JSON.stringify(entry.data) + (entry.prev_hash || ''))
                .digest('hex');
            
            if (entry.hash !== computedHash) return false;
        }
        return true;
    }
}
```

---

## PHASE 7: Legal & Compliance Framework (Weeks 1-14, Ongoing)

### 7.1 Required Legal Documents

Create these documents in `docs/legal/`:

```
docs/legal/
├── DPDP_COMPLIANCE.md         # Digital Personal Data Protection Act 2023 compliance
├── IT_ACT_COMPLIANCE.md       # IT Act 2000 (Section 43A, 66, 69, 72A) compliance
├── TRAI_COMPLIANCE.md         # Telecom Regulatory Authority compliance
├── RBI_COMPLIANCE.md          # RBI digital payment guidelines
├── CERT_IN_COMPLIANCE.md      # CERT-In cybersecurity framework
├── PRIVACY_POLICY.md          # End-user privacy policy (multilingual)
├── TERMS_OF_SERVICE.md        # Terms of service for citizens
├── DATA_RETENTION_POLICY.md   # Data retention and deletion policy
├── CONSENT_FRAMEWORK.md       # Consent management framework (DPDP compliant)
└── EVIDENCE_ADMISSIBILITY.md  # Court-admissible evidence standards
```

### 7.2 Key Compliance Requirements

**Digital Personal Data Protection Act 2023 (DPDP)**:
- ✅ Purpose limitation → Each permission tied to specific feature
- ✅ Data minimization → Only collect what's necessary
- ✅ Consent management → Granular, revocable, recorded
- ✅ Rights of data principals → Access, correction, erasure
- ✅ Data breach notification → 72-hour reporting to DPBI
- ✅ Data localization → All data on Indian servers only (NIC cloud)
- ✅ Data protection impact assessment → Required for high-risk processing
- ✅ Consent manager → Appointed for managing user consent

**IT Act 2000**:
- ✅ Section 43A → Compensation for failure to protect data
- ✅ Section 66 → Computer-related offences
- ✅ Section 69 → Decryption of information (lawful interception)
- ✅ Section 72A → Disclosure of information in breach of contract
- ✅ Section 67C → Preservation and retention of information

---

## PHASE 8: Infrastructure & Deployment (Weeks 10-14)

### 8.1 NIC Cloud Migration

Current setup uses AWS. For government deployment, migrate to NIC Cloud:

```
Current: AWS → Target: NIC Cloud (National Informatics Centre)
- NIC MeghRaj cloud
- Government empanelled data centres
- MeitY approved
- SOC 2 / ISO 27001 certified
- Located in India (data localization compliant)
```

### 8.2 Production Architecture

```
                        ┌─────────────────────┐
                        │   CDN (NIC Cloud)    │
                        └──────────┬──────────┘
                                   │
                        ┌──────────▼──────────┐
                        │   Load Balancer      │
                        │   (NIC LB / Nginx)   │
                        └──────────┬──────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
     ┌────────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
     │  API Gateway    │  │  WebSocket     │  │  Static Files  │
     │  (Kong/Express) │  │  Server (WS)   │  │  (Next.js)     │
     └────────┬────────┘  └───────┬────────┘  └────────────────┘
              │                    │
     ┌────────┼────────────────────┼────────┐
     │        │     Service Mesh   │        │
     │  ┌─────▼─────┐   ┌─────▼─────┐      │
     │  │ Auth      │   │ AI Engine │      │
     │  │ Service   │   │ (Python)  │      │
     │  │ (FastAPI) │   │ Port 5002 │      │
     │  │ Port 5001 │   └─────┬─────┘      │
     │  └─────┬─────┘         │            │
     │        │               │            │
     │  ┌─────▼─────┐   ┌─────▼─────┐      │
     │  │ Citizen   │   │ Risk      │      │
     │  │ Service   │   │ Scoring   │      │
     │  └─────┬─────┘   └─────┬─────┘      │
     │        │               │            │
     │  ┌─────▼─────┐   ┌─────▼─────┐      │
     │  │ Police    │   │ Evidence  │      │
     │  │ Service   │   │ Vault     │      │
     │  └─────┬─────┘   └─────┬─────┘      │
     │        │               │            │
     │  ┌─────▼─────┐   ┌─────▼─────┐      │
     │  │ Notifica- │   │ Threat    │      │
     │  │ tion      │   │ Intel     │      │
     │  └─────┬─────┘   └─────┬─────┘      │
     │        │               │            │
     └────────┼───────────────┼────────────┘
              │               │
     ┌────────▼───────────────▼────────┐
     │         Message Queue (Kafka)    │
     │  - Call events, alerts, cases    │
     └────────────────┬─────────────────┘
                      │
     ┌────────────────┼─────────────────┐
     │                │                  │
┌────▼────┐   ┌──────▼──────┐   ┌──────▼──┐
│ MongoDB │   │ Redis       │   │ Neo4j   │
│ Atlas   │   │ (Cache)     │   │ (Graph) │
└─────────┘   └─────────────┘   └─────────┘
```

### 8.3 Kubernetes Configuration

Update existing `infrastructure/kubernetes/` with:

- Separate namespaces: `raksaar-auth`, `raksaar-ai`, `raksaar-citizen`, `raksaar-police`
- Horizontal Pod Autoscaling for AI inference (most compute-intensive)
- Pod anti-affinity to distribute across nodes
- Resource limits for AI services (GPU nodes if available)
- Network policies for zero-trust between services
- Persistent volume claims for evidence storage
- ConfigMaps and Secrets for environment configuration

---

## PHASE 9: Real-time Event Streaming (Week 9-12)

### 9.1 Kafka Event Architecture

The current `kafka_stub.py` needs to be replaced with a full Kafka implementation:

```python
# Event types flowing through Kafka:

# Citizen → System
citizen_call_started       # { citizen_id, caller_number, timestamp }
citizen_call_analysis      # { citizen_id, transcript_chunk, risk_score }
citizen_sms_received       # { citizen_id, sender, text, contains_url }
citizen_report_fraud       # { citizen_id, case_data, evidence_hash }
citizen_sos_triggered      # { citizen_id, location, emergency_type }

# System → Citizen
scam_alert                  # { citizen_id, risk_level, scam_type, recommendation }
evidence_package_ready      # { citizen_id, case_id, download_url }
police_case_update          # { citizen_id, case_id, new_status, assigned_officer }

# System → Police
new_case_auto_generated     # { case_id, risk_score, citizen_info, evidence_summary }
high_priority_alert         # { case_id, scam_type, financial_loss_estimated }
scam_network_detected       # { case_id, linked_numbers, cluster_id }

# System → Government
national_threat_update      # { threat_type, affected_states, estimated_impact }
fraud_heatmap_update        # { district, new_cases, scam_types_breakdown }

# AI → System
call_risk_assessment        # { call_id, risk_score, scam_type, confidence }
sms_analysis_result         # { sms_id, is_scam, scam_type, linked_campaign }
upi_fraud_detected          # { transaction_id, risk_level, merchant_flags }
deepfake_detected           # { call_id, confidence, detection_method }
```

---

## PHASE 10: Advanced Features (Weeks 12-16)

### 10.1 Scammer Network Graph

Use Neo4j (already configured) for link analysis:

```cypher
// Neo4j query to detect scam networks
MATCH (caller:PhoneNumber)-[r:CALLED]->(victim:Citizen)
WHERE caller.fraud_reports > 5
OPTIONAL MATCH (caller)-[:LINKED_TO]->(upi:UPI_ID)
OPTIONAL MATCH (caller)-[:REGISTERED_AT]->(ip:IPAddress)
OPTIONAL MATCH (caller)-[:SAME_DEVICE]->(otherNumber:PhoneNumber)
RETURN caller, count(victim) as victims, collect(upi), collect(ip), collect(otherNumber)
ORDER BY victims DESC
LIMIT 100
```

### 10.2 Fraud Prediction Engine

```python
# ai/fraud-pattern-engine/predictor.py

"""
Predictive scam prevention using:
1. Time-series analysis of fraud reports by district
2. Seasonal pattern detection (festive season spikes, tax season)
3. Social media sentiment correlation (scam campaigns announced on Telegram)
4. Telecom traffic anomaly detection (sudden spike in calls from new numbers)
5. Weather/event correlation (natural disasters → relief scam spikes)

Output: Daily fraud risk forecast by district and scam type
"""
```

### 10.3 Dark Web Monitoring Module

```python
# ai/dark-web-monitor/scanner.py

"""
Monitor Telegram channels, dark web forums for:
- Stolen Aadhaar/PAN data being sold
- Scam scripts being shared
- Fake customer care numbers being advertised
- Phishing kits targeting Indian banks
- RAT (Remote Access Trojan) APKs being distributed

Alerts when citizen data found in leaked databases.
"""
```

### 10.4 Crypto Fraud Intelligence

Add detection for:
- Fake crypto investment apps (GainBitcoin, etc.)
- Pump-and-dump schemes advertised on WhatsApp/Telegram
- Crypto-to-UPI conversion tracing
- Fake mining pool scams

---

## TEAM WORK ALLOCATION (4 Members)

| Member | Primary Focus | Secondary Focus | Week 1-4 | Week 5-8 | Week 9-12 | Week 13-16 |
|--------|--------------|----------------|----------|----------|-----------|------------|
| **A** | Backend + API Gateway | Auth system | Fix port conflicts, implement citizen/police routes | Build evidence vault, implement all missing API routes | Kafka event system, WebSocket server | Performance testing, security audit |
| **B** | AI Engine + ML Models | Risk scoring | Train scam classification model, set up Whisper STT | Build deepfake detector, multilingual keyword engine | AI investigator, fraud prediction model | Model optimization, accuracy testing |
| **C** | Flutter App | UI/UX | Build auth flow, onboarding, home dashboard | Build call protection, SMS/WhatsApp protection | Emergency features, family dashboard, training module | Polish, testing, app store submission |
| **D** | Police Portal + Gov Integration | Legal compliance | Set up Next.js, build case dashboard, evidence viewer | Build OSINT module, network graphs, FIR generator | Integrate Sanchar Saathi, Bhashini, CERT-In | Write legal docs, compliance framework, pilot preparation |

---

## SUCCESS METRICS CHECKLIST

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Scam Detection Accuracy | ~60% (keyword-only) | 95% | Test against 10,000 recorded scam calls |
| Detection Time | N/A (not real-time) | < 2 seconds | End-to-end latency measurement |
| False Positive Rate | High (keyword match only) | < 5% | Precision/recall on labeled dataset |
| Language Support | English only | 13 languages | Integration tests per language |
| App Permissions | Not implemented | Granular consent | User consent audit |
| Evidence Admissibility | None | Court-certified | Legal review of evidence chain |
| Government Integration | None | 4/4 systems (Sanchar, Bhashini, CERT-In, 1930) | API connection tests |
| Real-time Sync | None | Sub-second | WebSocket latency < 500ms |
| User Onboarding | None | < 3 minutes | UX testing |
| Police Case Processing | Manual | Auto-FIR < 5 minutes | Auto-generated report to police |

---

## IMMEDIATE ACTION ITEMS (Next 7 Days)

1. **Fix port conflict** → Move auth-service to port 5001, update Express app.js
2. **Train basic scam classifier** → Use existing risk-scoring engine data + NCRB public dataset
3. **Build Bhashini STT integration** → Even a prototype with API key
4. **Create 3-minute demo video** → Record scam call → detection → evidence → police report
5. **Contact Gurugram Cyber Police** → Get letter of support for pilot
6. **Start DPDP compliance document** → Template for consent, data minimization
7. **Assign team members** → Use the allocation table above

---

## BLOCKERS & RISKS

| Risk | Impact | Mitigation |
|------|--------|------------|
| No real-world scam call dataset | Cannot train accurate ML | Use synthetic data + NCRB reports + partner with CyberPeace Foundation |
| Android call recording restrictions | Core feature blocked | On-device processing only, use Accessibility Service as fallback |
| Government API access pending | Can't demo live integration | Build mock APIs that simulate Sanchar Saathi/Bhashini |
| Privacy/legal concerns raised | Project rejected by govt | Engage cyber law firm from Day 1, document DPDP compliance |
| Telecom operator cooperation | SIM blocking not possible | Start with TRAI/Sanchar Saathi, build case for MOU later |
| 4-person team bandwidth | Slow progress | Focus on P0 features only, outsource non-core work |

---

## CONCLUSION

The project has a **solid foundation** — working backend, auth system, risk-scoring engine, and proper database architecture. The critical gaps are:

1. **No working AI model** (everything depends on this)
2. **No runnable Flutter app** (citizen-facing is the whole point)
3. **No government integration** (required for credibility)
4. **No legal compliance framework** (required for government adoption)
5. **No real-time infrastructure** (required for live detection)

**Priority**: AI model → Flutter app → Legal compliance → Government integration

The project CAN be production-ready in 16 weeks with focused effort from a 4-person team, provided you:
1. **Don't build everything** — use Bhashini (free government API) instead of building custom STT
2. **Don't aim for perfection** — get the simplest working demo to Gurugram police first
3. **Do get legal right** — document DPDP compliance before writing more code
4. **Do partner with NIC** — hosting on NIC cloud is a non-negotiable for government
5. **Do focus on the pilot district** — Gurugram first, India later

---

*Document prepared for CyberShield AI (Raksaar) team review. Last updated: June 2024.*