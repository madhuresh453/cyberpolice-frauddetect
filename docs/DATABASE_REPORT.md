# Database Report — MongoDB Atlas

## Connection

| Property | Value |
|---|---|
| Database | `cyber-police` |
| Status | ✅ **Online** |
| Environment | development |

## Collection Inventory

| # | Collection | Documents | Exists | Indexes |
|---|---|---|---|---|
| 1 | `admin_users` | 1 | ✅ | default (`_id`) |
| 2 | `users` | 3 | ✅ | `email`, `phoneNumber`, `role`, `status` |
| 3 | `citizens` | 1 | ✅ | default |
| 4 | `police_officers` | 1 | ✅ | default |
| 5 | `fir_reports` | 1 | ✅ | default |
| 6 | `complaints` | 1 | ✅ | default |
| 7 | `calls` | 1 | ✅ | default |
| 8 | `call_recordings` | 0 | ✅ | default |
| 9 | `ai_predictions` | 1 | ✅ | default |
| 10 | `scam_alerts` | 1 | ✅ | default |
| 11 | `locations` | 0 | ✅ | default |
| 12 | `device_tokens` | 0 | ✅ | default |
| 13 | `fraud_patterns` | 0 | ✅ | default |
| 14 | `audit_logs` | 0 | ✅ | default |
| 15 | `notifications` | 0 | ✅ | default |
| 16 | `blocklist_numbers` | 0 | ✅ | default |
| 17 | `whitelist_numbers` | 0 | ✅ | default |
| 18 | `voiceprints` | 0 | ✅ | default |
| 19 | `isp_reports` | 0 | ✅ | default |
| 20 | `cyberpolice-db` | 0 | ⚠️ | Orphan collection |

## Validation Notes

### Issues Found

1. **Orphan Collection**: `cyberpolice-db` exists in the database but has no corresponding Mongoose model. This is likely a legacy artifact.

2. **Missing Collections**: The Beanie ODM document models (Phase 3 MongoDB migration) define these additional collections that do not exist in the Mongoose-managed database:
   - `roles` — Not yet created in Mongoose
   - `permissions` — Not yet created in Mongoose
   - `sessions` — Not yet created in Mongoose
   - `api_keys` — Not yet created in Mongoose
   - `fraud_reports` — Not yet created in Mongoose
   - `call_analysis` — Not yet created in Mongoose
   - `sms_analysis` — Not yet created in Mongoose
   - `whatsapp_analysis` — Not yet created in Mongoose
   - `upi_analysis` — Not yet created in Mongoose
   - `evidence` — Not yet created in Mongoose
   - `cases` — Not yet created in Mongoose
   - `threat_intelligence` — Not yet created in Mongoose
   - `fraud_campaigns` — Not yet created in Mongoose
   - `digital_trust_scores` — Not yet created in Mongoose

   These collections will be auto-created by Beanie when the FastAPI auth-service initializes, as they are registered in the `DOCUMENT_MODELS` list in `backend/shared/database/documents.py`.

3. **Dual Database Access**: The Express backend uses Mongoose to access MongoDB, while the auth-service uses Motor/Beanie. Both operate on the same database (`cyber-police`) but use different ODM layers. This is by design for Phase 3+.

## Mongoose Models vs Collections

| Mongoose Model | Collection | Created |
|---|---|---|
| `User` | `users` | ✅ |
| `Citizen` | `citizens` | ✅ |
| `PoliceOfficer` | `police_officers` | ✅ |
| `AdminUser` | `admin_users` | ✅ |
| `AuditLog` | `audit_logs` | ✅ |
| `Notification` | `notifications` | ✅ |
| `Call` | `calls` | ✅ |
| `CallRecording` | `call_recordings` | ✅ |
| `Complaint` | `complaints` | ✅ |
| `FIRReport` | `fir_reports` | ✅ |
| `FraudPattern` | `fraud_patterns` | ✅ |
| `ISPReport` | `isp_reports` | ✅ |
| `Location` | `locations` | ✅ |
| `DeviceToken` | `device_tokens` | ✅ |
| `BlocklistNumber` | `blocklist_numbers` | ✅ |
| `WhitelistNumber` | `whitelist_numbers` | ✅ |
| `ScamAlert` | `scam_alerts` | ✅ |
| `AIPrediction` | `ai_predictions` | ✅ |
| `Voiceprint` | `voiceprints` | ✅ |

## Recommendations

1. **Drop orphan collection**: Remove `cyberpolice-db` from the database.
2. **Add remaining models**: Create Mongoose models for `roles`, `permissions`, `sessions`, `api_keys`, `fraud_reports`, `cases`, `evidence`, and threat intelligence collections to match the Phase 3 MongoDB document models.
3. **Sync indexes**: Ensure Mongoose indexes match the Beanie ODM indexes defined in `documents.py`.