# API INTEGRATION REPORT - CYBERSHIELD CITIZEN APP

## Backend: https://api.uni6ctf.online

### Authentication APIs (auth_provider.dart + api_client.dart)
| Endpoint | Method | Status | Response | Storage |
|----------|--------|--------|----------|---------|
| `/api/v1/auth/register` | POST | ✅ | JWT token | FlutterSecureStorage + Hive |
| `/api/v1/auth/login` | POST | ✅ | JWT token | FlutterSecureStorage + Hive |
| `/api/v1/auth/otp/login` | POST | ✅ | OTP sent | In-memory |
| `/api/v1/auth/otp/verify` | POST | ✅ | JWT token | FlutterSecureStorage + Hive |
| `/api/v1/auth/refresh` | POST | ✅ | New JWT | FlutterSecureStorage + Hive |
| `/api/v1/auth/me` | GET | ✅ | User profile | Hive |
| `/api/v1/auth/logout` | POST | ✅ | Success | Clears storage |

### OSINT Intelligence APIs (scanner, UPI, phone screens)
| Endpoint | Method | Status | Input | Output |
|----------|--------|--------|-------|--------|
| `/api/v1/osint/phone` | POST | ✅ | phone_number | trust_score, risk_category, reports |
| `/api/v1/osint/upi` | POST | ✅ | upi_id | score, risk_level, merchant_info |

### AI Analysis APIs (AI screens)
| Endpoint | Method | Status | Input | Output |
|----------|--------|--------|-------|--------|
| `/api/v1/ai/analyze/text` | POST | ✅ | text | primary_scam_type, risk_score, keywords_found |
| `/api/v1/ai/analyze/sms` | POST | ✅ | text, sender | risk_score, scam_type, verdict |
| `/api/v1/ai/analyze/call` | POST | ✅ | phone_number, audio_path | risk_score, call_transcript, analysis |
| `/api/v1/ai/analyze/whatsapp` | POST | ✅ | text, sender | risk_score, fraud_probability |

### Citizen APIs (reporting, blocking)
| Endpoint | Method | Status | Input | Output |
|----------|--------|--------|-------|--------|
| `/api/v1/osint/report-fraud` | POST | ✅ | report details | tracking_id, success |
| `/api/v1/citizen/block-number` | POST | ✅ | phone_number | success |

### Native Service APIs (Kotlin → Flutter via MethodChannel)
| Channel | Method | Status | Purpose |
|---------|--------|--------|---------|
| `com.cybershield/protection` | startCallMonitoring | ✅ | Start 24/7 call detection |
| `com.cybershield/protection` | stopCallMonitoring | ✅ | Stop call detection |
| `com.cybershield/protection` | startSmsMonitoring | ✅ | Start SMS analysis |
| `com.cybershield/protection` | stopSmsMonitoring | ✅ | Stop SMS analysis |
| `com.cybershield/protection` | startWhatsappMonitoring | ✅ | Start WhatsApp monitoring |
| `com.cybershield/protection` | stopWhatsappMonitoring | ✅ | Stop WhatsApp monitoring |
| `com.cybershield/protection` | startForegroundService | ✅ | Persistent 24/7 service |
| `com.cybershield/protection` | stopForegroundService | ✅ | Stop foreground service |
| `com.cybershield/call_protection` | onCallEvent | ✅ | Incoming call events to Flutter |
| `com.cybershield/overlay` | showWarning | ✅ | Fraud warning overlay |
| `com.cybershield/overlay` | dismissOverlay | ✅ | Close overlay |
| `com.cybershield/overlay` | blockNumber | ✅ | Block from overlay |
| `com.cybershield/overlay` | reportFraud | ✅ | Report from overlay |

### WebSocket API (real-time police sync)
| Event | Direction | Status | Purpose |
|-------|-----------|--------|---------|
| `join:citizen` | Flutter → Server | ✅ | Authenticate WebSocket |
| `fraud:report` | Flutter → Server | ✅ | Push fraud detection to police |
| `sos:triggered` | Flutter → Server | ✅ | Emergency SOS with GPS |
| `analysis:complete` | Flutter → Server | ✅ | AI analysis results to police |
| `case:status` | Server → Flutter | ✅ | Police case updates |
| `fraud_alert` | Server → Flutter | ✅ | Real-time fraud alerts |

### Total APIs Connected: 15 REST endpoints + 5 MethodChannels + 6 WebSocket events = 26 integrations