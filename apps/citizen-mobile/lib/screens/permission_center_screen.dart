import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
/// Permission Center Screen - requests all required permissions
class PermissionCenterScreen extends ConsumerStatefulWidget {
  const PermissionCenterScreen({super.key});

  @override
  ConsumerState<PermissionCenterScreen> createState() => _PermissionCenterScreenState();
}

class _PermissionCenterScreenState extends ConsumerState<PermissionCenterScreen> {
  bool _phoneGranted = false;
  bool _smsGranted = false;
  bool _contactsGranted = false;
  bool _notificationsGranted = false;
  bool _microphoneGranted = false;
  bool _locationGranted = false;
  bool _storageGranted = false;
  bool _cameraGranted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _loading = true);
    final phone = await Permission.phone.status;
    final sms = await Permission.sms.status;
    final contacts = await Permission.contacts.status;
    final notifications = await Permission.notification.status;
    final microphone = await Permission.microphone.status;
    final location = await Permission.location.status;
    final storage = await Permission.storage.status;
    final camera = await Permission.camera.status;

    setState(() {
      _phoneGranted = phone.isGranted;
      _smsGranted = sms.isGranted;
      _contactsGranted = contacts.isGranted;
      _notificationsGranted = notifications.isGranted;
      _microphoneGranted = microphone.isGranted;
      _locationGranted = location.isGranted;
      _storageGranted = storage.isGranted;
      _cameraGranted = camera.isGranted;
      _loading = false;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      switch (permission) {
        case Permission.phone: _phoneGranted = status.isGranted; break;
        case Permission.sms: _smsGranted = status.isGranted; break;
        case Permission.contacts: _contactsGranted = status.isGranted; break;
        case Permission.notification: _notificationsGranted = status.isGranted; break;
        case Permission.microphone: _microphoneGranted = status.isGranted; break;
        case Permission.location: _locationGranted = status.isGranted; break;
        case Permission.storage: _storageGranted = status.isGranted; break;
        case Permission.camera: _cameraGranted = status.isGranted; break;
        default: break;
      }
    });
  }

  Future<void> _requestAll() async {
    setState(() => _loading = true);
    await [
      Permission.phone.request(),
      Permission.sms.request(),
      Permission.contacts.request(),
      Permission.notification.request(),
      Permission.microphone.request(),
      Permission.location.request(),
      Permission.storage.request(),
      Permission.camera.request(),
    ].wait;
    await _checkPermissions();
  }

  bool get _allGranted =>
      _phoneGranted && _smsGranted && _contactsGranted &&
      _notificationsGranted && _microphoneGranted && _locationGranted;

  @override
  Widget build(BuildContext context) {
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.primaryBlue.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: const Icon(Icons.shield_outlined, size: 40, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 20),
              Text(
                'Permissions Required',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'CyberShield needs these permissions to protect you from cyber fraud',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // All permissions
              _buildPermissionCard(
                Icons.phone_in_talk,
                'Phone',
                'Detect and analyze incoming scam calls',
                _phoneGranted,
                Permission.phone,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.sms,
                'SMS',
                'Scan messages for phishing and fraud',
                _smsGranted,
                Permission.sms,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.contacts,
                'Contacts',
                'Identify known vs unknown callers',
                _contactsGranted,
                Permission.contacts,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.notifications_active,
                'Notifications',
                'Send real-time fraud alerts',
                _notificationsGranted,
                Permission.notification,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.mic,
                'Microphone',
                'Analyze voice calls for scam keywords',
                _microphoneGranted,
                Permission.microphone,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.location_on,
                'Location',
                'Show local fraud threats and heatmaps',
                _locationGranted,
                Permission.location,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.folder,
                'Storage',
                'Save evidence of fraud attempts',
                _storageGranted,
                Permission.storage,
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                Icons.camera_alt,
                'Camera',
                'Scan QR codes and document evidence',
                _cameraGranted,
                Permission.camera,
              ),

              const SizedBox(height: 32),

              // Allow All button
              if (!_allGranted)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _requestAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.shield, size: 20),
                              SizedBox(width: 8),
                              Text('Allow All Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),

              if (_allGranted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Permissions Granted',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.successGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CyberShield can now fully protect you',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mark permissions as granted and navigate to home
                      context.go('/home');
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

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
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
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

  Widget _buildPermissionCard(
    IconData icon,
    String title,
    String description,
    bool granted,
    Permission permission,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: granted
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: granted
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: granted ? AppTheme.successGreen : AppTheme.warningOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: granted ? null : () => _requestPermission(permission),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: granted
                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                    : AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                granted ? 'Granted' : 'Allow',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: granted ? AppTheme.successGreen : AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}