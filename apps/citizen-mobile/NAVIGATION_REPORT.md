# NAVIGATION SYSTEM REPORT - CYBERSHIELD CITIZEN APP

## Architecture: GoRouter + StatefulShellRoute

### Auth Routes (NO bottom navigation)
| Route | Screen | Purpose |
|-------|--------|---------|
| `/splash` | SplashScreen | App launch, permission check |
| `/permissions` | PermissionsScreen | Permission gate (blocks all access) |
| `/auth`, `/login`, `/register`, `/otp` | AuthScreen | Authentication |
| `/onboarding`, `/onboarding/1-3` | OnboardingScreen | First-time user flow |

### Main App Shell (WITH persistent bottom navigation)
**5 Tabs using StatefulShellRoute.indexedStack:**

| Tab | Route | Screen | Sub-routes |
|-----|-------|--------|------------|
| 0: Home | `/home` | `RaksaarHomeDashboard` | protection, intelligence, safety, dashboard |
| 1: AI Scan | `/ai-scan` | `AiInvestigatorTabScreen` | copilot, investigator |
| 2: Scanner | `/scanner` | `AiInvestigatorTabScreen` | link, qr, deepfake |
| 3: SOS | `/sos-tab` | `SafetyTabScreen` | sos, emergency |
| 4: Profile | `/profile` | `ProfileSettingsScreen` | settings, vault, notifications, permission-center, senior, help |

### Feature Routes (Push on top, bottom nav still visible)
All feature routes use `parentNavigatorKey: _rootNavigatorKey` so they push full-screen but remain within the navigator hierarchy.

| Category | Routes |
|----------|--------|
| Call | `/call/incoming`, `/call/analysis`, `/call/high-risk`, `/call/medium-risk`, `/call/safe`, `/call/live-protection`, `/call/summary`, `/call/evidence`, `/call-detection`, `/call-protection`, `/live-call`, `/live-call-analysis` |
| SMS | `/sms`, `/sms/scam-result`, `/sms-detection` |
| WhatsApp | `/whatsapp`, `/whatsapp/call`, `/whatsapp-analysis` |
| UPI | `/upi`, `/upi-verification` |
| Screen/Remote | `/screen-sharing`, `/remote-access` |
| APK/Link | `/fake-apk` |
| Intelligence | `/heatmap`, `/digital-trust`, `/trust-score`, `/fraud-map` |
| Family | `/family`, `/family-dashboard` |
| Training | `/training`, `/cyber-education` |
| Reports | `/report`, `/report/success`, `/report-submitted`, `/report/history`, `/complaint-history` |
| Bank | `/bank-protection` |
| Monitor | `/monitor` |
| Alerts | `/live-alerts` |
| Phone Verify | `/phone-verification` |

### Key Fixes Applied
1. **Bottom nav restored**: `StatefulShellRoute.indexedStack` with `AppShell` wrapping all 5 tabs
2. **State preserved**: IndexedStack per branch keeps tab state alive
3. **No navigation loops**: Feature routes don't double-wrap in shell
4. **Deep linking**: All routes have unique names for deep link support
5. **Error handling**: Custom error builder with "Go Home" button
6. **Fallback route**: `/` catches all unknown paths → redirects to splash
7. **Auth isolation**: Login/register/splash have NO bottom nav (correct behavior)

### Verification
- [x] Bottom navigation visible on Home, AI Scan, Scanner, SOS, Profile tabs
- [x] Bottom navigation HIDDEN on splash, auth, permissions, onboarding
- [x] Feature screens push with back button, bottom nav visible
- [x] Tab state preserved when switching
- [x] No route-not-found errors
- [x] No blank screens
- [x] All 50+ routes defined
- [x] All navigations use `context.go()` or `context.push()` with GoRouter