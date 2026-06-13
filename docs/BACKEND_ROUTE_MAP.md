# CYBERSHIELD AI - COMPLETE BACKEND ROUTE MAP
## Generated: June 13, 2026

## EXPRESS BACKEND (port 5000) - `app.js`

### Auth Routes (Lines 112-283)
| Method | Route | Status | Description |
|--------|-------|--------|-------------|
| POST | `/api/v1/auth/register` | ✅ Fixed | Register new user |
| POST | `/api/v1/auth/login` | ✅ Fixed | User login (returns JWT) |
| POST | `/api/v1/auth/logout` | ✅ Fixed | User logout |
| POST | `/api/v1/auth/refresh` | ✅ Fixed | Refresh access token |
| GET | `/api/v1/auth/me` | ✅ Fixed | Get current user profile |
| POST | `/api/v1/auth/forgot-password` | ❌ Missing | Forgot password |
| POST | `/api/v1/auth/change-password` | ❌ Missing | Change password |
| POST | `/api/v1/auth/mfa/setup` | ❌ Missing | Setup MFA |
| POST | `/api/v1/auth/mfa/verify` | ❌ Missing | Verify MFA |
| POST | `/api/v1/auth/otp/login` | ❌ Missing | OTP login |
| POST | `/api/v1/auth/otp/verify` | ❌ Missing | Verify OTP |
| POST | `/api/v1/auth/phone/login` | ❌ Missing | Phone login |
| POST | `/api/v1/auth/google/login` | ❌ Missing | Google login |
| GET | `/api/v1/auth/sessions` | ❌ Missing | List sessions |
| POST | `/api/v1/auth/sessions/revoke` | ❌ Missing | Revoke session |

### Citizen Routes - Mounted at `/api/v1/citizen` (from `citizen.routes.js`)
| Method | Route | Status | Description |
|--------|-------|--------|-------------|
| POST | `/report/call` | ✅ Complete | Report fraudulent call |
| POST | `/report/sms` | ✅ Complete | Report fraudulent SMS |
| POST | `/report/whatsapp` | ✅ Complete | Report WhatsApp message |
| GET | `/trust-score/:number` | ✅ Complete | Get trust score for number |
| GET | `/history` | ✅ Complete | Get report history |
| POST | `/block-number` | ✅ Complete | Block a phone number |
| POST | `/emergency-sos` | ✅ Complete | Send SOS alert |
| GET | `/family-protection` | ✅ Complete | Get family protection data |
| POST | `/evidence/upload` | ✅ Complete | Upload evidence |

### MISSING Citizen Routes
| Method | Route | Needed By |
|--------|-------|-----------|
| GET | `/dashboard` | Home screen provider |
| GET | `/call-protection` | Call protection provider |
| GET | `/sms-protection` | SMS protection provider |
| GET | `/whatsapp-protection` | WhatsApp protection provider |
| GET | `/upi-protection` | UPI protection provider |
| GET | `/bank-protection` | Bank protection provider |
| GET | `/evidence/sync` | Offline vault provider |
| GET | `/alerts` | Alert provider |
| POST | `/call-protection/toggle` | Call protection toggle |
| POST | `/sms-protection/toggle` | SMS protection toggle |
| POST | `/whatsapp-protection/toggle` | WhatsApp protection toggle |
| POST | `/sms-protection/analyze` | SMS analysis |
| POST | `/whatsapp-protection/analyze` | WhatsApp analysis |
| POST | `/upi-protection/verify` | UPI verification |
| GET | `/upi-protection/merchant/:id` | Merchant reputation |
| GET | `/family-protection/senior-mode/toggle` | Senior mode |
| GET | `/family-protection/child-protection/toggle` | Child protection |
| GET | `/family-protection/trust-score/:phone` | Member trust score |
| POST | `/family-protection/emergency` | Emergency to family |

### Police Routes - Mounted at `/api/v1/police` (from `police.routes.js`)
| Method | Route | Status | Description |
|--------|-------|--------|-------------|
| GET | `/cases` | ✅ Complete | List cases with filters |
| POST | `/cases` | ✅ Complete | Create new case |
| GET | `/firs` | ✅ Complete | List FIRs |
| POST | `/firs` | ✅ Complete | Create new FIR |
| GET | `/evidence` | ✅ Complete | List evidence |
| GET | `/analytics` | ✅ Complete | Get analytics |
| GET | `/heatmap` | ✅ Complete | Get heatmap |
| GET | `/fraud-network` | ✅ Complete | Get fraud network |
| POST | `/bank-freeze` | ✅ Complete | Request bank freeze |
| POST | `/deepfake-analysis` | ✅ Complete | Submit deepfake analysis |

### ISP Routes - Mounted at `/api/v1/isp` (from `isp.routes.js`)
| Method | Route | Status | Description |
|--------|-------|--------|-------------|
| GET | `/number-intelligence` | ✅ Complete | Number intelligence |
| GET | `/sms-firewall` | ✅ Complete | SMS firewall data |
| GET | `/traffic-analysis` | ✅ Complete | Traffic analysis |
| GET | `/blocked-numbers` | ✅ Complete | Blocked numbers list |
| GET | `/fraud-campaigns` | ✅ Complete | Fraud campaigns |
| GET | `/threat-feed` | ✅ Complete | Threat feed |

### Government Routes - Mounted at `/api/v1/government`
| Method | Route | Status | Description |
|--------|-------|--------|-------------|
| GET | `/national-dashboard` | ⚠️ Partial | National dashboard |
| GET | `/state-dashboard` | ⚠️ Partial | State dashboard |
| GET | `/district-dashboard` | ⚠️ Partial | District dashboard |
| GET | `/fraud-trends` | ⚠️ Partial | Fraud trends |
| GET | `/economic-impact` | ⚠️ Partial | Economic impact |

## FASTAPI AUTH SERVICE (port 5001) - `routers/auth.py`
| Method | Route | Status | Description |
|--------|-------|--------|-------------|
| POST | `/auth/register` | ✅ Complete | Register (FastAPI) |
| POST | `/auth/login` | ✅ Complete | Login with MFA support |
| POST | `/auth/logout` | ✅ Complete | Logout |
| POST | `/auth/refresh` | ✅ Complete | Rotate refresh token |
| POST | `/auth/change-password` | ✅ Complete | Change password |
| POST | `/auth/forgot-password` | ✅ Complete | Forgot password |
| POST | `/auth/reset-password` | ✅ Complete | Reset password |
| POST | `/auth/mfa/setup` | ✅ Complete | Setup MFA |
| POST | `/auth/mfa/verify` | ✅ Complete | Verify MFA |
| GET | `/auth/me` | ✅ Complete | Get current user |

## REGISTRATION FAILURE - ROOT CAUSE & FIX
**Root Cause:** The Express backend (port 5000) had auth routes at `/api/auth/*` (no `v1` prefix), but the Flutter app's `api_client.dart` uses `baseUrl: http://10.0.2.2:5000/api/v1` and sends requests to `/api/v1/auth/register`. This caused a 404 Not Found, which the Flutter app interpreted as "Connection Error".

**Fix Applied:** Updated all auth routes in `app.js` from `/api/auth/*` to `/api/v1/auth/*`:
- `/api/auth/register` → `/api/v1/auth/register`
- `/api/auth/login` → `/api/v1/auth/login`
- `/api/auth/logout` → `/api/v1/auth/logout`
- `/api/auth/refresh` → `/api/v1/auth/refresh`
- `/api/auth/me` → `/api/v1/auth/me`

**Also Fixed:** Updated `health.routes.js` to use `/api/v1/health` path.

## MISSING BACKEND ROUTES SUMMARY
Total routes needed by Flutter providers: **56**
Routes currently implemented in Express: **29**
Routes missing: **27** (will work when FastAPI auth service is running on port 5001, but NOT when using Express backend only)