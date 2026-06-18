# POLICE PORTAL SYNC REPORT - CYBERSHIELD CITIZEN APP

## Real-Time Sync Architecture

```
Citizen App → WebSocket (Socket.IO) → Backend → Police Portal Dashboard
     ↓                                          ↓
  REST API (HTTPS)                         MongoDB Change Streams
     ↓                                          ↓
  MongoDB Collections                     Real-time UI Updates
```

## Sync Events

### Fraud Reports
| Trigger | Source | Police Portal Destination | Status |
|---------|--------|--------------------------|--------|
| User files report | ReportFraudScreen | Investigation Queue | ✅ |
| AI detects fraud | AI Analysis Screen | Threat Intelligence | ✅ |
| Call protection alert | CallProtectionService | Live Alerts Tab | ✅ |

### SOS Events
| Trigger | Source | Police Portal Destination | Status |
|---------|--------|--------------------------|--------|
| User presses SOS | EmergencySosScreen | Emergency Dashboard | ✅ |
| GPS coordinates sent | SOS with location | Map View | ✅ |
| Trusted contacts notified | Emergency contacts | Case File | ✅ |

### High Risk Calls
| Trigger | Source | Police Portal Destination | Status |
|---------|--------|--------------------------|--------|
| Trust score < 30 | CallProtectionService | Threat Intelligence | ✅ |
| Scam keywords detected | LiveCallAnalyzer | Investigation Queue | ✅ |
| Multiple complaints | Fraud Database | Analytics Dashboard | ✅ |

### High Risk SMS
| Trigger | Source | Police Portal Destination | Status |
|---------|--------|--------------------------|--------|
| Fraud keywords match | SmsProtectionService | Threat Intelligence | ✅ |
| Phishing URL detected | LinkScannerScreen | Investigation Queue | ✅ |
| Known scam pattern | AI analysis | Analytics Dashboard | ✅ |

### WhatsApp Analysis
| Trigger | Source | Police Portal Destination | Status |
|---------|--------|--------------------------|--------|
| Suspicious message | WhatsappAccessibilityService | Threat Intelligence | ✅ |
| Fraud link in message | NotificationListener | Investigation Queue | ✅ |

### AI Analysis Results
| Trigger | Source | Police Portal Destination | Status |
|---------|--------|--------------------------|--------|
| Text analysis | AiInvestigatorScreen | Analytics Dashboard | ✅ |
| Call analysis | CallProtectionScreen | Threat Intelligence | ✅ |
| Deepfake detection | DeepfakeDetectionScreen | Cyber Forensics | ✅ |

## WebSocket Events Table
| Event | Payload | Frequency | Police Use |
|-------|---------|-----------|------------|
| `fraud:report` | type, riskScore, phoneNumber, location | On detection | Case creation |
| `sos:triggered` | latitude, longitude, contacts | On SOS | Dispatch resources |
| `analysis:complete` | full analysis JSON | On AI completion | Evidence collection |
| `case:status` | caseId, status, officerId | From police | Citizen notification |
| `fraud_alert` | title, message, severity | Broadcast | Mass alerts |

## MongoDB Collections Synced to Police Portal
| Collection | Sync Method | Update Frequency | Status |
|-----------|-------------|-----------------|--------|
| `fraud_reports` | REST + WebSocket | Real-time | ✅ |
| `complaints` | REST + WebSocket | Real-time | ✅ |
| `sos_events` | WebSocket | On trigger | ✅ |
| `ai_predictions` | REST | On analysis | ✅ |
| `call_logs` | REST | On call end | ✅ |
| `alerts` | WebSocket | Broadcast | ✅ |

## Sync Verification Points
- [x] Citizen files report → Police dashboard shows it immediately
- [x] SOS trigger → Police dispatcher receives GPS + contacts
- [x] High risk call detected → Threat intel updated
- [x] AI analysis complete → Evidence stored in MongoDB
- [x] Deepfake alert → Cyber forensics notified
- [x] Fraud SMS detected → Investigation queue updated