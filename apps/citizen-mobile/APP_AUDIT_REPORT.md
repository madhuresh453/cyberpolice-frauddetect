# CYBERSHIELD CITIZEN APP - COMPLETE AUDIT REPORT

## Project Structure Overview

```
lib/
├── main.dart                         # Entry point with GoRouter + ProviderScope
├── app.dart                          # Legacy app shell (deprecated)
├── routes/
│   └── app_router.dart               # GoRouter with StatefulShellRoute (all 50+ routes)
├── api/
│   └── api_client.dart               # All REST endpoints prefixed /api/v1/
├── core/
│   ├── config/app_config.dart        # API URLs, WS URLs, version config
│   ├── permission_manager.dart       # Mandatory/optional permission check
│   └── secure_storage.dart           # Dual storage (FlutterSecureStorage + Hive)
├── providers/                        # Riverpod state management (auth, settings, etc.)
├── screens/                          # 40+ screens across sub-folders
│   ├── home/                         # Dashboard with 6 quick actions, protection modules
│   ├── auth/                         # Login, Register, OTP
│   ├── permissions/                  # Permission gate
│   ├── ai/                           # AI text/call analysis
│   ├── ai_investigator/              # Universal scanner (phone, UPI, URL, SMS, QR)
│   ├── call/                         # Incoming call, live protection, analysis
│   ├── sms/                          # SMS protection
│   ├── whatsapp/                     # WhatsApp protection
│   ├── upi/                          # UPI verification
│   ├── safety/                       # Emergency SOS
│   ├── reports/                      # Fraud reporting
│   └── profile/                      # Settings, permissions, vault
├── services/
│   ├── background_service.dart       # 24/7 monitoring bridge
│   ├── native_bridge_service.dart    # Flutter ↔ Android native method channel
│   ├── websocket_service.dart        # Socket.IO for real-time police sync
│   ├── local_notification_service.dart # Push notifications
│   ├── trust_engine.dart             # Offline + online fraud analysis
│   └── app_initializer.dart          # Startup service orchestration
├── themes/                           # Raksaar dark/light themes
└── widgets/                          # Shared UI components
```

## Component Status

| Component | Status | Details |
|-----------|--------|---------|
| Bottom Navigation | ✅ | 5 tabs: Home, AI Scan, Scanner, SOS, Profile |
| GoRouter Routing | ✅ | 50+ routes, StatefulShellRoute |
| Permission System | ✅ | 8 mandatory permissions enforced |
| Auth Flow | ✅ | Login, Register, OTP, JWT, Auto-login |
| API Client | ✅ | All 15+ endpoints, timeout handling |
| Background Service | ✅ | Foreground service with MethodChannel bridge |
| Call Detection | ✅ | Native CallProtectionService (Kotlin) |
| SMS Detection | ✅ | Native SmsReceiver + SmsProtectionService |
| WhatsApp Detection | ✅ | Native AccessibilityService |
| Fraud Analysis | ✅ | Local + AI API dual analysis |
| Overlay System | ✅ | Native CallOverlayService |
| WebSocket | ✅ | Socket.IO for real-time police sync |
| Error Handling | ✅ | try/catch on all operations, 10s timeouts |

## Data Flow

```
Incoming Call/SMS/WhatsApp
    ↓
Native Android Service (Kotlin)
    ├── Local keyword/scam pattern analysis
    ├── Risk score calculation
    └── Backend API call
    ↓
Flutter via MethodChannel
    ├── BackgroundService streams events
    ├── LocalNotificationService alerts user
    ├── Overlay warning shown (high risk)
    └── WebSocket pushes to police portal
```

## Backend API Integration

| Endpoint | Method | Connected | Screen |
|----------|--------|-----------|--------|
| `/api/v1/auth/login` | POST | ✅ | Auth |
| `/api/v1/auth/register` | POST | ✅ | Auth |
| `/api/v1/auth/otp/login` | POST | ✅ | Auth OTP |
| `/api/v1/auth/otp/verify` | POST | ✅ | Auth OTP |
| `/api/v1/auth/refresh` | POST | ✅ | Background |
| `/api/v1/auth/me` | GET | ✅ | Profile |
| `/api/v1/osint/phone` | POST | ✅ | Scanner |
| `/api/v1/osint/upi` | POST | ✅ | UPI |
| `/api/v1/ai/analyze/text` | POST | ✅ | AI Analysis |
| `/api/v1/ai/analyze/sms` | POST | ✅ | SMS Protection |
| `/api/v1/ai/analyze/call` | POST | ✅ | Call Protection |
| `/api/v1/ai/analyze/whatsapp` | POST | ✅ | WhatsApp |
| `/api/v1/osint/report-fraud` | POST | ✅ | Report |
| `/api/v1/citizen/block-number` | POST | ✅ | Overlay |

## Security Architecture

- JWT tokens stored in FlutterSecureStorage + Hive (dual redundancy)
- Token refresh via `/api/v1/auth/refresh`
- Auto-login on startup
- All API calls authenticated with Bearer token
- Permission gate blocks all access until mandatory permissions granted
- Permanently denied permissions → Settings dialog + Exit App