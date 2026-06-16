import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Government-grade permission manager for RAKSAAR – Cyber Safety OS
///
/// Permission Policy (v2.0):
/// ─────────────────────────────────────────────
/// MANDATORY (app BLOCKS startup if missing):
///   - READ_CALL_LOG / READ_PHONE_STATE  → call detection
///   - READ_CONTACTS                     → caller reputation
///   - RECORD_AUDIO                      → live call AI analysis
///   - RECEIVE_SMS / READ_SMS            → fraud SMS detection
///   - CAMERA                            → QR / APK scanning
///   - POST_NOTIFICATIONS                → instant fraud alerts
///
/// OPTIONAL (warnings only, NEVER block):
///   - SYSTEM_ALERT_WINDOW               → overlay alerts
///   - BIND_ACCESSIBILITY_SERVICE        → WhatsApp monitoring
///   - IGNORE_BATTERY_OPTIMIZATIONS      → background service
///   - REQUEST_SCHEDULE_EXACT_ALARM      → precise reminders
///   - Auto-Start (OEM specific)         → boot persistence
///   - PACKAGE_USAGE_STATS               → app usage monitoring
///   - ACCESS_FINE_LOCATION              → SOS / heatmap
///
class RaksaarPermissionManager {
  // ─── MANDATORY — app MUST NOT start without these ───
  static final List<Permission> _mandatoryPermissions = [
    Permission.phone,      // READ_CALL_LOG / READ_PHONE_STATE
    Permission.contacts,   // READ_CONTACTS
    Permission.microphone, // RECORD_AUDIO
    Permission.sms,        // RECEIVE_SMS + READ_SMS
    Permission.camera,     // CAMERA
    Permission.notification, // POST_NOTIFICATIONS
  ];

  // ─── OPTIONAL — warnings only, NEVER block startup ───
  static final List<Permission> _optionalPermissions = [
    Permission.systemAlertWindow,         // overlay
    Permission.ignoreBatteryOptimizations, // battery
    Permission.requestInstallPackages,      // APK install (related)
    Permission.location,                    // fine location
    Permission.storage,                     // storage (evidence)
  ];

  // ==================================================================
  //  PUBLIC API
  // ==================================================================

  /// Returns true ONLY when ALL mandatory permissions are granted.
  /// Optional permissions are IGNORED.
  static Future<bool> hasMandatoryPermissions() async {
    final result = await _checkPermissionsInternal();
    return result['allMandatoryGranted'] as bool;
  }

  /// Returns a detailed result map with two groups:
  /// {
  ///   "callLogs":  true/false,     ← mandatory
  ///   "contacts":  true/false,     ← mandatory
  ///   "microphone": true/false,    ← mandatory
  ///   "sms":       true/false,     ← mandatory
  ///   "camera":    true/false,     ← mandatory
  ///   "notifications": true/false, ← mandatory
  ///   "allMandatoryGranted": true/false,
  ///
  ///   "overlay":    true/false,    ← optional
  ///   "accessibility": true/false, ← optional
  ///   "batteryOptimization": true/false, ← optional
  ///   "location":   true/false,    ← optional
  ///   "storage":    true/false,    ← optional
  /// }
  static Future<Map<String, dynamic>> checkAllPermissions() async {
    return await _checkPermissionsInternal();
  }

  /// Request ALL mandatory permissions.
  /// Returns true if ALL mandatory permissions were granted.
  /// Does NOT request or block on optional permissions.
  static Future<bool> requestMandatoryPermissions({
    required BuildContext context,
  }) async {
    for (final p in _mandatoryPermissions) {
      final status = await p.status;
      if (status.isGranted) continue;

      if (status.isPermanentlyDenied) {
        await _showSettingsDialog(context, p);
        return false;
      }

      final result = await p.request();
      if (!result.isGranted) {
        if (result.isPermanentlyDenied) {
          await _showSettingsDialog(context, p);
        }
        return false;
      }
    }
    return true;
  }

  /// Request a single optional permission.
  /// Never blocks or returns false on failure — always returns status.
  static Future<bool> requestOptionalPermission(Permission p) async {
    try {
      final status = await p.request();
      return status.isGranted;
    } catch (e) {
      print("Optional permission request failed (non-fatal): $e");
      return false;
    }
  }

  /// Check accessibility service status (optional).
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      const channel = MethodChannel('com.cybershield/accessibility');
      final result = await channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } catch (e) {
      print("Accessibility check error (non-fatal): $e");
      return false;
    }
  }

  /// Legacy alias — delegates to hasMandatoryPermissions
  static Future<bool> hasAllCriticalPermissions() async {
    return hasMandatoryPermissions();
  }

  // ==================================================================
  //  INTERNAL
  // ==================================================================

  static Future<Map<String, dynamic>> _checkPermissionsInternal() async {
    // ── Mandatory ──
    final phoneStatus = await Permission.phone.status;
    final contactsStatus = await Permission.contacts.status;
    final micStatus = await Permission.microphone.status;
    final smsStatus = await Permission.sms.status;
    final cameraStatus = await Permission.camera.status;
    final notificationStatus = await Permission.notification.status;

    // ── Optional runtime ──
    final overlayStatus = await Permission.systemAlertWindow.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    final locationStatus = await Permission.location.status;
    final storageStatus = await Permission.storage.status;

    // ── Optional non-standard ──
    final accessibilityStatus = await isAccessibilityServiceEnabled();

    // Detailed logging
    print("PERMISSION AUDIT:");
    print("  [MANDATORY]  phone  = $phoneStatus");
    print("  [MANDATORY]  contacts = $contactsStatus");
    print("  [MANDATORY]  mic    = $micStatus");
    print("  [MANDATORY]  sms    = $smsStatus");
    print("  [MANDATORY]  camera = $cameraStatus");
    print("  [MANDATORY]  notification = $notificationStatus");
    print("  [OPTIONAL]  overlay = $overlayStatus");
    print("  [OPTIONAL]  accessibility = $accessibilityStatus");
    print("  [OPTIONAL]  battery = $batteryStatus");
    print("  [OPTIONAL]  location = $locationStatus");
    print("  [OPTIONAL]  storage = $storageStatus");

    final callLogsGranted = phoneStatus.isGranted;
    final contactsGranted = contactsStatus.isGranted;
    final micGranted = micStatus.isGranted;
    final smsGranted = smsStatus.isGranted;
    final cameraGranted = cameraStatus.isGranted;
    final notificationsGranted = notificationStatus.isGranted;

    final allMandatoryGranted = callLogsGranted &&
        contactsGranted &&
        micGranted &&
        smsGranted &&
        cameraGranted &&
        notificationsGranted;

    print("  => allMandatoryGranted = $allMandatoryGranted");
    if (!allMandatoryGranted) {
      print("  !! Missing mandatory permissions — app will NOT start");
    }

    return {
      // Mandatory
      "callLogs": callLogsGranted,
      "contacts": contactsGranted,
      "microphone": micGranted,
      "sms": smsGranted,
      "camera": cameraGranted,
      "notifications": notificationsGranted,
      "allMandatoryGranted": allMandatoryGranted,
      // Optional
      "overlay": overlayStatus.isGranted,
      "accessibility": accessibilityStatus,
      "batteryOptimization": batteryStatus.isGranted,
      "location": locationStatus.isGranted,
      "storage": storageStatus.isGranted,
    };
  }

  // ─── Dialogs ───

  static Future<void> _showSettingsDialog(
      BuildContext context, Permission p) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '${_getPermissionTitle(p)} permission is permanently denied.\n\n'
          'RAKSAAR requires this to protect you from scams.\n\n'
          'Please enable it in Settings → Apps → RAKSAAR → Permissions → '
          '${_getPermissionTitle(p)}',
        ),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit App'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static String _getPermissionTitle(Permission p) {
    switch (p) {
      case Permission.phone:
        return 'Phone / Call Logs';
      case Permission.microphone:
        return 'Microphone';
      case Permission.sms:
        return 'SMS';
      case Permission.contacts:
        return 'Contacts';
      case Permission.camera:
        return 'Camera';
      case Permission.notification:
        return 'Notifications';
      case Permission.systemAlertWindow:
        return 'Overlay Alerts';
      case Permission.ignoreBatteryOptimizations:
        return 'Battery Optimization';
      case Permission.location:
        return 'Location';
      case Permission.storage:
        return 'Storage';
      case Permission.requestInstallPackages:
        return 'APK Installation';
      default:
        return p.toString().split('.').last;
    }
  }
}