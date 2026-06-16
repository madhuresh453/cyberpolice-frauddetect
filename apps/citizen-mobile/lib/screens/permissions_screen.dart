import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';
import '../core/permission_manager.dart';

/// Permissions screen (legacy, kept for routing backward-compat).
/// Uses the new mandatory-vs-optional model internally.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});
  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _callLogs = false;
  bool _contacts = false;
  bool _mic = false;
  bool _sms = false;
  bool _camera = false;
  bool _notifications = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final map = await RaksaarPermissionManager.checkAllPermissions();
    if (!mounted) return;
    setState(() {
      _callLogs = map['callLogs'] as bool;
      _contacts = map['contacts'] as bool;
      _mic = map['microphone'] as bool;
      _sms = map['sms'] as bool;
      _camera = map['camera'] as bool;
      _notifications = map['notifications'] as bool;
      _loading = false;
    });
  }

  bool get _allMandatory =>
      _callLogs && _contacts && _mic && _sms && _camera && _notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),
            const ShieldIcon(size: 80),
            const SizedBox(height: 20),
            const Text('Enable Full Protection',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppTheme.cyberBlue),
              ),
            if (!_loading) ...[
              _permTile(Icons.call, 'Call Logs', _callLogs, Permission.phone),
              _permTile(Icons.contacts, 'Contacts', _contacts, Permission.contacts),
              _permTile(Icons.mic, 'Microphone', _mic, Permission.microphone),
              _permTile(Icons.sms, 'SMS', _sms, Permission.sms),
              _permTile(Icons.camera_alt, 'Camera', _camera, Permission.camera),
              _permTile(Icons.notifications_active, 'Notifications',
                  _notifications, Permission.notification),
            ],
            const SizedBox(height: 24),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor)),
                child: const Row(children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: AppTheme.textSecondary),
                  SizedBox(width: 8),
                  Text('Your data is safe and 100% secure',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary))
                ])),
            const SizedBox(height: 24),
            if (!_loading)
              CyberButton(
                label: _allMandatory
                    ? 'Continue to Dashboard'
                    : 'Allow Required Permissions',
                icon: _allMandatory ? Icons.arrow_forward : Icons.shield,
                color: _allMandatory ? AppTheme.safeGreen : AppTheme.cyberBlue,
                onPressed: _allMandatory
                    ? () => context.go('/home')
                    : _requestAll,
              ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _permTile(
      IconData icon, String title, bool granted, Permission permission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: granted
            ? null
            : () async {
                await permission.request();
                _refresh();
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: granted
                  ? AppTheme.safeGreen.withValues(alpha: 0.3)
                  : AppTheme.borderColor,
            ),
          ),
          child: Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: (granted
                            ? AppTheme.safeGreen
                            : AppTheme.cyberBlue)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon,
                    color: granted ? AppTheme.safeGreen : AppTheme.cyberBlue,
                    size: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: granted
                    ? AppTheme.safeGreen.withValues(alpha: 0.15)
                    : AppTheme.cyberBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                granted ? 'Granted' : 'Allow',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: granted ? AppTheme.safeGreen : AppTheme.cyberBlue,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _requestAll() async {
    setState(() => _loading = true);
    await RaksaarPermissionManager.requestMandatoryPermissions(
        context: context);
    await _refresh();
  }
}