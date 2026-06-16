# CYBERSHIELD-AI PRODUCTION URL MIGRATION & DEPLOYMENT READINESS AUDIT

**Date:** 2026-06-16  
**Audited By:** CyberShield DevOps  
**Status:** ✅ PRODUCTION READY

---

## 1. EXECUTIVE SUMMARY

Complete URL audit and migration performed across the entire CyberShield-AI repository. All hardcoded development URLs are now centralized or replaced with environment-aware configuration. The platform is ready for production deployment on AWS using:

| Service | Production URL |
|---------|---------------|
| **Backend API** | `https://api.uni6ctf.online` |
| **Citizen App** | `https://app.uni6ctf.online` |
| **Police Admin** | `https://police.uni6ctf.online` |
| **Health Check** | `https://api.uni6ctf.online/health` |

---

## 2. AUDIT RESULTS: ALL FILES CHANGED

### 2.1 Flutter Mobile App (apps/citizen-mobile)

| # | File | Line | Current URL | Recommended URL | Risk | Status |
|---|------|------|-------------|-----------------|------|--------|
| 1 | `lib/core/config/app_config.dart` | 16 | `https://admin.uni6ctf.online` | `https://police.uni6ctf.online` | HIGH | ✅ FIXED |
| 2 | `lib/core/config/app_config.dart` | 21 | `http://10.0.2.2:5000` | Development only (via env) | LOW | ✅ ACCEPTABLE |
| 3 | `lib/core/config/app_config.dart` | 22 | `http://10.0.2.2:8000` | Development only (via env) | LOW | ✅ ACCEPTABLE |
| 4 | `lib/core/config/app_config.dart` | 23 | `http://localhost:3001` | Development only (via env) | LOW | ✅ ACCEPTABLE |
| 5 | `lib/core/config/app_config.dart` | 24 | `http://localhost:3000` | Development only (via env) | LOW | ✅ ACCEPTABLE |
| 6 | `lib/core/config/app_config.dart` | 25 | `ws://10.0.2.2:5000/ws` | Development only (via env) | LOW | ✅ ACCEPTABLE |

**✅ Production build automatically uses `https://api.uni6ctf.online` for all API calls**
**✅ Production build automatically uses `wss://api.uni6ctf.online/ws` for WebSocket**
**✅ 10.0.2.2 references exist only in `_dev*` constants, never used in release builds**

### 2.2 Backend API (backend/)

| # | File | Line | Current URL | Recommended URL | Risk | Status |
|---|------|------|-------------|-----------------|------|--------|
| 7 | `shared/middlewares/security.middleware.js` | 32-37 | `http://localhost:*`, old domains | Added `https://*.uni6ctf.online` + `localhost:3001` | HIGH | ✅ FIXED |
| 8 | `shared/routes/ai.routes.js` | 15 | `http://localhost:8000` | Env-aware: prod → `https://api.uni6ctf.online` | HIGH | ✅ FIXED |
| 9 | `shared/database/redis.js` | 8 | `127.0.0.1` | Env-aware: prod → `redis` | MEDIUM | ✅ FIXED |
| 10 | `shared/services/neo4j.service.js` | 6 | `bolt://localhost:7687` | Env-aware: prod → `bolt://neo4j:7687` | MEDIUM | ✅ FIXED |
| 11 | `shared/services/neo4j-graph.service.js` | 12 | `bolt://localhost:7687` | Env-aware: prod → `bolt://neo4j:7687` | MEDIUM | ✅ FIXED |
| 12 | `services/graph-intelligence-service/FraudGraphExplorer.js` | 11 | `bolt://localhost:7687` | Env-aware: prod → `bolt://neo4j:7687` | MEDIUM | ✅ FIXED |
| 13 | `services/evidence-service/AuditTrailService.js` | 37 | `127.0.0.1` (fallback IP) | Acceptable default IP | LOW | ✅ ACCEPTABLE |
| 14 | `services/evidence-service/OfficerActionLog.js` | 39 | `127.0.0.1` (fallback IP) | Acceptable default IP | LOW | ✅ ACCEPTABLE |
| 15 | `tests/startup.test.js` | 110 | `http://localhost:${port}` | Test file - uses dynamic port | LOW | ✅ ACCEPTABLE |

### 2.3 Police Portal (portals/police-admin)

| # | File | Line | Current URL | Recommended URL | Risk | Status |
|---|------|------|-------------|-----------------|------|--------|
| 16 | `services/api.ts` | 1 | `http://localhost:8000` | `https://api.uni6ctf.online` | HIGH | ✅ FIXED |
| 17 | `next.config.js` | 6 | `'localhost'` in domains | Removed `localhost` | MEDIUM | ✅ FIXED |

### 2.4 Docker Compose Configuration

| # | File | Line | Current URL | Recommended URL | Risk | Status |
|---|------|------|-------------|-----------------|------|--------|
| 18 | `docker-compose.prod.yml` | 147 | `http://localhost:5000/api/v1` | `https://api.uni6ctf.online/api/v1` | HIGH | ✅ FIXED |
| 19 | `docker-compose.yml` | 198-220 | `http://localhost:8000` | Development only | LOW | ✅ ACCEPTABLE |
| 20 | `docker-compose.yml` | 309 | `PLAINTEXT://localhost:9092` | Kafka internal - acceptable | LOW | ✅ ACCEPTABLE |

---

## 3. NEW FILES CREATED

### 3.1 `.env.development`
```env
API_URL=http://localhost:5000
POLICE_URL=http://localhost:3001
APP_URL=http://localhost:3000
AI_GATEWAY_URL=http://localhost:8000
NEO4J_URI=bolt://localhost:7687
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
```

### 3.2 `.env.production`
```env
API_URL=https://api.uni6ctf.online
POLICE_URL=https://police.uni6ctf.online
APP_URL=https://app.uni6ctf.online
AI_GATEWAY_URL=https://api.uni6ctf.online
NEO4J_URI=bolt://neo4j:7687
REDIS_HOST=redis
REDIS_PORT=6379
```

---

## 4. REMAINING LOCALHOST REFERENCES

These are **safe** - they exist in development-only config or are acceptable defaults:

| File | Reference | Reason |
|------|-----------|--------|
| `apps/citizen-mobile/lib/core/config/app_config.dart` | `http://10.0.2.2:*` | Dev only - wrapped in `!kReleaseMode` |
| `apps/citizen-mobile/lib/core/config/app_config.dart` | `http://localhost:*` | Dev only - wrapped in `!kReleaseMode` |
| `apps/citizen-mobile/lib/core/config/app_config.dart` | `ws://10.0.2.2:5000/ws` | Dev only - wrapped in `!kReleaseMode` |
| `backend/services/evidence-service/AuditTrailService.js` | `127.0.0.1` | Default fallback IP, overridable |
| `backend/services/evidence-service/OfficerActionLog.js` | `127.0.0.1` | Default fallback IP, overridable |
| `backend/tests/startup.test.js` | `http://localhost:${port}` | Test file - dynamic port |
| `docker-compose.yml` | `http://localhost:*` | Development docker-compose |
| `docker-compose.yml` | `PLAINTEXT://localhost:9092` | Kafka internal listener |

---

## 5. DEPLOYMENT BLOCKERS

| Blocker | Status | Notes |
|---------|--------|-------|
| Hardcoded localhost in production builds | ❌ NONE | All production builds use `*.uni6ctf.online` |
| 10.0.2.2 in release APK | ❌ NONE | Only in `_dev*` constants behind `kReleaseMode` |
| CORS blocking production origins | ❌ NONE | `security.middleware.js` updated with production origins |
| Mixed content (HTTP in HTTPS) | ❌ NONE | Production URLs all HTTPS |
| Docker ports exposed | ❌ NONE | Internal services use Docker networking |

---

## 6. SECURITY ISSUES

| Issue | Status | Details |
|-------|--------|---------|
| HTTPS enforcement | ✅ DONE | All production URLs use HTTPS |
| CORS restricted origins | ✅ DONE | Only `*.uni6ctf.online` + localhost dev origins |
| No insecure HTTP endpoints | ✅ DONE | Production API uses HTTPS only |
| No mixed content | ✅ DONE | All production URLs consistent |
| No development API keys | ✅ DONE | No API keys exposed |
| No test secrets | ✅ DONE | No secrets in code |
| No emulator-only URLs in production | ✅ DONE | `10.0.2.2` only in dev constants |
| Certificate pinning | ⚠️ NOTED | `app_config.dart` has `requireCertificatePinning = true` - verify SSL certs deployed |

---

## 7. CORS ISSUES

**Backend CORS (`security.middleware.js`) now allows:**

```
http://localhost:3000        (development)
http://localhost:5000        (development)
http://localhost:8080        (development)
http://localhost:3001        (development)
https://app.uni6ctf.online   (production - citizen)
https://police.uni6ctf.online (production - police)
https://api.uni6ctf.online   (production - API)
```

**Environment-aware fallback:** `config.nodeEnv === "development"` allows all origins in dev mode.

---

## 8. API ISSUES

| API Endpoint | Production URL | Status |
|-------------|---------------|--------|
| Citizen API v1 | `https://api.uni6ctf.online/api/v1` | ✅ |
| Citizen API v2 | `https://api.uni6ctf.online/api/v2` | ✅ |
| AI Gateway | `https://api.uni6ctf.online` (or docker internal) | ✅ |
| WebSocket | `wss://api.uni6ctf.online/ws` | ✅ |
| Health Check | `https://api.uni6ctf.online/health` | ✅ |
| System Status | `https://api.uni6ctf.online/system/status` | ✅ |

---

## 9. MOBILE COMPATIBILITY ISSUES

| Android Version | localhost Dependency | Status |
|----------------|---------------------|--------|
| Android 11 (API 30) | None in release build | ✅ COMPATIBLE |
| Android 12 (API 31) | None in release build | ✅ COMPATIBLE |
| Android 13 (API 33) | None in release build | ✅ COMPATIBLE |
| Android 14 (API 34) | None in release build | ✅ COMPATIBLE |
| Android 15 (API 35) | None in release build | ✅ COMPATIBLE |

**Key Flutter configurations:**
- `kReleaseMode` switch ensures production builds use `https://api.uni6ctf.online`
- Development mode uses `10.0.2.2` (Android emulator) or `localhost` (web/iOS)
- No hardcoded IP addresses in release APK/AAB

---

## 10. ENVIRONMENT SYSTEM

| Environment File | Purpose |
|-----------------|---------|
| `.env.development` | Local development URLs (localhost) |
| `.env.production` | Production URLs (uni6ctf.online) |

**Backend services use `process.env.NODE_ENV` to auto-detect environment:**
- `NODE_ENV=production` → production URLs
- `NODE_ENV=development` or unset → development URLs

**Flutter app uses `kReleaseMode` to auto-detect:**
- `flutter build apk --release` → production URLs
- `flutter run` (debug) → development URLs

---

## 11. VERIFICATION CHECKLIST

- [x] All hardcoded URLs identified and documented
- [x] Production URLs use HTTPS exclusively
- [x] Development environment still works with localhost
- [x] CORS allows all required origins
- [x] No localhost in Flutter release builds
- [x] Docker compose production config uses correct URLs
- [x] Police portal API points to `https://api.uni6ctf.online`
- [x] Backend services environment-aware
- [x] `.env.development` and `.env.production` created
- [x] Audit report generated

---

## 12. FILES MODIFIED SUMMARY

| # | File | Change |
|---|------|--------|
| 1 | `apps/citizen-mobile/lib/core/config/app_config.dart` | Police URL: `admin.uni6ctf.online` → `police.uni6ctf.online` |
| 2 | `backend/shared/middlewares/security.middleware.js` | Added production CORS origins + localhost:3001 |
| 3 | `portals/police-admin/services/api.ts` | Default API URL: `http://localhost:8000` → `https://api.uni6ctf.online` |
| 4 | `portals/police-admin/next.config.js` | Removed `localhost` from image domains |
| 5 | `backend/shared/routes/ai.routes.js` | AI Gateway URL: env-aware production fallback |
| 6 | `backend/shared/database/redis.js` | Redis host: env-aware production fallback |
| 7 | `backend/shared/services/neo4j.service.js` | Neo4j URI: env-aware production fallback |
| 8 | `backend/shared/services/neo4j-graph.service.js` | Neo4j URI: env-aware production fallback |
| 9 | `backend/services/graph-intelligence-service/FraudGraphExplorer.js` | Neo4j URI: env-aware production fallback |
| 10 | `docker-compose.prod.yml` | Police portal API URL: production URL |
| 11 | `.env.development` | **NEW** - Development environment |
| 12 | `.env.production` | **NEW** - Production environment |
| 13 | `PRODUCTION_URL_AUDIT.md` | **NEW** - This report |

---

## 13. CONCLUSION

**All critical and high-risk URLs have been migrated.** The CyberShield-AI platform is production-ready for AWS deployment with the following domain structure:

| Domain | Purpose |
|--------|---------|
| `https://app.uni6ctf.online` | Citizen mobile/web app |
| `https://api.uni6ctf.online` | Backend API + AI Gateway |
| `https://police.uni6ctf.online` | Police admin dashboard |

**Development environment remains fully functional** with localhost URLs. The `kReleaseMode` (Flutter) and `NODE_ENV` (Node.js) switches ensure automatic environment detection.

**Next Steps for Deployment:**
1. Deploy SSL certificates for `*.uni6ctf.online`
2. Configure AWS Route53 / DNS records
3. Set up AWS ECS/EKS or EC2 with Docker Compose
4. Run `docker-compose -f docker-compose.prod.yml up -d`
5. Verify health endpoint: `https://api.uni6ctf.online/health`
6. Build Flutter release APK: `flutter build apk --release`
7. Deploy police portal: `cd portals/police-admin && npm run build`