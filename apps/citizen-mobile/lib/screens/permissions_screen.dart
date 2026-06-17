import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../core/permission_manager.dart';

/// Permission Gate Screen – Blocks ALL access until ALL mandatory permissions granted.
/// Cannot be bypassed. If user denies, shows settings dialog.
/// If user permanently denies, shows exit/settings dialog.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _checking = true;
  bool _allGranted = false;
  String? _error;

  // Permission states
  bool _phoneGranted = false;
  bool _smsGranted = false;
  bool _contactsGranted = false;
  bool _microphoneGranted = false;
  bool _locationGranted = false;
  bool _notificationsGranted = false;
  bool _cameraGranted = false;
  bool _storageGranted = false;
  bool _overlayGranted = false;
  bool _batteryGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() { _checking = true; _error = null; });
    try {
      final phone = await Permission.phone.status;
      final sms = await Permission.sms.status;
      final contacts = await Permission.contacts.status;
      final microphone = await Permission.microphone.status;
      final location = await Permission.location.status;
      final notifications = await Permission.notification.status;
      final camera = await Permission.camera.status;
      final storage = await Permission.storage.status;
      final overlay = await Permission.systemAlertWindow.status;
      final battery = await Permission.ignoreBatteryOptimizations.status;

      setState(() {
        _phoneGranted = phone.isGranted;
        _smsGranted = sms.isGranted;
        _contactsGranted = contacts.isGranted;
        _microphoneGranted = microphone.isGranted;
        _locationGranted = location.isGranted;
        _notificationsGranted = notifications.isGranted;
        _cameraGranted = camera.isGranted;
        _storageGranted = storage.isGranted;
        _overlayGranted = overlay.isGranted;
        _batteryGranted = battery.isGranted;
        _allGranted = _checkAllMandatory();
        _checking = false;
      });

      if (_allGranted) {
        // All mandatory permissions granted – proceed to app
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.go('/onboarding/1');
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _checking = false;
      });
    }
  }

  bool _checkAllMandatory() {
    return _phoneGranted && _smsGranted && _contactsGranted &&
           _microphoneGranted && _locationGranted && _notificationsGranted &&
           _cameraGranted && _storageGranted;
  }

  List<_PermissionItem> _getPermissionItems() {
    return [
      _PermissionItem(Icons.phone_in_talk, 'Phone Access', 'Detect and block scam calls', _phoneGranted, Permission.phone),
      _PermissionItem(Icons.sms, 'SMS Access', 'Scan messages for fraud and phishing', _smsGranted, Permission.sms),
      _PermissionItem(Icons.contacts, 'Contacts', 'Verify caller reputation', _contactsGranted, Permission.contacts),
      _PermissionItem(Icons.mic, 'Microphone', 'Analyze calls for scam keywords', _microphoneGranted, Permission.microphone),
      _PermissionItem(Icons.location_on, 'Location', 'Emergency SOS and threat heatmaps', _locationGranted, Permission.location),
      _PermissionItem(Icons.notifications_active, 'Notifications', 'Real-time fraud alerts', _notificationsGranted, Permission.notification),
      _PermissionItem(Icons.camera_alt, 'Camera', 'QR scanning and evidence upload', _cameraGranted, Permission.camera),
      _PermissionItem(Icons.folder, 'Storage', 'Save fraud evidence securely', _storageGranted, Permission.storage),
    ];
  }

  Future<void> _requestSinglePermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(permission);
      return;
    }
    await _checkPermissions();
  }

  Future<void> _requestAllMandatory() async {
    setState(() { _checking = true; });

    // Request all mandatory permissions in sequence
    final mandatoryPermissions = [
      Permission.phone,
      Permission.sms,
      Permission.contacts,
      Permission.microphone,
      Permission.location,
      Permission.notification,
      Permission.camera,
      Permission.storage,
    ];

    for (final p in mandatoryPermissions) {
      final status = await p.status;
      if (status.isGranted) continue;
      
      if (status.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog(p);
        return;
      }
      
      final result = await p.request();
      if (result.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog(p);
        return;
      }
    }

    // Also request optional ones
    await Permission.systemAlertWindow.request();
    await Permission.ignoreBatteryOptimizations.request();

    await _checkPermissions();
  }

  void _showPermanentlyDeniedDialog(Permission p) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '${_getPermissionName(p)} permission is permanently denied.\n\n'
          'RAKSAAR CyberShield requires this permission to protect you.\n\n'
          'Please enable it in Settings → Apps → RAKSAAR → Permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit App'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
              await _checkPermissions();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _getPermissionName(Permission p) {
    switch (p) {
      case Permission.phone: return 'Phone / Call Logs';
      case Permission.sms: return 'SMS';
      case Permission.contacts: return 'Contacts';
      case Permission.microphone: return 'Microphone';
      case Permission.location: return 'Location';
      case Permission.notification: return 'Notifications';
      case Permission.camera: return 'Camera';
      case Permission.storage: return 'Storage';
      default: return p.toString().split('.').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, size: 64, color: AppTheme.primaryBlue),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text('Checking permissions...', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_allGranted) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: AppTheme.successGreen),
              const SizedBox(height: 24),
              const Text('All Permissions Granted', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Starting CyberShield Protection...', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppTheme.successGreen),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Shield icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue.withValues(alpha: 0.2), AppTheme.primaryBlue.withValues(alpha: 0.05)],
                  ),
                ),
                child: const Icon(Icons.shield_outlined, size: 40, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 20),
              Text(
                'Permissions Required',
                style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'CyberShield needs these permissions to protect you from cyber fraud.\nWithout them, the app cannot function.',
                style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // All permission cards
              ..._getPermissionItems().map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPermissionCard(item),
              )),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text('Error: $_error', style: const TextStyle(color: AppTheme.dangerRed, fontSize: 12)),
              ],

              const SizedBox(height: 24),

              // Grant All button
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _requestAllMandatory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield, size: 20),
                      SizedBox(width: 8),
                      Text('Grant All Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outlined, size: 20, color: AppTheme.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your privacy is protected. All data is encrypted and never shared without your consent.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(_PermissionItem item) {
    final granted = _isGranted(item.permission);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: granted ? AppTheme.successGreen.withValues(alpha: 0.3) : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: granted ? AppTheme.successGreen.withValues(alpha: 0.1) : AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: granted ? AppTheme.successGreen : AppTheme.warningOrange, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text(item.description, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: granted ? null : () => _requestSinglePermission(item.permission),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: granted ? AppTheme.successGreen.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                granted ? 'Granted' : 'Allow',
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: granted ? AppTheme.successGreen : AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isGranted(Permission permission) {
    switch (permission) {
      case Permission.phone: return _phoneGranted;
      case Permission.sms: return _smsGranted;
      case Permission.contacts: return _contactsGranted;
      case Permission.microphone: return _microphoneGranted;
      case Permission.location: return _locationGranted;
      case Permission.notification: return _notificationsGranted;
      case Permission.camera: return _cameraGranted;
      case Permission.storage: return _storageGranted;
      case Permission.systemAlertWindow: return _overlayGranted;
      case Permission.ignoreBatteryOptimizations: return _batteryGranted;
      default: return false;
    }
  }
}

class _PermissionItem {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final Permission permission;

  _PermissionItem(this.icon, this.title, this.description, this.granted, this.permission);
}