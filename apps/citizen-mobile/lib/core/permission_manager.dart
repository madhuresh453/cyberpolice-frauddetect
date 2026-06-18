import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Government-grade permission manager for RAKSAAR – Cyber Safety OS
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
  // Fields are intentionally kept for documentation but analyzed code uses them inline

  /// Returns true ONLY when ALL mandatory permissions are granted.
  static Future<bool> hasMandatoryPermissions() async {
    final result = await _checkPermissionsInternal();
    return result['allMandatoryGranted'] as bool;
  }

  /// Returns detailed permission status map
  static Future<Map<String, dynamic>> checkAllPermissions() async {
    return await _checkPermissionsInternal();
  }

  /// Request ALL mandatory permissions sequentially.
  static Future<bool> requestMandatoryPermissions({required BuildContext context}) async {
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

  /// Request a single optional permission (never blocks)
  static Future<bool> requestOptionalPermission(Permission p) async {
    try {
      final status = await p.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Optional permission error: $e');
      return false;
    }
  }

  /// Check accessibility service status
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      const channel = MethodChannel('com.cybershield/accessibility');
      final result = await channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('Accessibility check error: $e');
      return false;
    }
  }

  /// Legacy alias — delegates to hasMandatoryPermissions
  static Future<bool> hasAllCriticalPermissions() async {
    return hasMandatoryPermissions();
  }

  static Future<Map<String, dynamic>> _checkPermissionsInternal() async {
    final phoneStatus = await Permission.phone.status;
    final contactsStatus = await Permission.contacts.status;
    final micStatus = await Permission.microphone.status;
    final smsStatus = await Permission.sms.status;
    final cameraStatus = await Permission.camera.status;
    final notificationStatus = await Permission.notification.status;
    final overlayStatus = await Permission.systemAlertWindow.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    final locationStatus = await Permission.location.status;
    final storageStatus = await Permission.storage.status;
    final accessibilityStatus = await isAccessibilityServiceEnabled();

    final callLogsGranted = phoneStatus.isGranted;
    final contactsGranted = contactsStatus.isGranted;
    final micGranted = micStatus.isGranted;
    final smsGranted = smsStatus.isGranted;
    final cameraGranted = cameraStatus.isGranted;
    final notificationsGranted = notificationStatus.isGranted;

    final allMandatoryGranted = callLogsGranted && contactsGranted &&
        micGranted && smsGranted && cameraGranted && notificationsGranted;

    return {
      "callLogs": callLogsGranted,
      "contacts": contactsGranted,
      "microphone": micGranted,
      "sms": smsGranted,
      "camera": cameraGranted,
      "notifications": notificationsGranted,
      "allMandatoryGranted": allMandatoryGranted,
      "overlay": overlayStatus.isGranted,
      "accessibility": accessibilityStatus,
      "batteryOptimization": batteryStatus.isGranted,
      "location": locationStatus.isGranted,
      "storage": storageStatus.isGranted,
    };
  }

  static Future<void> _showSettingsDialog(BuildContext context, Permission p) async {
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
      case Permission.phone: return 'Phone / Call Logs';
      case Permission.microphone: return 'Microphone';
      case Permission.sms: return 'SMS';
      case Permission.contacts: return 'Contacts';
      case Permission.camera: return 'Camera';
      case Permission.notification: return 'Notifications';
      case Permission.systemAlertWindow: return 'Overlay Alerts';
      case Permission.ignoreBatteryOptimizations: return 'Battery';
      case Permission.location: return 'Location';
      case Permission.storage: return 'Storage';
      case Permission.requestInstallPackages: return 'APK Installation';
      default: return p.toString().split('.').last;
    }
  }
}