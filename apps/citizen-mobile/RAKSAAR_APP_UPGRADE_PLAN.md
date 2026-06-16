# RAKSAAR Citizen Mobile App — Production-Grade Upgrade Plan
## apps/citizen-mobile

---

## CURRENT STATE
✅ 40+ screens, 15 providers, services, background detection, AI integration
🔄 Needs: Material 3, dark/AMOLED mode, permission gating, real-time sync, government DPDP compliance

---

## ARCHITECTURE

```
lib/
├── main.dart                   ← App entry + permission gate + theme init
├── app.dart                    ← MaterialApp.router with theme switching
│
├── core/
│   ├── app_constants.dart      ← API URLs, feature flags
│   ├── raksaar_theme.dart      ← Material 3: Light/Dark/AMOLED [✓ CREATED]
│   ├── permission_manager.dart ← Government-grade permission system [✓ CREATED]
│   └── websocket_service.dart  ← Real-time citizen↔police sync
│
├── themes/
│   └── raksaar_theme.dart      ← Theme definitions
│
├── models/                     ← Dataclasses matching backend
│   ├── user_model.dart
│   ├── fraud_case.dart
│   ├── risk_score.dart
│   ├── evidence_item.dart
│   ├── sos_alert.dart
│   ├── family_member.dart
│   └── trust_score.dart
│
├── repositories/               ← Data layer (API calls, caching)
│   ├── auth_repository.dart
│   ├── fraud_repository.dart
│   ├── protection_repository.dart
│   ├── evidence_repository.dart
│   ├── family_repository.dart
│   └── trust_score_repository.dart
│
├── providers/                  ← Riverpod state management
│   ├── auth_provider.dart
│   ├── protection_provider.dart
│   ├── dashboard_provider.dart
│   ├── websocket_provider.dart
│   ├── alarm_provider.dart
│   └── permission_provider.dart
│
├── screens/
│   ├── splash/
│   ├── onboarding/             ← 3-pages with permission requests
│   ├── permissions/            ← Permission gate screen
│   ├── auth/                   ← Login/Register/OTP
│   ├── home/                   ← Smart Dashboard (risk score, protections, alerts)
│   ├── protection/
│   │   ├── call/               ← Call analysis, live protection
│   │   ├── sms/                ← SMS scam detection
│   │   ├── whatsapp/           ← WhatsApp analysis
│   │   ├── upi/                ← UPI fraud detection
│   │   └── deepfake/           ← Voice/video deepfake detection
│   ├── sos/                    ← Emergency SOS + location sharing
│   ├── family/                 ← Family protection dashboard
│   ├── women/                  ← Women safety module
│   ├── evidence/               ← Encrypted evidence vault
│   ├── trust_score/            ← Digital trust score
│   ├── training/               ← Scam awareness academy (gamified)
│   ├── settings/               ← Profile, theme, permissions, DPDP
│   └── report/                 ← Fraud reporting + history
│
└── widgets/
    ├── risk_badge.dart
    ├── protection_tile.dart
    ├── dashboard_card.dart
    ├── shimmer_loading.dart
    ├── cyber_chart.dart
    └── sos_button.dart
```

---

## PHASE 1: UI/UX MODERNIZATION ✅ DONE
- Material 3 theme with Light/Dark/AMOLED modes ✓
- Government-grade permission manager with rationale dialogs ✓

## PHASE 1a: THEME PROVIDER & APP WRAPPER
**Files to create:**
- `lib/core/theme_provider.dart` ← Riverpod provider for theme mode

**Implementation:**
```dart
// Theme state provider
enum ThemeModeOption { light, dark, amoled, system }

class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  ThemeNotifier() : super(ThemeModeOption.system);
  
  void setTheme(ThemeModeOption mode) {
    state = mode;
    // Persist to Hive
  }
}
```

## PHASE 1b: MAIN.DART WITH PERMISSION GATE
**Update:** `lib/main.dart`

**Flow:**
1. Initialize Hive, notifications, Firebase
2. Check permissions via `RaksaarPermissionManager`
3. If permissions not granted → show permission gate
4. If permissions granted → check auth token
5. If not logged in → show login/register
6. If logged in → show home dashboard

## PHASE 2: SMART HOME DASHBOARD
**New file:** `lib/screens/home/home_dashboard.dart`

**Sections:**
1. **Risk Score Card** — Circular gauge showing 0-100 score with color (green/yellow/red/black)
2. **Protection Status** — 5 protection cards (Call, SMS, WhatsApp, UPI, Deepfake) with on/off toggle
3. **Recent Threats** — Timeline of blocked scam attempts
4. **Quick Actions** — SOS, Report, Family, Scan
5. **AI Tip** — Daily scam awareness tip

**API Integration:**
- `GET /api/v1/protection/status` → Protection toggles
- `GET /api/v1/analytics/threats` → Recent threats
- `GET /api/v1/ai/tip` → Daily tip

## PHASE 3: REAL-TIME PROTECTION ENGINE
**Files to modify:** Call detection, SMS monitoring, WhatsApp, UPI

**Integration:**
- `WebSocket` → `ws://localhost:5000/ws`
- Events: `fraud_detected`, `call_risk_update`, `sms_alert`

**Call Protection Flow:**
```
Incoming Call
  → Native CallDetectionService (Java)
  → Platform Channel → Flutter
  → GET /api/v1/ai/analyze/call?number=X
  → Display overlay warning
  → WebSocket: emit "fraud:report"
```

## PHASE 4: FAMILY SAFETY MODULE
**New file:** `lib/screens/family/family_dashboard.dart`

**Features:**
- Invite family members via SMS/WhatsApp
- View protection status of each member
- Receive alerts when family member gets scam call
- Senior citizen mode: larger text, simplified UI
- Child mode: stricter scam filtering

**API:** `GET /api/v1/family/members`, `POST /api/v1/family/invite`

## PHASE 5: WOMEN SAFETY MODULE
**New file:** `lib/screens/women/safety_center.dart`

**Features:**
- Silent SOS: shake phone to trigger
- Live location sharing with trusted contacts
- Fake call generator (escape unsafe situations)
- Safe route suggestions based on scam heatmap
- Audio recording trigger (records 60s before/after SOS)

**API:** `POST /api/v1/women/sos`, `GET /api/v1/women/safe_routes`

## PHASE 6: AI COPILOT
**New file:** `lib/screens/ai/ai_copilot.dart`

**Features:**
- Chat interface with AI assistant
- Screenshot analysis: user uploads scam message screenshot → AI reads + explains
- Link scanner: paste URL → AI checks safety
- Voice analysis: upload scam call recording → AI explains

**API:** `POST /api/v1/ai/analyze/screenshot`, `POST /api/v1/ai/analyze/url`

## PHASE 7: DIGITAL TRUST SCORE
**New file:** `lib/screens/trust_score/lookup_screen.dart`

**Searchable database:**
- Phone number trust score
- UPI ID trust score
- Website trust score
- WhatsApp account score

**API:** `GET /api/v1/trust-score/phone/{number}`

## PHASE 8: EVIDENCE VAULT (ENCRYPTED)
**Update:** `lib/screens/evidence/evidence_vault.dart`

**Features:**
- AES-256-GCM encryption
- Hash chain verification (SHA-256)
- Export as legal evidence package
- Cloud backup + offline access
- Auto-capture from scam detection

**API:** `POST /api/evidence/upload`, `GET /api/evidence`

## PHASE 9: SCAM AWARENESS ACADEMY
**New file:** `lib/screens/training/academy_home.dart`

**Gamification:**
- Daily quiz (5 questions)
- Simulated scam calls (audio + analysis)
- Phishing SMS challenge
- Cyber badges (Bronze/Silver/Gold/Platinum)
- Leaderboard (anonymous)

## PHASE 10: BACKEND INTEGRATION (NO MOCK DATA)
**All providers must connect to real endpoints:**

| Screen | Endpoint | Method |
|--------|----------|--------|
| Login | `/api/v1/auth/login` | POST |
| Register | `/api/v1/auth/register` | POST |
| Dashboard Stats | `/api/v1/citizen/dashboard` | GET |
| Call Analysis | `/api/v1/ai/analyze/call` | POST |
| SMS Analysis | `/api/v1/ai/analyze/sms` | POST |
| WhatsApp | `/api/v1/ai/analyze/whatsapp` | POST |
| Fraud Report | `/api/v1/citizen/reports` | POST |
| Evidence | `/api/evidence/upload` | POST |
| Family | `/api/v1/citizen/family` | GET |
| Trust Score | `/api/v1/osint/phone` | POST |
| SOS | `/api/v1/citizen/sos` | POST |

## PHASE 11: WEBSOCKET REALTIME SYNC
**New file:** `lib/services/websocket_service.dart`

**Events:**
```dart
// Citizen → Backend
socket.emit('fraud:report', { caseId, type, risk });
socket.emit('sos:triggered', { lat, lng, contacts });
socket.emit('join:citizen', userId);

// Police → Citizen (via Backend)
socket.on('case:status', (data) => showNotification(data));
socket.on('case:assigned', (data) => showUpdate(data));
socket.on('investigation:update', (data) => { /* UI update */ });
```

## PHASE 12: PERFORMANCE OPTIMIZATION
- Code splitting (deferred imports for heavy screens)
- Image caching (cached_network_image)
- Lazy loading (ListView.builder everywhere)
- Background isolate for AI analysis
- Hive for offline-first caching
- APK size target: < 80MB

## PHASE 13: APP STORE READINESS
- Privacy policy (DPDP 2023 compliant)
- Terms of service
- App icons (adaptive Android)
- Splash screen
- Play Store screenshots (7.6" / 12.9" tablets)
- Release signing configuration
- App description: Hindi + English

---

## MILESTONE PLAN

| Milestone | Phase | Effort | Priority |
|-----------|-------|--------|----------|
| M1: Foundation | P1 | 2 days | 🔴 CRITICAL |
| M2: Dashboard | P2 | 1 day | 🔴 CRITICAL |
| M3: Permission Gate | P1a | 1 day | 🔴 CRITICAL |
| M4: Backend Connect | P10 | 2 days | 🔴 CRITICAL |
| M5: Call Protection | P3 | 2 days | 🟡 HIGH |
| M6: WebSocket | P11 | 1 day | 🟡 HIGH |
| M7: Evidence Vault | P8 | 1 day | 🟡 HIGH |
| M8: Family + Women | P4+P5 | 2 days | 🟢 MEDIUM |
| M9: AI Copilot | P6 | 2 days | 🟢 MEDIUM |
| M10: Trust Score | P7 | 1 day | 🟢 MEDIUM |
| M11: Academy | P9 | 1 day | 🔵 LATER |
| M12: Store Ready | P13 | 1 day | 🔵 LATER |

**Total effort:** ~18 days for full production upgrade

---

## IMMEDIATE NEXT STEPS (Priority)

1. ✅ Create `raksaar_theme.dart` — DONE
2. ✅ Create `permission_manager.dart` — DONE
3. ⬜ Update `main.dart` with permission gate + theme provider
4. ⬜ Update `app.dart` with Material 3 theming
5. ⬜ Create permission onboarding screen
6. ⬜ Create smart home dashboard
7. ⬜ Implement websocket_service.dart
8. ⬜ Connect all screens to real backend APIs