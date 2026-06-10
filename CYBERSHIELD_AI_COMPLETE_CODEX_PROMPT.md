# CYBERSHIELD AI — COMPLETE PRODUCTION CODEX PROMPT
### From Scratch to National Government Deployment
### Gurugram Cyber Police | Version 3.0 FINAL

---

> **HOW TO USE THIS PROMPT:**
> Paste each section into Claude Codex / GitHub Copilot Workspace / Cursor AI one section at a time.
> Start with MASTER SETUP, then follow the numbered sections in order.
> Each section builds on the previous one. Do not skip sections.

---

## ══════════════════════════════════════════
## MASTER SYSTEM PROMPT (Paste this FIRST in every new Codex session)
## ══════════════════════════════════════════

```
You are a senior full-stack engineer building CYBERSHIELD AI — a production-grade, 
government-level AI-powered scam call detection and prevention system for India, 
commissioned by Gurugram Cyber Police.

PROJECT FOLDER: CYBERSHIELD-AI/
TARGET: National deployment across India protecting all citizens

THE SYSTEM HAS THREE PORTALS:
1. CITIZEN ANDROID APP — Real-time scam detection for every Indian citizen
2. POLICE ADMIN PORTAL — Web dashboard for Cyber Police investigation & monitoring  
3. ISP/TELECOM PORTAL — Network-level threat intelligence for telecom operators

CORE PRINCIPLES:
- All code must be production-ready, not demo-quality
- Security-first: end-to-end encryption, no data leakage
- Privacy-first: recordings stored only on user device, processed locally by AI
- India-first: Hindi + 22 Indian languages supported, Indian number formats
- Government-grade: integrates with Sanchar Saathi, TRAI, CERT-In APIs
- Scalability: must handle 500M+ users across India

TECH STACK (DO NOT CHANGE):
- Android App: Kotlin + Jetpack Compose + MVVM + Hilt DI
- Backend: Python FastAPI (microservices) + Node.js (real-time WebSocket)
- AI/ML: PyTorch + Transformers (DistilBERT) + XGBoost + SpeechBrain + Whisper
- Database: PostgreSQL (primary) + Redis (cache) + MongoDB (evidence/logs)
- Real-time: Apache Kafka (event streaming) + Socket.io
- Infrastructure: Docker + Kubernetes + AWS/GCP India region
- Police Dashboard: Next.js 14 + TypeScript + Tailwind CSS + shadcn/ui
- ISP Portal: Next.js 14 + TypeScript + Tailwind CSS
- Maps: Google Maps API (India heatmap)
- Auth: Firebase Auth (citizens) + JWT + OAuth2 (police/ISP)

DESIGN SYSTEM:
- Dark theme: background #0A0E1A, cards #0F1629, accent #1E3A5F
- Danger: #FF3B30, Warning: #FF9500, Safe: #34C759, Info: #007AFF
- Font: Inter for web, system font for Android
- All dashboards must match the provided mockup screenshots exactly

When I say "BUILD SECTION X", generate complete, runnable code for that section.
Always include: error handling, loading states, TypeScript types, comments.
Never use placeholder/TODO code — write the actual implementation.
```

---

## ══════════════════════════════════════════
## SECTION 1 — PROJECT STRUCTURE & INITIAL SETUP
## ══════════════════════════════════════════

```
BUILD SECTION 1: Complete project folder structure and initial configuration.

Create the following COMPLETE folder structure for CYBERSHIELD-AI/:

CYBERSHIELD-AI/
├── android-app/                    # Citizen Android Application
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── java/com/cybershield/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── CyberShieldApp.kt
│   │   │   │   ├── di/              # Hilt Dependency Injection modules
│   │   │   │   │   ├── AppModule.kt
│   │   │   │   │   ├── NetworkModule.kt
│   │   │   │   │   ├── DatabaseModule.kt
│   │   │   │   │   └── AIModule.kt
│   │   │   │   ├── data/
│   │   │   │   │   ├── local/       # Room DB
│   │   │   │   │   │   ├── CyberShieldDatabase.kt
│   │   │   │   │   │   ├── dao/
│   │   │   │   │   │   └── entities/
│   │   │   │   │   ├── remote/      # API clients
│   │   │   │   │   │   ├── ApiService.kt
│   │   │   │   │   │   └── models/
│   │   │   │   │   └── repository/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── models/
│   │   │   │   │   ├── usecases/
│   │   │   │   │   └── repository/  # interfaces
│   │   │   │   ├── presentation/
│   │   │   │   │   ├── screens/
│   │   │   │   │   │   ├── splash/
│   │   │   │   │   │   ├── onboarding/
│   │   │   │   │   │   ├── home/
│   │   │   │   │   │   ├── incoming_call/
│   │   │   │   │   │   ├── call_analysis/
│   │   │   │   │   │   ├── risk_detection/
│   │   │   │   │   │   ├── call_in_progress/
│   │   │   │   │   │   ├── call_summary/
│   │   │   │   │   │   ├── call_details/
│   │   │   │   │   │   ├── sms_protection/
│   │   │   │   │   │   ├── whatsapp_protection/
│   │   │   │   │   │   ├── history/
│   │   │   │   │   │   ├── report_fraud/
│   │   │   │   │   │   ├── blocked_numbers/
│   │   │   │   │   │   ├── settings/
│   │   │   │   │   │   ├── upi_protection/
│   │   │   │   │   │   ├── screen_share_detection/
│   │   │   │   │   │   ├── remote_access_detection/
│   │   │   │   │   │   ├── fake_apk_detection/
│   │   │   │   │   │   ├── scam_link_scanner/
│   │   │   │   │   │   ├── fraud_heatmap/
│   │   │   │   │   │   ├── family_protection/
│   │   │   │   │   │   ├── scam_simulation/
│   │   │   │   │   │   ├── cyber_emergency/
│   │   │   │   │   │   └── premium/
│   │   │   │   │   ├── components/  # reusable Compose components
│   │   │   │   │   ├── theme/
│   │   │   │   │   └── navigation/
│   │   │   │   ├── services/
│   │   │   │   │   ├── CallMonitorService.kt
│   │   │   │   │   ├── SmsMonitorService.kt
│   │   │   │   │   ├── WhatsAppMonitorService.kt
│   │   │   │   │   ├── UpiMonitorService.kt
│   │   │   │   │   ├── ScreenShareDetectionService.kt
│   │   │   │   │   └── BackgroundProtectionService.kt
│   │   │   │   ├── ml/
│   │   │   │   │   ├── ScamDetectionModel.kt
│   │   │   │   │   ├── SpeechToTextEngine.kt
│   │   │   │   │   ├── IntentClassifier.kt
│   │   │   │   │   ├── KeywordDetector.kt
│   │   │   │   │   └── RiskScoreCalculator.kt
│   │   │   │   └── utils/
│   │   │   └── res/
│   │   │       ├── layout/
│   │   │       ├── drawable/
│   │   │       ├── values/
│   │   │       └── raw/             # TFLite model files
│   │   ├── build.gradle.kts
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
│
├── backend/
│   ├── services/
│   │   ├── api-gateway/             # Main API Gateway (FastAPI)
│   │   │   ├── main.py
│   │   │   ├── routers/
│   │   │   ├── middleware/
│   │   │   └── Dockerfile
│   │   ├── auth-service/            # Authentication & JWT
│   │   │   ├── main.py
│   │   │   ├── models.py
│   │   │   ├── routes.py
│   │   │   └── Dockerfile
│   │   ├── call-analysis-service/   # Core call analysis AI
│   │   │   ├── main.py
│   │   │   ├── analyzer.py
│   │   │   ├── speech_processor.py
│   │   │   ├── risk_scorer.py
│   │   │   └── Dockerfile
│   │   ├── sms-analysis-service/    # SMS/WhatsApp analysis
│   │   │   ├── main.py
│   │   │   ├── sms_analyzer.py
│   │   │   ├── link_scanner.py
│   │   │   └── Dockerfile
│   │   ├── number-intelligence-service/  # Phone number lookup
│   │   │   ├── main.py
│   │   │   ├── number_lookup.py
│   │   │   ├── trai_integration.py
│   │   │   ├── bank_registry.py
│   │   │   └── Dockerfile
│   │   ├── evidence-service/        # Evidence storage & management
│   │   │   ├── main.py
│   │   │   ├── evidence_manager.py
│   │   │   ├── encryption.py
│   │   │   └── Dockerfile
│   │   ├── reporting-service/       # FIR generation & Sanchar Saathi
│   │   │   ├── main.py
│   │   │   ├── fir_generator.py
│   │   │   ├── sanchar_saathi.py
│   │   │   ├── police_notifier.py
│   │   │   └── Dockerfile
│   │   ├── notification-service/    # Real-time alerts
│   │   │   ├── main.py
│   │   │   ├── push_notifications.py
│   │   │   ├── websocket_handler.py
│   │   │   └── Dockerfile
│   │   ├── isp-service/             # ISP/Telecom integration
│   │   │   ├── main.py
│   │   │   ├── telecom_api.py
│   │   │   ├── number_blocking.py
│   │   │   ├── traffic_analyzer.py
│   │   │   └── Dockerfile
│   │   ├── intelligence-service/    # Threat intelligence aggregation
│   │   │   ├── main.py
│   │   │   ├── pattern_analyzer.py
│   │   │   ├── campaign_detector.py
│   │   │   ├── heatmap_generator.py
│   │   │   └── Dockerfile
│   │   └── upi-monitor-service/     # UPI fraud detection
│   │       ├── main.py
│   │       ├── upi_analyzer.py
│   │       └── Dockerfile
│   ├── shared/
│   │   ├── database/
│   │   │   ├── postgres_client.py
│   │   │   ├── redis_client.py
│   │   │   ├── mongodb_client.py
│   │   │   └── migrations/
│   │   ├── models/
│   │   │   ├── call_models.py
│   │   │   ├── user_models.py
│   │   │   ├── report_models.py
│   │   │   └── intelligence_models.py
│   │   ├── security/
│   │   │   ├── encryption.py
│   │   │   ├── auth_middleware.py
│   │   │   └── rate_limiter.py
│   │   └── kafka/
│   │       ├── producer.py
│   │       └── consumer.py
│   ├── ai-engine/
│   │   ├── models/
│   │   │   ├── scam_classifier/
│   │   │   │   ├── train.py
│   │   │   │   ├── model.py
│   │   │   │   ├── dataset.py
│   │   │   │   └── evaluate.py
│   │   │   ├── speech_to_text/
│   │   │   │   ├── whisper_processor.py
│   │   │   │   ├── indic_language_model.py
│   │   │   │   └── real_time_transcriber.py
│   │   │   ├── intent_detector/
│   │   │   │   ├── intent_model.py
│   │   │   │   ├── keyword_extractor.py
│   │   │   │   └── urgency_detector.py
│   │   │   ├── number_analyzer/
│   │   │   │   ├── number_features.py
│   │   │   │   └── xgboost_classifier.py
│   │   │   └── upi_fraud_detector/
│   │   │       ├── transaction_analyzer.py
│   │   │       └── anomaly_detector.py
│   │   ├── data/
│   │   │   ├── scam_patterns/
│   │   │   ├── bank_numbers/
│   │   │   ├── official_numbers/
│   │   │   └── training_datasets/
│   │   └── serving/
│   │       ├── model_server.py
│   │       └── inference_api.py
│   └── docker-compose.yml
│
├── police-dashboard/                # Next.js Police Admin Portal
│   ├── src/
│   │   ├── app/
│   │   │   ├── (auth)/
│   │   │   │   ├── login/
│   │   │   │   └── layout.tsx
│   │   │   └── (dashboard)/
│   │   │       ├── layout.tsx
│   │   │       ├── page.tsx          # Dashboard Overview
│   │   │       ├── live-monitoring/
│   │   │       ├── threat-intelligence/
│   │   │       ├── fraud-heatmap/
│   │   │       ├── scam-reports/
│   │   │       ├── blocked-numbers/
│   │   │       ├── fraud-campaigns/
│   │   │       ├── digital-trust-score/
│   │   │       ├── upi-fraud/
│   │   │       ├── bank-verification/
│   │   │       ├── deepfake-detection/
│   │   │       ├── case-management/
│   │   │       ├── complaints/
│   │   │       ├── evidence-vault/
│   │   │       ├── analytics/
│   │   │       ├── users-roles/
│   │   │       ├── audit-logs/
│   │   │       └── system-settings/
│   │   ├── components/
│   │   │   ├── dashboard/
│   │   │   ├── charts/
│   │   │   ├── maps/
│   │   │   ├── tables/
│   │   │   ├── live-feed/
│   │   │   └── ui/
│   │   ├── lib/
│   │   │   ├── api.ts
│   │   │   ├── websocket.ts
│   │   │   ├── auth.ts
│   │   │   └── utils.ts
│   │   ├── types/
│   │   └── hooks/
│   ├── package.json
│   └── next.config.js
│
├── isp-portal/                      # Next.js ISP/Telecom Portal
│   ├── src/
│   │   ├── app/
│   │   │   └── (dashboard)/
│   │   │       ├── page.tsx          # Dashboard Overview
│   │   │       ├── real-time-monitor/
│   │   │       ├── number-intelligence/
│   │   │       ├── traffic-analytics/
│   │   │       ├── threat-detection/
│   │   │       ├── blocked-numbers/
│   │   │       ├── customer-reports/
│   │   │       ├── api-integrations/
│   │   │       ├── compliance-logs/
│   │   │       ├── alerts/
│   │   │       ├── settings/
│   │   │       └── support/
│   │   ├── components/
│   │   ├── lib/
│   │   └── types/
│   └── package.json
│
├── shared/
│   ├── api-contracts/               # OpenAPI specs for all services
│   ├── proto/                       # gRPC proto files
│   └── types/                       # Shared TypeScript types
│
├── infrastructure/
│   ├── kubernetes/
│   │   ├── deployments/
│   │   ├── services/
│   │   ├── ingress/
│   │   └── configmaps/
│   ├── terraform/
│   │   ├── aws/
│   │   └── gcp/
│   ├── nginx/
│   │   └── nginx.conf
│   └── monitoring/
│       ├── prometheus/
│       └── grafana/
│
├── scripts/
│   ├── setup.sh
│   ├── deploy.sh
│   ├── seed_database.py
│   └── train_models.sh
│
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   └── SECURITY.md
│
├── .env.example
├── .env.production
├── docker-compose.yml
├── docker-compose.prod.yml
└── README.md

Generate the complete docker-compose.yml that starts ALL services:
- PostgreSQL 16 with Indian timezone
- Redis 7 with persistence
- MongoDB 7 for evidence storage
- Apache Kafka + Zookeeper for event streaming
- All 10 backend microservices
- AI model serving container
- Nginx reverse proxy
- Prometheus + Grafana monitoring

Also generate:
1. Complete .env.example with all required environment variables
2. scripts/setup.sh that initializes everything with one command
3. README.md with complete setup instructions in English and Hindi
```

---

## ══════════════════════════════════════════
## SECTION 2 — DATABASE SCHEMA (Complete)
## ══════════════════════════════════════════

```
BUILD SECTION 2: Complete PostgreSQL database schema for CyberShield AI.

Create backend/shared/database/migrations/001_initial_schema.sql with ALL tables:

-- ═══════════════════════════════
-- USER & AUTHENTICATION TABLES
-- ═══════════════════════════════

CREATE TABLE citizens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    name VARCHAR(100),
    firebase_uid VARCHAR(255) UNIQUE,
    device_id VARCHAR(255),
    device_model VARCHAR(100),
    android_version VARCHAR(20),
    app_version VARCHAR(20),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    state VARCHAR(50),
    city VARCHAR(100),
    district VARCHAR(100),
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMP,
    total_calls_scanned INTEGER DEFAULT 0,
    total_threats_blocked INTEGER DEFAULT 0,
    family_group_id UUID,
    language_preference VARCHAR(10) DEFAULT 'hi',
    notification_enabled BOOLEAN DEFAULT TRUE,
    auto_block_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_active_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE police_officers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    rank VARCHAR(50),
    department VARCHAR(100) DEFAULT 'Cyber Cell',
    station VARCHAR(100),
    state VARCHAR(50),
    city VARCHAR(100),
    role VARCHAR(30) DEFAULT 'investigator', -- super_admin, admin, investigator, analyst, operator
    password_hash VARCHAR(255) NOT NULL,
    last_login TIMESTAMP,
    two_factor_enabled BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE isp_operators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(100) NOT NULL,
    operator_code VARCHAR(20) UNIQUE,
    contact_name VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    role VARCHAR(30) DEFAULT 'analyst', -- admin, analyst, operator
    license_number VARCHAR(100),
    circles TEXT[], -- ['Haryana', 'Delhi', 'UP']
    password_hash VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) UNIQUE,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ═══════════════════════════════
-- PHONE NUMBER INTELLIGENCE
-- ═══════════════════════════════

CREATE TABLE phone_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    operator VARCHAR(50),           -- Jio, Airtel, Vi, BSNL
    circle VARCHAR(50),             -- Telecom circle
    number_type VARCHAR(30),        -- mobile, landline, voip, international
    registered_name VARCHAR(200),
    is_official BOOLEAN DEFAULT FALSE,
    official_org VARCHAR(100),
    is_verified_bank BOOLEAN DEFAULT FALSE,
    bank_name VARCHAR(100),
    risk_score INTEGER DEFAULT 0,   -- 0-100
    risk_level VARCHAR(20) DEFAULT 'unknown', -- safe, low, medium, high, blocked
    total_reports INTEGER DEFAULT 0,
    total_calls_analyzed INTEGER DEFAULT 0,
    first_reported_at TIMESTAMP,
    last_activity_at TIMESTAMP,
    is_blocked BOOLEAN DEFAULT FALSE,
    blocked_at TIMESTAMP,
    blocked_by VARCHAR(30),         -- system, police, isp, government
    block_reason TEXT,
    blacklist_source VARCHAR(50),
    trai_registered BOOLEAN,
    location_state VARCHAR(50),
    location_city VARCHAR(100),
    sim_change_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE official_numbers_registry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_type VARCHAR(50),  -- bank, government, insurance, telecom
    organization_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    number_purpose VARCHAR(100),    -- customer_care, fraud_reporting, verification
    is_active BOOLEAN DEFAULT TRUE,
    verified_by VARCHAR(50),
    source_url VARCHAR(500),
    added_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_name, phone_number)
);

-- ═══════════════════════════════
-- CALL ANALYSIS TABLES
-- ═══════════════════════════════

CREATE TABLE call_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    citizen_id UUID REFERENCES citizens(id),
    phone_number VARCHAR(15) NOT NULL,
    call_direction VARCHAR(10) DEFAULT 'incoming', -- incoming, outgoing
    call_start_time TIMESTAMP NOT NULL,
    call_end_time TIMESTAMP,
    call_duration_seconds INTEGER DEFAULT 0,
    
    -- Risk Assessment
    risk_score INTEGER DEFAULT 0,
    risk_level VARCHAR(20) DEFAULT 'analyzing',
    confidence_percentage DECIMAL(5,2),
    
    -- Detection Results
    detected_scam_type VARCHAR(50),   -- otp_fraud, bank_fraud, kyc_scam, etc.
    detected_keywords TEXT[],
    detected_language VARCHAR(30),
    urgency_detected BOOLEAN DEFAULT FALSE,
    impersonation_detected BOOLEAN DEFAULT FALSE,
    
    -- AI Analysis
    transcript TEXT,
    intent_classification VARCHAR(50),
    sentiment_score DECIMAL(5,2),
    speech_pattern_anomaly BOOLEAN DEFAULT FALSE,
    
    -- Number Verification
    number_in_official_db BOOLEAN DEFAULT FALSE,
    number_verified_org VARCHAR(100),
    number_operator VARCHAR(50),
    number_circle VARCHAR(50),
    
    -- Actions Taken
    action_taken VARCHAR(50),         -- monitored, warned, call_cut, blocked
    auto_blocked BOOLEAN DEFAULT FALSE,
    user_blocked BOOLEAN DEFAULT FALSE,
    
    -- Evidence
    recording_file_path TEXT,        -- encrypted, stored on device
    recording_duration INTEGER,
    evidence_exported BOOLEAN DEFAULT FALSE,
    
    -- Reporting
    auto_reported BOOLEAN DEFAULT FALSE,
    reported_to_police BOOLEAN DEFAULT FALSE,
    reported_to_sanchar_saathi BOOLEAN DEFAULT FALSE,
    case_id UUID,
    
    -- Location
    citizen_state VARCHAR(50),
    citizen_city VARCHAR(100),
    citizen_lat DECIMAL(10,8),
    citizen_lng DECIMAL(11,8),
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sms_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    citizen_id UUID REFERENCES citizens(id),
    sender_number VARCHAR(15),
    sender_id VARCHAR(20),           -- HDFCBK, VK-BANKAL type IDs
    message_text TEXT,
    message_hash VARCHAR(64),        -- for deduplication
    received_at TIMESTAMP,
    
    -- Analysis
    risk_score INTEGER DEFAULT 0,
    risk_level VARCHAR(20),
    scam_type VARCHAR(50),
    detected_keywords TEXT[],
    suspicious_links TEXT[],
    link_scan_results JSONB,
    
    -- Classification
    is_spam BOOLEAN DEFAULT FALSE,
    is_scam BOOLEAN DEFAULT FALSE,
    is_phishing BOOLEAN DEFAULT FALSE,
    confidence DECIMAL(5,2),
    
    -- Actions
    auto_moved_to_spam BOOLEAN DEFAULT FALSE,
    user_reported BOOLEAN DEFAULT FALSE,
    deleted_by_user BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE whatsapp_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    citizen_id UUID REFERENCES citizens(id),
    contact_name VARCHAR(100),
    contact_number VARCHAR(15),
    is_group BOOLEAN DEFAULT FALSE,
    group_name VARCHAR(100),
    message_type VARCHAR(20),        -- text, call, image, link
    
    -- For calls
    call_duration INTEGER,
    call_risk_score INTEGER,
    
    -- For messages
    message_preview TEXT,
    risk_score INTEGER DEFAULT 0,
    risk_level VARCHAR(20),
    scam_type VARCHAR(50),
    
    -- Analysis
    detected_keywords TEXT[],
    suspicious_links TEXT[],
    
    analyzed_at TIMESTAMP DEFAULT NOW()
);

-- ═══════════════════════════════
-- FRAUD REPORTS & CASES
-- ═══════════════════════════════

CREATE TABLE fraud_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id VARCHAR(30) UNIQUE,   -- CSAI2025051800001 format
    citizen_id UUID REFERENCES citizens(id),
    
    -- Report Details
    fraud_type VARCHAR(50) NOT NULL,  -- call_fraud, sms_fraud, whatsapp_fraud, upi_fraud
    scam_category VARCHAR(50),        -- bank_fraud, otp_fraud, kyc_scam, loan_fraud etc.
    reported_number VARCHAR(15),
    description TEXT,
    financial_loss DECIMAL(12,2),
    
    -- Evidence Links
    call_analysis_id UUID REFERENCES call_analyses(id),
    sms_analysis_id UUID REFERENCES sms_analyses(id),
    screenshot_paths TEXT[],
    
    -- Status
    status VARCHAR(30) DEFAULT 'pending',  -- pending, under_review, confirmed, resolved, rejected
    priority VARCHAR(20) DEFAULT 'medium',
    
    -- Police Assignment
    assigned_officer_id UUID REFERENCES police_officers(id),
    case_id UUID,
    fir_number VARCHAR(50),
    
    -- External Reporting
    sanchar_saathi_ticket_id VARCHAR(100),
    reported_to_sanchar_saathi_at TIMESTAMP,
    cybercrime_portal_ref VARCHAR(100),
    
    -- Location
    citizen_state VARCHAR(50),
    citizen_city VARCHAR(100),
    
    reported_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(30) UNIQUE,      -- CS2025018-001 format
    title VARCHAR(200) NOT NULL,
    case_type VARCHAR(50),
    
    -- FIR Details
    fir_number VARCHAR(50),
    fir_registered_at TIMESTAMP,
    court_case_number VARCHAR(50),
    
    -- Status
    status VARCHAR(30) DEFAULT 'open',  -- open, under_investigation, closed, court
    priority VARCHAR(20) DEFAULT 'medium',
    
    -- Assignment
    investigating_officer_id UUID REFERENCES police_officers(id),
    station VARCHAR(100),
    state VARCHAR(50),
    
    -- Suspect Information
    suspect_numbers TEXT[],
    suspect_names TEXT[],
    suspect_locations TEXT[],
    
    -- Financial
    total_financial_loss DECIMAL(15,2),
    victims_count INTEGER DEFAULT 0,
    
    -- Evidence
    evidence_count INTEGER DEFAULT 0,
    
    description TEXT,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    closed_at TIMESTAMP
);

CREATE TABLE evidence_vault (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    evidence_id VARCHAR(30) UNIQUE,
    case_id UUID REFERENCES cases(id),
    report_id UUID REFERENCES fraud_reports(id),
    
    -- File Details
    file_name VARCHAR(255),
    file_type VARCHAR(30),           -- call_recording, sms, whatsapp_chat, screenshot, document, apk
    file_size_bytes BIGINT,
    file_hash_sha256 VARCHAR(64),    -- integrity verification
    
    -- Storage
    storage_path TEXT,
    is_encrypted BOOLEAN DEFAULT TRUE,
    encryption_key_id VARCHAR(100),
    
    -- Metadata
    related_phone_number VARCHAR(15),
    duration_seconds INTEGER,        -- for recordings
    
    -- Chain of Custody
    uploaded_by_type VARCHAR(20),    -- citizen, officer, system
    uploaded_by_id UUID,
    uploaded_at TIMESTAMP DEFAULT NOW(),
    accessed_by JSONB DEFAULT '[]',  -- array of {officer_id, accessed_at}
    
    is_admissible BOOLEAN DEFAULT FALSE,
    verified_by_officer_id UUID,
    verified_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- ═══════════════════════════════
-- BLOCKED NUMBERS
-- ═══════════════════════════════

CREATE TABLE blocked_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) NOT NULL,
    
    blocked_by_type VARCHAR(20) NOT NULL,  -- system, citizen, police, isp, government
    blocked_by_citizen_id UUID REFERENCES citizens(id),
    blocked_by_officer_id UUID REFERENCES police_officers(id),
    blocked_by_isp_id UUID REFERENCES isp_operators(id),
    
    reason TEXT NOT NULL,
    scam_type VARCHAR(50),
    risk_score INTEGER,
    report_count INTEGER DEFAULT 0,
    
    -- ISP Level blocking
    isp_block_requested BOOLEAN DEFAULT FALSE,
    isp_block_confirmed BOOLEAN DEFAULT FALSE,
    isp_blocked_at TIMESTAMP,
    isp_operator VARCHAR(50),
    
    -- Government Level
    trai_deactivated BOOLEAN DEFAULT FALSE,
    trai_deactivated_at TIMESTAMP,
    
    is_active BOOLEAN DEFAULT TRUE,
    blocked_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    unblocked_at TIMESTAMP,
    unblock_reason TEXT,
    
    UNIQUE(phone_number, blocked_by_type)
);

-- ═══════════════════════════════
-- THREAT INTELLIGENCE
-- ═══════════════════════════════

CREATE TABLE scam_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_name VARCHAR(200),
    campaign_type VARCHAR(50),       -- otp_fraud, kyc_scam, bank_fraud, loan_fraud, investment_fraud
    
    -- Detection
    detected_at TIMESTAMP DEFAULT NOW(),
    first_seen_at TIMESTAMP,
    last_seen_at TIMESTAMP,
    
    -- Scale
    affected_numbers TEXT[],
    victim_count INTEGER DEFAULT 0,
    affected_states TEXT[],
    
    -- Patterns
    trigger_keywords TEXT[],
    message_templates TEXT[],
    attack_vectors TEXT[],           -- call, sms, whatsapp, email
    
    -- Risk
    risk_score INTEGER DEFAULT 0,
    severity VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Investigation
    campaign_id VARCHAR(30) UNIQUE,
    assigned_case_id UUID REFERENCES cases(id),
    
    financial_loss_estimate DECIMAL(15,2),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE digital_trust_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    
    overall_score INTEGER DEFAULT 50,   -- 0-100 (lower = more trusted, higher = more suspicious)
    
    -- Score Breakdown
    user_reports_score INTEGER DEFAULT 0,     -- out of 25
    ai_analysis_score INTEGER DEFAULT 0,      -- out of 25
    fraud_history_score INTEGER DEFAULT 0,    -- out of 25
    bank_verification_score INTEGER DEFAULT 0, -- out of 15
    network_reputation_score INTEGER DEFAULT 0, -- out of 10
    
    -- History
    times_reported INTEGER DEFAULT 0,
    times_flagged_by_ai INTEGER DEFAULT 0,
    linked_to_campaigns INTEGER DEFAULT 0,
    linked_to_cases INTEGER DEFAULT 0,
    
    last_calculated_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ═══════════════════════════════
-- UPI FRAUD TABLES
-- ═══════════════════════════════

CREATE TABLE upi_fraud_detections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    citizen_id UUID REFERENCES citizens(id),
    upi_id VARCHAR(100),
    merchant_name VARCHAR(200),
    amount DECIMAL(12,2),
    
    risk_score INTEGER DEFAULT 0,
    risk_level VARCHAR(20),
    fraud_indicators JSONB,          -- {new_payee: true, unusual_amount: true, ...}
    
    action_taken VARCHAR(30),        -- allowed, warned, blocked
    user_cancelled BOOLEAN DEFAULT FALSE,
    
    detected_at TIMESTAMP DEFAULT NOW()
);

-- ═══════════════════════════════
-- SYSTEM & AUDIT TABLES
-- ═══════════════════════════════

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_type VARCHAR(20),           -- citizen, officer, isp, system
    user_id UUID,
    user_name VARCHAR(100),
    
    action VARCHAR(100) NOT NULL,
    module VARCHAR(50),
    target_type VARCHAR(50),
    target_id VARCHAR(100),
    
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    
    is_sensitive BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE system_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_type VARCHAR(50),
    metric_value DECIMAL(15,4),
    unit VARCHAR(20),
    tags JSONB,
    recorded_at TIMESTAMP DEFAULT NOW()
);

-- Create all indexes for performance
CREATE INDEX idx_call_analyses_citizen ON call_analyses(citizen_id);
CREATE INDEX idx_call_analyses_phone ON call_analyses(phone_number);
CREATE INDEX idx_call_analyses_risk ON call_analyses(risk_level);
CREATE INDEX idx_call_analyses_time ON call_analyses(call_start_time DESC);
CREATE INDEX idx_call_analyses_location ON call_analyses(citizen_state, citizen_city);

CREATE INDEX idx_phone_numbers_risk ON phone_numbers(risk_score DESC);
CREATE INDEX idx_phone_numbers_blocked ON phone_numbers(is_blocked);

CREATE INDEX idx_fraud_reports_status ON fraud_reports(status);
CREATE INDEX idx_fraud_reports_citizen ON fraud_reports(citizen_id);
CREATE INDEX idx_fraud_reports_number ON fraud_reports(reported_number);

CREATE INDEX idx_blocked_numbers_phone ON blocked_numbers(phone_number);
CREATE INDEX idx_blocked_numbers_active ON blocked_numbers(is_active);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_type, user_id);
CREATE INDEX idx_audit_logs_time ON audit_logs(created_at DESC);
```

---

## ══════════════════════════════════════════
## SECTION 3 — ANDROID APP: CORE SERVICES & CALL MONITORING
## ══════════════════════════════════════════

```
BUILD SECTION 3: Complete Android app core — call monitoring, AI engine, and background services.

Generate the following complete Kotlin files:

FILE 1: android-app/app/src/main/java/com/cybershield/services/CallMonitorService.kt

Complete foreground service that:
- Uses InCallService + TelecomManager for call interception
- Captures audio from both sides of call using AudioRecord API
- Streams audio in real-time to local AI engine
- Handles all call states: RINGING, ACTIVE, DISCONNECTED
- Shows persistent notification with current protection status
- Triggers ScamDetectionModel.analyzeAudio() every 2 seconds
- On HIGH RISK (score >= 70): fires FullScreenIntentActivity with risk alert
- On MEDIUM RISK (score >= 40): fires heads-up notification with warning
- Auto-cuts call if score >= 85 AND auto-block is enabled
- After call: saves encrypted recording, sends report to backend
- Must handle audio permissions gracefully (Android 13+ restrictions)
- Must work as overlay on incoming call screen (SYSTEM_ALERT_WINDOW)

FILE 2: android-app/app/src/main/java/com/cybershield/ml/ScamDetectionModel.kt

On-device AI inference engine that:
- Loads TFLite model from assets/scam_detection.tflite
- Real-time speech-to-text using ML Kit Speech API (Hindi + English + 10 Indian languages)
- Keyword detection: complete list of 200+ scam keywords in Hindi + English:
  Hindi: OTP, बैंक, केवाईसी, आधार, बीमा, लोन, रिफंड, ब्लॉक, अकाउंट, पैसे, 
         वेरिफिकेशन, अपडेट, बंद, फ्रॉड, ठग, नंबर, कार्ड, पिन, सीवीवी
  English: OTP, bank, KYC, verify, blocked, account, refund, transfer, 
           urgent, immediately, police, arrest, RBI, TRAI, penalty, suspended
- Intent classification: BENIGN / SUSPICIOUS / SCAM_LIKELY / SCAM_CONFIRMED
- Urgency detection: phrases that create fear/pressure
- Impersonation detection: "I am from HDFC/SBI/RBI/police" patterns
- Risk score calculation algorithm:
  * Base: 0
  * +15 per scam keyword detected
  * +25 if urgency phrase detected
  * +30 if impersonation detected  
  * +20 if number not in official DB
  * -30 if number verified as official
  * Cap at 100
- Real-time output: RiskAssessment(score, level, keywords, intent, confidence)

FILE 3: android-app/app/src/main/java/com/cybershield/services/SmsMonitorService.kt

SMS monitoring service that:
- Registers BroadcastReceiver for android.provider.Telephony.SMS_RECEIVED
- Also monitors SMS_DELIVER_ACTION for all incoming SMS
- Passes each SMS through text-based ScamDetectionModel
- For suspicious links: calls LinkScannerService to check against phishing DB
- Shows categorized inbox: Safe / Suspicious / Spam
- Auto-moves confirmed scam SMS to spam folder
- Handles sender ID detection (VK-BANKAL type alphanumeric senders)

FILE 4: android-app/app/src/main/java/com/cybershield/services/ScreenShareDetectionService.kt

Screen sharing & remote access detection service that:
- Monitors for running apps: AnyDesk, TeamViewer, Airdroid, QuickSupport
- Detects MediaProjection API usage (screen recording/sharing)
- When screen sharing detected DURING an active call: immediately alert user
- Shows full-screen warning: "Screen Sharing Detected - Risk: HIGH"
- Buttons: "Stop Sharing" (kills the app) and "I'm Sure, Continue"
- Logs detection event for evidence

FILE 5: android-app/app/src/main/java/com/cybershield/services/UpiMonitorService.kt

UPI fraud detection service:
- Monitors UPI payment intents from: PhonePe, GPay, Paytm, BHIM
- Intercepts before payment confirmation
- Analyzes: merchant name, UPI ID, amount against fraud patterns
- Flags: new payee + large amount, UPI ID pattern anomalies
- Cross-checks merchant UPI ID against scam database
- Shows UPI Protection overlay: shows risk score, reason, Cancel/Continue buttons

FILE 6: android-app/app/src/main/java/com/cybershield/ml/FakeApkDetector.kt

APK detection service:
- Monitors package installation via PackageInstaller.SessionCallback
- When new APK install detected: check APK name against pattern DB
- Flag: "hdfc.apk", "sbi-update.apk", "verify-kyc.apk" type names
- Check certificate signature of banking apps
- Show warning overlay before install: "Fake APK Detected - This may steal your data"

Generate each file with complete, compilable Kotlin code including all imports.
```

---

## ══════════════════════════════════════════
## SECTION 4 — ANDROID APP: ALL 30 UI SCREENS
## ══════════════════════════════════════════

```
BUILD SECTION 4: All 30 Jetpack Compose UI screens for the Citizen Android App.

Design language:
- Background: #0A0E1A (very dark navy)
- Card background: #0F1629
- Primary accent: #1E3A5F (deep blue)
- Danger: #FF3B30, Warning: #FF9500, Safe: #34C759, Info: #007AFF
- Text primary: #FFFFFF, Text secondary: #8E9BB5
- Font: System font (Roboto)
- Rounded corners: 16dp for cards, 12dp for buttons
- Neon glow effects on risk indicators

Generate complete Composable functions for ALL 30 screens:

SCREEN 1 — SplashScreen.kt
- Animated CyberShield logo (shield with pulse animation)  
- "CyberShield AI" title + "Scam Call Detection System"
- "By Gurugram Cyber Police" + Haryana Police logo
- Loading animation while checking permissions/auth
- Navigates to OnboardingScreen or HomeScreen

SCREEN 2 — OnboardingScreen.kt (3 pages with ViewPager)
Page 1: "Welcome to CyberShield AI" — shield animation, 4 feature bullets
Page 2: "How It Protects You" — animated detection flow diagram
Page 3: "Your Safety, Our Priority" — privacy guarantees
- Progress dots at bottom, Next/Get Started buttons

SCREEN 3 — PermissionsScreen.kt
- "Enable Full Protection" heading
- List each permission with icon, name, purpose, toggle:
  * Microphone — "To listen calls" — required
  * Phone — "To manage calls" — required  
  * Contacts — "To verify callers" — required
  * SMS — "To scan messages" — required
  * Location — "To detect fraud hotspot" — optional
- "Allow All" primary button + "Continue with Limited" secondary

SCREEN 4 — HomeScreen.kt (Dashboard)
- Top bar: CyberShield AI logo + notification bell + settings icon
- Protection status card: "You are Protected" green / "Protection Off" red
  with animated shield pulse
- Today's Activity row: Calls Scanned | Threats Detected | People Protected
- 4 toggle cards in 2x2 grid:
  * Call Protection: ON/OFF with phone icon
  * SMS Protection: ON/OFF with message icon
  * WhatsApp Protection: ON/OFF with WA icon
  * UPI Protection: ON/OFF with rupee icon
- Real-time Protection indicator: waveform animation when active
- Bottom navigation: Home | History | Report | More

SCREEN 5 — IncomingCallScreen.kt
- Full-screen overlay on incoming call
- Caller number + "Unknown Number" or contact name
- Avatar circle with person icon
- CyberShield AI badge at bottom showing: "Identifying Caller..."
- Waveform analysis animation
- Decline (red) and Answer (green) buttons
- If risk detected before answering: show Risk Score badge on caller avatar

SCREEN 6 — CallAnalysisScreen.kt  
- Circular progress with percentage (shows 65% → animates to final score)
- "Analyzing Call..." header
- Checklist items with animated check/loading states:
  ✓ Checking number in database
  ✓ Verifying with official sources  
  ⟳ Analyzing conversation...
  ⟳ Detecting keywords...
  ⟳ Calculating risk score...
- "Please wait, call is being monitored for your safety"

SCREEN 7 — HighRiskDetectionScreen.kt
- Full-screen RED background with pulsing danger animation
- ⚠ "High Risk Detected" + "Scam Likely" in red
- Risk Score: "85 / 100" large text + "Very High Risk" badge
- Reasons list:
  • Asking for OTP
  • Claiming to be from Bank
  • Urgency Detected
  • Number not in official database
- "End Call & Block" — primary red button (full width)
- "Report & Save Evidence" — secondary outlined button

SCREEN 8 — MediumRiskDetectionScreen.kt
- ORANGE warning theme
- ⚠ "Suspicious Call" + "Proceed with Caution"
- Risk Score: "45 / 100" + "Medium Risk" badge
- Reasons list
- "Continue Call" — orange button
- "Report Number" — outlined button

SCREEN 9 — SafeCallScreen.kt
- GREEN theme with shield checkmark animation
- "Safe Call" heading  
- "This number appears safe" subtitle
- Risk Score: "10 / 100" + "Very Low Risk" green badge
- "This number is verified and seems to be safe"
- "Continue Call" green button

SCREEN 10 — CallInProgressScreen.kt
- Call timer (02:15 format)
- "Live Protection: ON" with green indicator
- Real-time audio waveform visualization
- Detected Keywords chip list: bank, verify, account, kyc, otp
- Risk Score meter (live updating)
- "End Call" red button at bottom

SCREEN 11 — CallEndedSummaryScreen.kt
- "Call Ended" header in red/green based on outcome
- Phone number
- Final Risk Score large display
- Summary bullets (auto-generated):
  • OTP was requested
  • Fake bank representative
  • Number not verified
- Action Taken section:
  • Call Disconnected ✓
  • Number Blocked ✓  
  • Evidence Saved ✓
- "View Details" button

SCREEN 12 — CallDetailsEvidenceScreen.kt
- Phone number + date/time header
- Risk score badge
- AI-Generated Transcript (formatted as chat):
  Caller: Hello, I am from HDFC Bank.
  Victim: Yes.
  Caller: Your account is blocked.
  (etc.)
- ▶ Play Recording button
- Download/Share Evidence button

SCREEN 13 — SmsProtectionScreen.kt
- Tab row: Inbox | Spam
- SMS list with:
  * Sender ID (HDFCBK, VK-BANKAL, etc.)
  * Message preview
  * Timestamp
  * Color badge: Safe (green) / Scam Detected (red) / Suspicious (orange)
- Scam badge on suspicious messages
- Tap to view full SMS analysis

SCREEN 14 — SmsScamResultScreen.kt
- "Scam SMS Detected" header with red alert
- Reason:
  • Contains suspicious link
  • Asking for personal info
  • Reported by other users
- "Delete & Block" primary button
- "Report SMS" secondary button

SCREEN 15 — WhatsAppProtectionScreen.kt
- WhatsApp green header + "Protection Active" shield
- Feature list:
  • Detect scam calls ✓
  • Identify fraud patterns ✓
  • Alert in real-time ✓
  • Works in background ✓
- "Manage Settings" button

SCREEN 16 — WhatsAppCallScreen.kt
- "WhatsApp Call" header
- Phone number + Unknown Number
- "CyberShield AI — Analyzing WhatsApp call..." banner
- Same analysis UI as regular call

SCREEN 17 — UpiProtectionScreen.kt
- "UPI Protection" header
- "Monitoring UPI Transactions"
- When suspicious payment detected:
  * "Suspicious Activity Detected" card
  * Amount: ₹25,000
  * To: Unknown Merchant
  * Risk: High
  * Reason: New payee, Large amount, Unusual time
  * "Cancel Payment" red button
  * "Continue Anyway" ghost button

SCREEN 18 — ScreenShareDetectionScreen.kt
- ⚠ "Screen Sharing Detected" header — orange/red
- "You are sharing your screen during a call"
- "Risk: High — Scammers may access your banking details"
- "Stop Sharing" — red button
- "I'm Sure, Continue" — ghost text button

SCREEN 19 — RemoteAccessDetectionScreen.kt
- ⚠ "Remote Access App Detected"
- "AnyDesk is running during this call"
- "Risk: Very High — Scammers can control your device"
- "Close App" red button
- "Ignore Warning" ghost button

SCREEN 20 — FakeApkDetectionScreen.kt
- ⚠ "Fake APK Detected" header
- "HDFC.apk — This app may contain malware and steal your data"
- Risk: High
- "Delete File" red button  
- "Report APK" secondary button

SCREEN 21 — ScamLinkScannerScreen.kt
- "Link Scanner" header
- URL input or auto-captured URL display
- Green or Red result card:
  * URL shown
  * "Risk: High — This website is not safe"
  * Details: Newly registered domain, Low trust score, Reported by users
- "Go Back" button for unsafe links

SCREEN 22 — FraudHeatmapScreen.kt
- Full-screen India map (dark theme)
- Heat overlay: red dots for high-risk areas
- "Most Affected Cities" list
- Date filter: Today / This Week / This Month
- "View Full Map" expansion

SCREEN 23 — FamilyProtectionScreen.kt
- "Family Protection" heading
- Protected family members list:
  * Father — +91 98765 11111 — Protected (green badge)
  * Mother — +91 98765 22222 — Protected (green badge)
- "Add Family Member" button
- "You will be notified if any scam threat is detected"

SCREEN 24 — ScamSimulationTrainingScreen.kt
- "Scam Simulation" + "Learn. Identify. Stay Safe."
- Training modules:
  * OTP Scam — "Start Training" button — Level: Beginner
  * KYC Scam — "Start Training" — Level: Intermediate
  * Loan Fraud — "Start Training" — Level: Advanced
- Progress indicator per module

SCREEN 25 — CyberEmergencyScreen.kt
- "I Got Scammed — Need Immediate Help?" red header
- Steps list with action buttons:
  1. Save Call Logs
  2. Save Messages
  3. Save Screenshots
  4. Generate Report
- "Start Emergency" large red button
- Connects directly to Gurugram Cyber Police helpline

SCREEN 26 — HistoryScreen.kt
- Tab row: All | Calls | SMS | WhatsApp
- Timeline list with:
  * Phone number + call type icon
  * Date/time
  * Risk score badge (colored 0-100)
  * Risk level text
- Filter by: Date | Risk Level | Type

SCREEN 27 — ReportFraudScreen.kt
- "Report Fraud" heading
- Phone number field (pre-filled from context)
- "Select Type" dropdown: Call Fraud / SMS Fraud / WhatsApp Fraud / UPI Fraud / Other
- Description text area
- "Upload Evidence (Optional)" — image/recording picker
- "Submit Report" primary button

SCREEN 28 — ReportSubmittedScreen.kt
- ✓ green checkmark animation
- "Report Submitted Successfully"
- Report ID: CSAI2025051800001
- "Thank you for helping us build a safer community"
- "Done" button

SCREEN 29 — BlockedNumbersScreen.kt
- "Blocked Numbers" heading + total count badge
- List: phone number | blocked date | delete button
- Swipe to unblock

SCREEN 30 — SettingsScreen.kt
- General Settings (notifications, language: English/Hindi/Regional)
- Protection Settings (auto-block threshold, call monitoring)
- Privacy & Security (data storage, export data, delete account)
- Permission Manager (shows all permissions, re-request buttons)
- About CyberShield AI (version, credits, Gurugram Cyber Police badge)
- Premium upgrade section (if not premium)

Also generate Navigation.kt with complete NavHost mapping all 30 screens
with proper deep links and argument passing.
```

---

## ══════════════════════════════════════════
## SECTION 5 — BACKEND: AI ENGINE & MICROSERVICES
## ══════════════════════════════════════════

```
BUILD SECTION 5: Complete Python FastAPI backend services and AI engine.

FILE 1: backend/services/call-analysis-service/analyzer.py

Complete call analysis service:

class CallAnalyzer:
    def __init__(self):
        - Load DistilBERT model fine-tuned for scam detection
        - Load XGBoost model for audio feature analysis
        - Load SpeechBrain for speech processing
        - Initialize Whisper for transcription
        - Load scam_keywords.json (200+ keywords in 11 languages)
        - Load bank_numbers_registry.json (all Indian banks official numbers)
        - Load official_numbers.json (government, insurance, telecom)
    
    async def analyze_audio_chunk(self, audio_bytes: bytes, phone_number: str) -> RiskAssessment:
        - Convert audio bytes to mel spectrogram
        - Run XGBoost on audio features (MFCCs, spectral contrast, chroma)
        - Run Whisper transcription (with Hindi + English model)
        - Run keyword detection on transcript
        - Run DistilBERT intent classification
        - Check phone_number against official registry
        - Calculate composite risk score
        - Return RiskAssessment object
    
    def calculate_risk_score(self, factors: dict) -> int:
        - Implement complete scoring algorithm:
          * audio_anomaly_score * 0.2
          * keyword_score * 0.25  
          * intent_score * 0.25
          * urgency_score * 0.15
          * number_verification_score * 0.15
        - Apply boosters: +20 if OTP mentioned AND impersonating bank
        - Apply reducers: -25 if verified official number
        - Return score 0-100
    
    async def check_number(self, phone_number: str) -> NumberInfo:
        - Query PostgreSQL for phone_number record
        - Check against bank registry
        - Check against TRAI database (via API)
        - Check against our blocked_numbers table
        - Return NumberInfo(is_official, org_name, risk_level, is_blocked)
    
    async def generate_transcript_summary(self, full_transcript: str) -> CallSummary:
        - Use GPT/Claude API or local LLM
        - Generate structured summary with:
          * main_intent (what the caller wanted)
          * scam_indicators (list of red flags)
          * victim_at_risk (boolean)
          * recommended_action

FILE 2: backend/services/call-analysis-service/main.py

FastAPI service with endpoints:
- POST /analyze/chunk — analyze single audio chunk (called from Android every 2s)
- POST /analyze/complete — analyze full call recording after call ends
- POST /number/verify — verify if phone number is official
- GET /number/{phone}/history — get all previous analyses for a number
- POST /transcript — get full AI-generated transcript from recording
- WebSocket /ws/live/{call_id} — stream real-time risk updates to Android app

FILE 3: backend/ai-engine/models/scam_classifier/train.py

Complete training script:
- Dataset sources to use:
  * MUCS Hindi speech dataset
  * IndicSpeech multilingual dataset  
  * Custom synthetic scam dialogue dataset (generate 10,000 examples)
  * Collected FIR/complaint reports data
  
- Model architecture:
  * Base: distilbert-base-multilingual-cased
  * Fine-tuned on: 
    - 50,000 scam call transcripts (synthetic + real)
    - 11 Indian languages
    - 8 scam categories
  
- Training config:
  * epochs=10, batch_size=32, lr=2e-5
  * Use weighted loss for class imbalance
  * Validation split: 80/10/10

- Export formats:
  * PyTorch (.pt) for server
  * ONNX for optimization
  * TFLite for Android device

FILE 4: backend/services/number-intelligence-service/bank_registry.py

Complete Indian bank number registry:
- Populate with ALL major Indian banks' official customer care numbers:
  SBI, HDFC, ICICI, Axis, PNB, BOB, Canara, Union Bank, IDBI, Kotak,
  Yes Bank, IndusInd, Federal Bank, South Indian Bank, Karnataka Bank,
  and 40+ more banks
  
- Each bank entry:
  {
    bank_name: str,
    bank_code: str,
    customer_care_numbers: List[str],
    fraud_reporting_numbers: List[str],
    official_sms_sender_ids: List[str],
    official_website: str,
    rbi_registered: bool,
    verified_at: datetime
  }
  
- Also include:
  * All Indian government helplines (1930 cyber crime, 112 emergency, etc.)
  * Insurance company numbers (LIC, Star Health, HDFC Life etc.)
  * TRAI, RBI official numbers
  * All telecom customer care (Jio, Airtel, Vi, BSNL)

FILE 5: backend/services/reporting-service/sanchar_saathi.py

Sanchar Saathi integration:
- Auto-report confirmed scam numbers to:
  * Sanchar Saathi API (DoT portal)
  * National Cyber Crime Reporting Portal (cybercrime.gov.in)
  
- generate_report(call_analysis: CallAnalysis) -> FraudReport:
  * Format evidence package
  * Include: transcript, risk score, evidence hash, location
  * Submit via API
  * Store ticket ID for tracking
  
- auto_block_request(phone_number: str) -> BlockRequest:
  * Submit number deactivation request to TRAI
  * Notify relevant telecom operator
  * Update our blocked_numbers table

FILE 6: backend/services/isp-service/telecom_api.py

ISP/Telecom integration layer:
- Standard API interface for: Jio, Airtel, Vi, BSNL
- Endpoints ISPs can call:
  * GET /api/isp/threat-feed — live threat intelligence feed
  * GET /api/isp/blocked-numbers — numbers to block at network level
  * POST /api/isp/confirm-block — confirm a number has been blocked
  * GET /api/isp/analytics — threat analytics for their network
  
- Webhook system for real-time updates
- Number portability lookup integration
- Circle-wise threat statistics

Generate all files with complete, production-ready Python code.
Include proper error handling, logging, Pydantic models, and unit tests.
```

---

## ══════════════════════════════════════════
## SECTION 6 — POLICE ADMIN PORTAL (ALL SCREENS)
## ══════════════════════════════════════════

```
BUILD SECTION 6: Complete Next.js 14 Police Admin Portal matching mockup Image 13 exactly.

Tech: Next.js 14 App Router + TypeScript + Tailwind CSS + shadcn/ui
Design: Dark theme, colors from design system above
Charts: Recharts (DO NOT use Chart.js)
Maps: Google Maps + heatmap layer

Generate ALL 15 pages + components:

LAYOUT: police-dashboard/src/app/(dashboard)/layout.tsx
- Left sidebar (240px fixed):
  * CyberShield AI logo + "Police Admin Panel" subtitle
  * Inspector profile: name, badge, station
  * Navigation items (EXACT as in mockup):
    Dashboard, Live Monitoring (LIVE badge), Threat Intelligence, 
    Fraud Heatmap, Scam Reports, Blocked Numbers, Fraud Campaigns,
    Digital Trust Score, UPI Fraud Monitoring, Bank Verification,
    Deepfake Detection, Case Management, Complaints, Evidence Vault,
    Analytics & Insights, Users & Roles, Audit Logs, System Settings
  * System Status: green "All Systems Operational"
- Top bar: breadcrumb + date range picker + Download Report button + notifications + profile

PAGE 1: Dashboard (page.tsx)
Stats row (6 cards with trends):
- Total Reports This Week + % change
- High Risk Alerts + % change
- Confirmed Fraud Cases + % change
- Numbers Analyzed + % change
- SMS Analyzed + % change
- WhatsApp Analyzed + % change

Second stats row:
- UPI Fraud Attempts + % change
- Money Saved (₹12.48 Cr) + % change
- Victims Protected + % change
- FIR Registered + % change
- Arrests Made + % change
- Active Investigations + % change

Main content:
- Threat Trend Chart (line chart, 7 days): High-Risk Calls | Scam SMS | WhatsApp | UPI Fraud
- Risk Distribution Donut: High Risk % | Medium % | Low % | Safe %
- India Fraud Heatmap (mini map widget)
- Real-time Live Feed (right panel)

PAGE 2: Live Monitoring
- Stats: Live Calls | High Risk Calls | Live SMS/min | WhatsApp Sessions
- Left: Live Call Feed — scrolling list of active calls being analyzed
  Each item: phone number | location | risk score badge | time
- Center: Active High Risk Call details:
  * Phone number + location
  * Risk score 85/100 gauge
  * Audio waveform visualization
  * Live Transcript (chat bubble format):
    Caller: Your KYC is pending.
    Victim: Okay.
    Caller: To update it, I need your OTP.
    Victim: Which OTP?
    (etc.)
  * Listen Live | Mute | Add Note buttons
- Right: Live Risk Feed (all active threats)

PAGE 3: Threat Intelligence
- Active Campaigns table:
  * Campaign name, type, first detected, affected count, risk score
  * Campaign Trend mini-chart per campaign
- Top Keywords Detected: keyword | count | trend (real-time)
- Attack Vectors breakdown chart

PAGE 4: Fraud Heatmap  
- Full-page India map with heatmap overlay (Google Maps)
- Map controls: zoom, toggle heat intensity
- Top Affected Cities list (sidebar):
  Mumbai | Delhi | Bengaluru | Hyderabad | Kolkata | Chennai | Pune
- Date range filter
- Toggle layers: High Risk only | All risks
- District-level drill down

PAGE 5: Scam Reports
- Filter tabs: All Reports | High Risk | Under Review | Confirmed | Resolved
- Reports table:
  Report ID | Phone Number | Type | Reported By | Location | Date | Risk | Status | Actions
- Click → Opens report detail panel (slide-over)
- Report Detail includes: full timeline, evidence links, officer assignment

PAGE 6: Blocked Numbers
- Filter tabs: All Blocked | By System | By ISP Request | By Government
- Table: Phone Number | Operator | Circle | Blocked On | Blocked By | Reason | Status | Actions
- "Add Number" button → modal form
- "Export" button

PAGE 7: Fraud Campaigns
- Campaign cards with detailed stats:
  * Campaign name + type badge
  * First detected date
  * Active numbers count
  * Victim count
  * Risk Score gauge
  * Affected states map (mini India map)
  * "View Details" button
- Campaign Map Overview (India map with campaign distribution)
- Past Campaigns + Cluster Analysis tabs

PAGE 8: Digital Trust Score
- Search input: "Search number..."
- Result display for searched number:
  * Overall Score: 32/100 — "High Risk" red badge
  * Score Breakdown visual:
    - User Reports: 9/25 progress bar
    - AI Analysis: 8/25 progress bar
    - Fraud History: 7/25 progress bar
    - Bank Verification: 5/15 progress bar
    - Network Reputation: 3/10 progress bar
  * Recent Activity timeline
  * "View Full History" button

PAGE 9: Case Management
- Filter tabs: All Cases | Open | Under Investigation | Closed | Court Cases
- Cases table: 
  Case ID | Title | FIR No. | Date | Status | Priority | Investigating Officer | Last Updated
- New Case button → full form modal
- Case Detail: complete case file with evidence, timeline, FIR generator

PAGE 10: Evidence Vault
- Filter tabs: All Evidence | Calls | SMS | WhatsApp | Files | Links | Images
- Evidence table:
  Evidence ID | File Name | Type | Related To | Uploaded By | Date | Size | Actions
- Upload Evidence button with drag-drop zone
- Chain of custody log per evidence item
- Download evidence (access logged to audit trail)

PAGE 11: Analytics & Insights
- Peak Call Time chart (hourly heatmap 24h x 7days)
- Most Targeted Age Group bar chart
- Top Scam Type pie chart
- Most Affected Location treemap
- Call Trend line chart (30 days)
- Scam Types Distribution donut chart
- Geographic bar chart: Top Cities by threat volume

PAGE 12: Users & Roles
- Users tab: Table of all police officers
  Name | Badge | Role | Department | Station | Last Login | Status | Actions
- Roles tab: Role permissions matrix
- Add User button → form with role assignment

PAGE 13: Audit Logs
- Complete audit trail table:
  Log ID | User | Action | Module | Date & Time | IP Address
- Filter by: user, action type, date range
- Export as CSV/PDF

PAGE 14: System Settings
- Tabs: General | Integrations | Alerts | Users | Security | Data | Audit
- General: Station name, timezone (IST pre-filled), date format, language
- Integrations: toggle cards for Sanchar Saathi, TRAI, Bank Verification, Police DB, WhatsApp Business APIs
- Alerts: thresholds for auto-block, notification triggers
- Security: 2FA settings, IP whitelisting, data encryption settings
- Save Changes button (sticky footer)

PAGE 15: Audit Logs
- Complete system audit trail
- Filter: All Logs | System | Access | Compliance
- Log table with full details

Generate ALL components as real, working TypeScript + Tailwind code.
Use real Recharts charts, not placeholder divs.
```

---

## ══════════════════════════════════════════
## SECTION 7 — ISP/TELECOM PORTAL (ALL SCREENS)
## ══════════════════════════════════════════

```
BUILD SECTION 7: Complete Next.js 14 ISP/Telecom Portal matching mockup Image 5/9 exactly.

Same tech stack as Police Portal.
ISP user: Rajesh Kumar, SP Admin, ISP Telecom Services Ltd.

Generate ALL 12 sections:

LAYOUT: isp-portal/src/app/(dashboard)/layout.tsx
Sidebar navigation (exact from mockup):
Dashboard, Real-time Monitor, Number Intelligence, Traffic Analytics,
Threat Detection, Blocked Numbers, Customer Reports, API Integrations,
Compliance & Logs, Alerts & Notifications, Settings, Support

Top bar: company name + user profile + Date range + Export Report

PAGE 1: Dashboard Overview
Stats row:
- Total Calls Monitored: 25.64M (+16.7%)
- Threat Calls Detected: 125.8K (+12.4%)
- SMS Analyzed: 8.71M (+15.3%)
- WhatsApp Sessions: 3.22M (+9.1%)
- Active Alerts: 532 (+2.8%)

Charts:
- Threat Detection Trend (line chart, 7 days): High Risk | SMS | WhatsApp
- Risk Level Distribution donut: High 28.8% | Medium 34.2% | Low 19.3% | Safe 17.9%
- Top Threats Detected table: OTP Fraud 43,978 | Bank Fraud 32,456 | KYC Scam etc.
- Top Circles by Threats table
- Live Threat Map (India heatmap)
- Top 5 States by Live Threats
- System Status: "All Systems Operational"

PAGE 2: Real-time Monitor
- Live Stats bar: Live Calls | High-Risk Calls | SMS Per Min | WhatsApp Sessions
- Live Call Feed (real-time scrolling list)
- Live Call Waveform (for selected call)
- Live Threat Map (India, live dots appearing)
- Live Feed panel (right) — all active threats with scores

PAGE 3: Number Intelligence
- Search bar: "Search number..." + "All Circles" filter
- Filter tabs: All Numbers | High Risk | Medium Risk | Low Risk | Whitelisted
- Table: Phone Number | Operator | Circle | Risk Score | Risk Level | Last Active | Reports | Status | Action
- Pagination: Show 50 records per page
- Color-coded risk badges matching design system

PAGE 4: Traffic Analytics
- Stats: Total Traffic | Voice Calls | SMS | WhatsApp Sessions
- Traffic Over Time chart (area chart, 7 days)
- Traffic by Circle donut chart: North 31.4% | South 27.8% | East 24.6% | West etc.

PAGE 5: Threat Detection
- Filter tabs: All Threats | Calls | SMS | WhatsApp
- Threats table:
  Threat Type | Count | Trend (sparkline) | Severity | Affected | Detection Accuracy
- Detection Accuracy donut: 96.7% accuracy, 2.1% false positives
- Export button

PAGE 6: Blocked Numbers
- Filter tabs: All Blocked | By ISP Request | By System Detection | By Government
- Table: Phone Number | Operator | Circle | Blocked On | Blocked By | Reason | Status
- "Request Block" button
- Export functionality

PAGE 7: Customer Reports
- Table: Report ID | Phone Number | Type | Reported By | Reported On | Status
- Tabs: All Reports | Pending | Under Review | Resolved
- Totals bar: Total Reports | Pending | Under Review | Resolved

PAGE 8: API Integrations
- Integration cards (toggle active/inactive):
  * Sanchar Saathi API — Number Verification — Active
  * Bank Verification API — Bank Details — Active
  * UIDAI Verification API — KYC Verification — Active
  * Police Database API — Criminal Records — Active
  * Govt. Alert API — Threat Intelligence — Active
  * WhatsApp Business API — Message Analysis — Active
- Total API Calls | Successful Calls | Success Rate | Failed Calls stats
- "Add Integration" button

PAGE 9: Compliance & Logs
- Tabs: All Logs | System Logs | Access Logs | Compliance Logs
- Log table: Log ID | Event Type | User/System | Module | Date & Time | IP Address
- Export functionality

PAGE 10: Alerts & Notifications
- Alert tabs: All | Critical | Warning | Info
- Alert list: severity icon | message | number | location | time
- Alert Summary card: Critical 15 | Warning 23 | Info 45 | Total Alerts 83
- "View All Alerts" button

PAGE 11: Settings
- Tabs: General | Monitoring Settings | Alert Settings | User Management | API Settings
- General: Organization name (ISP Telecom Services Ltd.), security settings, timezone
- Security: Two-factor auth toggle, auto logout, IP whitelisting, data encryption, audit logging
- Save Changes sticky footer

PAGE 12: Support
- Tabs: Support Tickets | FAQ | Contact Support
- Tickets table: Ticket ID | Subject | Priority | Status | Created On
- "Create New Ticket" button
- FAQ accordion section
```

---

## ══════════════════════════════════════════
## SECTION 8 — REAL-TIME WEBSOCKET & KAFKA SYSTEM
## ══════════════════════════════════════════

```
BUILD SECTION 8: Complete real-time event streaming system.

FILE 1: backend/services/notification-service/websocket_handler.py

Complete WebSocket server using FastAPI + Socket.io:

class WebSocketManager:
    - Connection pools for: police_officers, isp_operators, android_apps
    - Room-based broadcasting: by state, by district, by risk_level
    
    async def broadcast_to_police(event: str, data: dict):
        - Broadcast to all connected police dashboard instances
        - Event types: NEW_HIGH_RISK_CALL, NEW_SCAM_REPORT, NUMBER_BLOCKED, 
          CASE_UPDATED, NEW_EVIDENCE, LIVE_TRANSCRIPT_CHUNK
    
    async def broadcast_to_isp(event: str, data: dict, operator: str = None):
        - Broadcast to specific ISP or all ISPs
        - Event types: THREAT_ALERT, NEW_BLOCK_REQUEST, TRAFFIC_ANOMALY
    
    async def send_to_device(device_id: str, event: str, data: dict):
        - Send to specific Android device
        - Event types: RISK_UPDATE, CALL_ALERT, SMS_ALERT, BLOCK_CONFIRMED

FILE 2: backend/shared/kafka/producer.py

Kafka event producer:
TOPICS to create:
- cybershield.calls.analyzed     — all call analysis results
- cybershield.calls.high-risk    — high risk calls only (fast lane)
- cybershield.sms.detected       — SMS scam detections
- cybershield.numbers.blocked    — number blocking events
- cybershield.reports.submitted  — new fraud reports
- cybershield.cases.updated      — case management updates
- cybershield.isp.block-requests — requests sent to ISPs
- cybershield.ai.model-updates   — AI model version updates

class EventProducer:
    publish_call_analyzed(call_data: dict) 
    publish_high_risk_alert(alert_data: dict)
    publish_number_blocked(block_data: dict)
    publish_fraud_report(report_data: dict)

FILE 3: backend/shared/kafka/consumer.py

Consumers for each service:
- NotificationConsumer: listens to high-risk → pushes to WebSocket
- ISPConsumer: listens to block-requests → forwards to telecom APIs
- AnalyticsConsumer: listens to all events → updates metrics/heatmap
- EvidenceConsumer: listens to high-risk → auto-packages evidence

Generate complete, production-ready Python code for all files.
```

---

## ══════════════════════════════════════════
## SECTION 9 — SECURITY, ENCRYPTION & COMPLIANCE
## ══════════════════════════════════════════

```
BUILD SECTION 9: Complete security architecture.

FILE 1: backend/shared/security/encryption.py

Complete encryption service:
- AES-256-GCM for all stored recordings and evidence
- Separate key per citizen (derived from user ID + server secret)
- Key rotation every 90 days
- Hardware-backed key storage on Android (Android Keystore)

class EncryptionService:
    encrypt_recording(audio_bytes: bytes, citizen_id: str) -> EncryptedFile
    decrypt_recording(encrypted_file: EncryptedFile, citizen_id: str) -> bytes
    generate_evidence_hash(file_bytes: bytes) -> str  # SHA-256 for integrity
    sign_evidence(file_bytes: bytes, officer_id: str) -> SignedEvidence

FILE 2: backend/shared/security/auth_middleware.py

Multi-layer authentication:
- Citizens: Firebase Auth JWT + device fingerprint
- Police: Custom JWT + badge number + 2FA (TOTP)
- ISP: API key + JWT + IP whitelist
- Rate limiting: 100 req/min per IP, 1000 req/min per API key
- Request signing for sensitive operations (adding to blocked list)

FILE 3: android-app security configuration:
- Certificate pinning for all API calls
- Root detection and response
- Frida/Xposed detection
- Tamper detection via SafetyNet/Play Integrity API
- Network security config (no cleartext, specific cert pins)

FILE 4: Privacy compliance (India PDPB 2023 + IT Act):
- Data minimization: only collect what's needed
- Purpose limitation: clear purpose for each data point
- User consent management system
- Right to erasure: complete data deletion on request
- Data localization: all data stored in Indian data centers
- Breach notification system: auto-alert within 72 hours

Generate all security files with production-ready code.
Include unit tests for encryption/decryption functions.
```

---

## ══════════════════════════════════════════
## SECTION 10 — GOVERNMENT INTEGRATIONS
## ══════════════════════════════════════════

```
BUILD SECTION 10: All government API integrations.

FILE 1: backend/services/reporting-service/sanchar_saathi.py

Complete Sanchar Saathi (DoT) integration:
- API: https://sancharsaathi.gov.in (use their actual API when available)
- Auto-report confirmed scam numbers
- Track ticket status
- Webhook for when TRAI deactivates a number

FILE 2: backend/services/number-intelligence-service/trai_integration.py

TRAI DND & number verification:
- Check if number is on DND registry
- Check number registration status
- Submit deactivation requests
- Bulk number lookup (up to 1000 numbers per request)

FILE 3: backend/services/reporting-service/cybercrime_portal.py

National Cyber Crime Reporting Portal integration:
- Portal: cybercrime.gov.in
- Auto-submit FIR for high-confidence fraud cases
- Track complaint status
- Generate complaint reference numbers

FILE 4: police-dashboard/src/lib/fir-generator.ts

Automated FIR document generator:
- Generates properly formatted FIR in:
  * English (for court submission)
  * Hindi (for local police station)
- Pre-fills from case data: victim details, accused number, evidence
- Generates PDF with all required fields
- Digital signature support
- Auto-numbering (CS2025018-001 format)

Generate all integration files with proper error handling and fallbacks
for when government APIs are unavailable.
```

---

## ══════════════════════════════════════════
## SECTION 11 — KUBERNETES & PRODUCTION DEPLOYMENT
## ══════════════════════════════════════════

```
BUILD SECTION 11: Complete Kubernetes deployment configuration for production.

Generate all Kubernetes YAML files:

infrastructure/kubernetes/

DEPLOYMENTS (one per microservice):
- api-gateway-deployment.yaml (3 replicas, HPA max 20)
- call-analysis-deployment.yaml (5 replicas, GPU node selector for AI)
- auth-service-deployment.yaml (3 replicas)
- notification-service-deployment.yaml (3 replicas)
- isp-service-deployment.yaml (2 replicas)
- reporting-service-deployment.yaml (2 replicas)
- ai-engine-deployment.yaml (GPU instances, 2 replicas)
- police-dashboard-deployment.yaml (2 replicas)
- isp-portal-deployment.yaml (2 replicas)

SERVICES + INGRESS:
- nginx-ingress-controller.yaml
- ssl-certificate.yaml (Let's Encrypt + custom govt domain)
- api-gateway-service.yaml (LoadBalancer type)
- Police dashboard: police.cybershieldai.gov.in
- ISP portal: isp.cybershieldai.gov.in
- API: api.cybershieldai.gov.in

CONFIGMAPS & SECRETS:
- cybershield-config.yaml (non-sensitive config)
- cybershield-secrets.yaml (template — actual values from Vault)
- database-config.yaml

HORIZONTAL POD AUTOSCALER:
- Scale call-analysis-service: 5→50 pods when CPU > 70%
- Scale notification-service: 3→30 pods based on WebSocket connections

MONITORING:
- prometheus-deployment.yaml
- grafana-deployment.yaml
- alertmanager.yaml (alerts to police email/SMS when system critical)

SCRIPTS:
scripts/deploy.sh — one-command deployment:
1. Build all Docker images
2. Push to ECR/GCR
3. kubectl apply all yamls
4. Run database migrations
5. Seed initial data (bank numbers, official numbers)
6. Health check all services
7. Send deployment notification to team

Also generate:
- GitHub Actions CI/CD pipeline (.github/workflows/deploy.yml)
- Automated testing pipeline
- Security scanning (Trivy, Snyk)
- Performance testing (k6 load test scripts)
```

---

## ══════════════════════════════════════════
## SECTION 12 — AI MODEL TRAINING & DATASETS
## ══════════════════════════════════════════

```
BUILD SECTION 12: Complete AI training pipeline.

FILE 1: backend/ai-engine/models/scam_classifier/dataset.py

Dataset builder for scam detection:

Synthetic data generation (generate_synthetic_dataset.py):
- Generate 50,000 scam call transcripts in English + Hindi
- Scam types with templates:
  
  1. OTP Fraud (Bank impersonation):
     "Hello, I am calling from [BANK_NAME]. Your [card/account] is [blocked/at risk]. 
      To [verify/update/activate] your account, please share the OTP sent to your number."
     
  2. KYC Scam:
     "Your KYC is [pending/expired/not updated]. You must complete it within [X hours] 
      or your account will be blocked. Please share your [Aadhaar/PAN/account details]."
     
  3. Fake Police Call:
     "I am calling from [Cyber Crime Cell/CBI/ED]. A case has been registered against 
      your number for [money laundering/illegal activity]. You must cooperate or face arrest."
  
  4. Loan Fraud:
     "You are approved for a [₹X lakh] loan with no documents. 
      Pay a small processing fee of ₹[X] to receive the amount."
  
  5. Investment Fraud:
     "We are offering [X]% daily returns on your investment. 
      Our clients have already earned ₹[X] crore. Invest now."
      
  6. Courier Scam:
     "A package in your name has been [seized/held] at [airport]. 
      It contains [drugs/illegal items]. You must pay ₹[X] fine to clear it."
  
  7. Electricity/Gas Bill Scam:
     "Your [electricity/gas] connection will be disconnected in [X hours] 
      due to non-payment. Call this number immediately."
  
  8. Job Fraud:
     "Congratulations! You are selected for [job title]. 
      Pay a registration fee of ₹[X] to confirm your position."

- Generate in 11 languages: Hindi, English, Bengali, Telugu, Marathi, 
  Tamil, Gujarati, Kannada, Malayalam, Punjabi, Odia

- Balance: 60% scam, 40% legitimate calls
- Add noise: background sounds, Indian accents, voice variations

FILE 2: backend/ai-engine/models/scam_classifier/train.py

Complete training script:
- Use Hugging Face Transformers
- Model: ai4bharat/indic-bert (better for Indian languages than multilingual BERT)
- Also train: distilbert-base-multilingual-cased (faster, for edge deployment)
- Training metrics: accuracy, precision, recall, F1, AUC-ROC
- Target: >95% accuracy, <2% false positive rate
- Export to ONNX + TFLite for Android deployment
- MLflow experiment tracking

FILE 3: backend/ai-engine/serving/model_server.py

High-performance model server:
- Triton Inference Server configuration
- Batch inference for high throughput
- Model versioning and A/B testing
- Auto-fallback if primary model fails
- Latency target: <200ms for inference

Generate complete, runnable Python code for all training files.
Include requirements.txt with all dependencies pinned.
```

---

## ══════════════════════════════════════════
## SECTION 13 — COMPLETE IMPLEMENTATION CHECKLIST
## ══════════════════════════════════════════

```
BUILD SECTION 13: Final integration, testing, and demo setup.

FILE 1: Demo script for Gurugram Cyber Police presentation

demo/POLICE_DEMO_SCRIPT.md:

DEMO SCENARIO: "HDFC Bank OTP Fraud"
Duration: 5 minutes

Step 1 [0:00-0:30] — Show citizen app dashboard
- "You are Protected" — green status
- All 4 protections ON

Step 2 [0:30-1:00] — Receive incoming call from unknown number
- App shows: "Incoming Call — +91 98765 43210 — Unknown Number"
- CyberShield AI badge appears: "Analyzing..."

Step 3 [1:00-2:00] — Live analysis during call
- Caller says: "Hello, I am from HDFC Bank. Your account is blocked. 
  Please share your OTP to verify."
- Risk score jumps: 20 → 45 → 65 → 85
- RED ALERT: "High Risk Detected — Scam Likely"
- Keywords detected: HDFC, bank, blocked, OTP

Step 4 [2:00-2:30] — System actions
- Call automatically disconnected
- Evidence saved
- Auto-reported to Sanchar Saathi
- Police dashboard shows new case in real-time

Step 5 [2:30-3:30] — Police dashboard view (on laptop)
- Inspector sees: "High Risk Call Detected — +91 98765 43210 — Gurugram, HR"
- Opens live transcript
- Sees call recording, risk factors, citizen details
- One-click: "Block Number" → sent to all telecom operators

Step 6 [3:30-4:30] — ISP Portal view
- Block request received for +91 98765 43210
- One-click confirm
- Number deactivated across all networks
- Status: Active → Blocked

Step 7 [4:30-5:00] — Impact shown
- Fraud Heatmap: Gurugram dot appears
- Statistics updated: 1 more fraud prevented
- "0 rupees lost, 1 citizen protected"

FILE 2: scripts/seed_demo_data.py
- Seed realistic demo data:
  * 1,234 total reports
  * 532 high-risk numbers
  * 5 active fraud campaigns
  * India heatmap data for all states
  * 45 police officers
  * 5 ISP operators

FILE 3: Complete API documentation (docs/API.md)
- OpenAPI spec for all 50+ endpoints
- Authentication guide
- Rate limits
- Webhook documentation
- SDK examples in: Python, Kotlin, JavaScript

FILE 4: TEAM_SETUP.md
4-person team split:
Person 1 (Backend Lead): API gateway, call analysis service, database
Person 2 (AI/ML): Model training, speech-to-text, scoring algorithm
Person 3 (Android): Android app, on-device AI, call monitoring service
Person 4 (Frontend): Police dashboard, ISP portal, maps

Week 1-2: Setup + basic call interception + database
Week 3-4: AI model training + risk scoring
Week 5-6: Police dashboard + reporting
Week 7-8: ISP portal + government integrations
Week 9-10: Integration testing + bug fixes
Week 11-12: Demo preparation + deployment

FILE 5: One-command local development setup
scripts/dev-setup.sh:
#!/bin/bash
# Install all dependencies
# Start Docker services (PostgreSQL, Redis, Kafka, MongoDB)
# Run database migrations
# Seed demo data
# Start all backend services
# Start police dashboard (localhost:3000)
# Start ISP portal (localhost:3001)
# Print Android app connection instructions

echo "CyberShield AI is running!"
echo "Police Dashboard: http://localhost:3000"
echo "ISP Portal: http://localhost:3001"
echo "API: http://localhost:8000"
echo "Demo login - Police: admin@cybershield.gov.in / CyberShield@2025"
```

---

## ══════════════════════════════════════════
## QUICK START: HOW TO USE THESE PROMPTS
## ══════════════════════════════════════════

### Step 1 — Setup (Day 1)
1. Create folder: `mkdir CYBERSHIELD-AI && cd CYBERSHIELD-AI`
2. Open Claude Codex / Cursor AI / GitHub Copilot Workspace
3. Paste MASTER SYSTEM PROMPT first
4. Then paste SECTION 1 → get complete folder structure + docker-compose.yml

### Step 2 — Database & Backend (Day 2-3)
5. Paste SECTION 2 → get complete database schema
6. Run: `psql -f backend/shared/database/migrations/001_initial_schema.sql`
7. Paste SECTION 5 → get all Python backend services
8. Paste SECTION 8 → get Kafka + WebSocket system

### Step 3 — Android App (Day 4-6)
9. Paste SECTION 3 → get all Kotlin services
10. Paste SECTION 4 → get all 30 UI screens

### Step 4 — Web Portals (Day 7-9)
11. Paste SECTION 6 → get complete Police Admin Portal
12. Paste SECTION 7 → get complete ISP Portal

### Step 5 — AI & Production (Day 10-12)
13. Paste SECTION 9 → security & encryption
14. Paste SECTION 10 → government integrations
15. Paste SECTION 11 → Kubernetes deployment
16. Paste SECTION 12 → AI model training
17. Paste SECTION 13 → demo setup

### Step 6 — Run Everything
```bash
cd CYBERSHIELD-AI
chmod +x scripts/dev-setup.sh
./scripts/dev-setup.sh
```

---

## IMPORTANT NOTES FOR YOUR TEAM

**Android WhatsApp Monitoring:**
WhatsApp does not provide an official API for call monitoring.
Your app can monitor WhatsApp calls via Android Accessibility Service 
(reads screen content) or NotificationListenerService (notification monitoring).
Full audio analysis of WhatsApp calls requires root access — clarify 
scope with Gurugram Cyber Police before implementation.

**TRAI/Sanchar Saathi API:**
Contact DoT (Department of Telecommunications) directly for official API access 
at sancharsaathi.gov.in — as a government-backed project, you will get priority access.

**Audio Permission (Android 10+):**
Real-time audio capture during calls requires special permissions on Android 10+.
File an exception request or use CALL_RECORDING accessibility approach.
Consult with Gurugram Cyber Police's legal team for lawful interception compliance.

**Data Localization:**
Per India's PDPB 2023, all data must be stored in Indian data centers.
Use AWS Mumbai (ap-south-1) or GCP Mumbai region.

---

*CYBERSHIELD AI — Securing Calls, Protecting Citizens*
*Built for Gurugram Cyber Police | Team CyberShield 2025*

