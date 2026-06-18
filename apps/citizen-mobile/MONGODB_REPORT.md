# MONGODB INTEGRATION REPORT - CYBERSHIELD CITIZEN APP

## Collections & Data Flow

### User & Auth Collections
| Collection | CRUD | Integration | Status |
|-----------|------|-------------|--------|
| `citizens` | Create, Read | Registration, Login, Profile | ✅ |
| `device_sessions` | Create, Update | Auto-login, session management | ✅ |

### Protection Collections
| Collection | CRUD | Integration | Status |
|-----------|------|-------------|--------|
| `call_logs` | Create | CallProtectionService native call recording | ✅ |
| `sms_logs` | Create | SmsProtectionService SMS analysis | ✅ |
| `whatsapp_logs` | Create | WhatsappAccessibilityService message capture | ✅ |
| `notifications` | Create | NotificationListenerService | ✅ |

### Security Collections
| Collection | CRUD | Integration | Status |
|-----------|------|-------------|--------|
| `fraud_reports` | Create, Read | Report screen (/api/v1/osint/report-fraud) | ✅ |
| `complaints` | Create, Read | Complaint history, tracking | ✅ |
| `alerts` | Create, Read | Real-time fraud alerts via WebSocket | ✅ |

### AI Collections
| Collection | CRUD | Integration | Status |
|-----------|------|-------------|--------|
| `ai_predictions` | Create | AI analysis results (text, SMS, call, WhatsApp) | ✅ |
| `voice_analysis` | Create | In-call voice deepfake detection | ✅ |
| `deepfake_results` | Create | Media deepfake analysis | ✅ |

### Emergency Collections
| Collection | CRUD | Integration | Status |
|-----------|------|-------------|--------|
| `sos_events` | Create | Emergency SOS with GPS location | ✅ |

## Data Flow Model

```
Citizen App
    ↓ REST API (https://api.uni6ctf.online)
Backend (Node.js)
    ↓ Mongoose ODM
MongoDB Atlas
    ↓ Change Streams
WebSocket (Socket.IO)
    ↓
Police Portal (real-time updates)
```

## Write Strategy
- All writes go through `/api/v1/*` REST endpoints on live backend
- No direct MongoDB access from mobile app (security best practice)
- Native services (CallProtectionService, SmsProtectionService) also use REST API
- WebSocket events are one-way from app → backend → police portal

## Data Security
- JWT authentication on all data access
- Data encrypted in transit (HTTPS)
- Backend handles all authorization
- No sensitive data stored locally (except JWT tokens in FlutterSecureStorage)