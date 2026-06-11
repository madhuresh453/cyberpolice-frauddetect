# CYBERSHIELD AI — BUILD FIX REPORT

Generated: 2026-06-11

---

## Files Modified

|1. `lib/utils/constants.dart`
   - Added `ApiEndpoints.logout` — was missing, causing auth_repository compile error

2. `lib/screens/home_mobile/screens/home_screen.dart`
   - Fixed `report.fraudType` nullable — now uses `report.fraudType ?? report.type`
   - Fixed `report.description` nullable — now uses `report.description ?? ''`

3. `lib/screens/qr_scanner_screen.dart`
   - Removed `AppTheme.primaryBlue.withOpacity(0.5)` from const context — replaced with `AppTheme.primaryBlue`
   - Method calls can't be inside const widgets

4. `lib/screens/live_alerts_screen.dart`
   - Fixed invalid icon: `Icons.whatsapp` → `Icons.chat`

5. `lib/screens/sms_protection_screen.dart`
   - Added `BuildContext context` parameter to `_buildSmsItem()` method — was missing context parameter
   - Updated all call sites to pass context

---

## Files Created

1. `lib/services/local_notification_service.dart`
   - Class `LocalNotificationService`
   - init(), showNotification(), showFraudAlert()
   - Used by main.dart init

2. `lib/services/background_service.dart`
   - Class `BackgroundService`
   - init(), startCallMonitoring(), stopCallMonitoring(), startSmsMonitoring(), stopSmsMonitoring(), registerPeriodicTasks()
   - Used by main.dart init

---

## Issues Fixed (Summary)

| Issue | File | Fix |
|-------|------|-----|
| Missing ApiEndpoints.logout | constants.dart | Added `logout = '/auth/logout'` |
| Nullable fraudType in home_screen | home_screen.dart | Used `?? report.type` |
| Nullable description in home_screen | home_screen.dart | Used `?? ''` |
| const with method call | qr_scanner_screen.dart | Removed `withOpacity` from const |
| Invalid icon `Icons.whatsapp` | live_alerts_screen.dart | Changed to `Icons.chat` |
| Missing context in method | sms_protection_screen.dart | Added `BuildContext context` param |
| Missing local_notification_service | N/A | Created file |
| Missing background_service | N/A | Created file |
| Missing ApiEndpoints.logout | N/A | Added to constants |

---

## Remaining Steps

### Cannot Run On This System:
- `flutter analyze` — Flutter SDK not installed
- `flutter build apk` — Flutter SDK not installed

### To Complete Manually:
```bash
# 1. Install Flutter SDK (if not installed)
# Download from: https://docs.flutter.dev/get-started/install

# 2. Navigate to project
cd apps/citizen-mobile

# 3. Install dependencies
flutter pub get

# 4. Analyze code
flutter analyze

# 5. Fix any remaining issues based on analysis output
# Common issues to watch for:
#   - Unused imports
#   - Deprecated API usage
#   - Type mismatches in widgets

# 6. Build APK
flutter build apk --debug
```

---

## What To Look For If Analysis Still Fails

### Common Flutter 3.16+ Issues:
1. `theme` properties — Check if `colorScheme` is used correctly
2. `ElevatedButton.styleFrom` parameters — Ensure valid parameters
3. `BottomNavigationBarThemeData` — Check API compatibility
4. `MaterialApp.router` — Requires proper GoRouter configuration

### Known Potentially Problematic Constructs:
- Splash screen uses `AnimatedBuilder` — Ensure import is correct
- `flutter_secure_storage` — Ensure it's in pubspec.yaml
- `geolocator` — Ensure Android permissions are set

---

## Files Status After Fixes

1. `constants.dart` — ✅ Fixed (logout added)
2. `auth_repository.dart` — ✅ Should compile (uses ApiEndpoints.logout)
3. `home_screen.dart` — ✅ Fixed (nullable handling)
4. `qr_scanner_screen.dart` — ✅ Fixed (const expressions)
5. `live_alerts_screen.dart` — ✅ Fixed (icon)
6. `sms_protection_screen.dart` — ✅ Fixed (context param)
7. `app_theme.dart` — ✅ No issues found
8. `local_notification_service.dart` — ✅ Created
9. `background_service.dart` — ✅ Created

---

## Steps To Run After Installing Flutter

1. Run `flutter pub get`
2. Run `flutter analyze`
3. Fix any remaining errors
4. Run `flutter build apk --debug`
5. Check `build/app/outputs/flutter-apk/app-debug.apk`