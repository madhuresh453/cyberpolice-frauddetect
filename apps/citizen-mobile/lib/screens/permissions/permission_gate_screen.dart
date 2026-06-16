import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/permission_manager.dart';
import '../../providers/app_providers.dart';

class PermissionGateScreen extends ConsumerStatefulWidget {
  final List<String> startupErrors;
  const PermissionGateScreen({super.key, this.startupErrors = const []});

  @override
  ConsumerState<PermissionGateScreen> createState() =>
      _PermissionGateScreenState();
}

class _PermissionGateScreenState extends ConsumerState<PermissionGateScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _loading = false;
  String? _errorMessage;

  bool _callLogsGranted = false;
  bool _contactsGranted = false;
  bool _micGranted = false;
  bool _smsGranted = false;
  bool _cameraGranted = false;
  bool _notificationsGranted = false;
  bool _overlayGranted = false;
  bool _accessibilityGranted = false;
  bool _batteryGranted = false;

  bool get _allMandatoryGranted =>
      _callLogsGranted &&
      _contactsGranted &&
      _micGranted &&
      _smsGranted &&
      _cameraGranted &&
      _notificationsGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final map = await RaksaarPermissionManager.checkAllPermissions();
    if (!mounted) return;
    setState(() {
      _callLogsGranted = map['callLogs'] as bool;
      _contactsGranted = map['contacts'] as bool;
      _micGranted = map['microphone'] as bool;
      _smsGranted = map['sms'] as bool;
      _cameraGranted = map['camera'] as bool;
      _notificationsGranted = map['notifications'] as bool;
      _overlayGranted = map['overlay'] as bool;
      _accessibilityGranted = map['accessibility'] as bool;
      _batteryGranted = map['batteryOptimization'] as bool;
      _loading = false;
    });
    if (_allMandatoryGranted) {
      ref.read(permissionsGrantedProvider.notifier).grant();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canProceed = _allMandatoryGranted;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.15),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Header
                const SizedBox(height: 8),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                  ),
                  child: const Icon(Icons.shield, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text('RAKSAAR',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 2),
                Text('Cyber Safety Operating System',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),

                if (!_loading) ...[
                  // Mandatory section header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Mandatory Permissions',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  _permTile(Icons.phone_in_talk, 'Call Logs', _callLogsGranted, Permission.phone),
                  _permTile(Icons.contacts, 'Contacts', _contactsGranted, Permission.contacts),
                  _permTile(Icons.mic, 'Microphone', _micGranted, Permission.microphone),
                  _permTile(Icons.sms, 'SMS', _smsGranted, Permission.sms),
                  _permTile(Icons.camera_alt, 'Camera', _cameraGranted, Permission.camera),
                  _permTile(Icons.notifications_active, 'Notifications', _notificationsGranted, Permission.notification),
                  const SizedBox(height: 12),
                  // Optional section header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Optional Features',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  _optionalTile(Icons.wallpaper, 'Overlay Protection', _overlayGranted, Permission.systemAlertWindow),
                  _optionalTile(Icons.accessibility, 'Accessibility', _accessibilityGranted, null),
                  _optionalTile(Icons.battery_charging_full, 'Battery Optimization', _batteryGranted, Permission.ignoreBatteryOptimizations),
                ],

                if (_loading) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                ],

                if (!_allMandatoryGranted && !_loading) ...[
                  const SizedBox(height: 8),
                  Text('Missing Required Permissions:', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                  ..._missingMandatoryList(),
                ],

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: canProceed && !_loading
                        ? () => ref.read(permissionsGrantedProvider.notifier).grant()
                        : (!_loading ? () async {
                            setState(() { _loading = true; _errorMessage = null; });
                            await RaksaarPermissionManager.requestMandatoryPermissions(context: context);
                            if (mounted) await _refreshPermissions();
                          } : null),
                    icon: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(canProceed ? Icons.shield : Icons.verified_user),
                    label: Text(_loading ? 'Checking...' : canProceed ? 'Start RAKSAAR Protection' : 'Grant Required Permissions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed ? Colors.green : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('A Government of India Initiative | DPDP 2023 Compliant',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permTile(IconData icon, String label, bool granted, Permission permission) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: granted ? null : () async {
          final ok = await RaksaarPermissionManager.requestMandatoryPermissions(context: context);
          if (ok) _refreshPermissions();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: granted ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: granted ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(granted ? Icons.check_circle : Icons.cancel, color: granted ? Colors.green : Colors.red, size: 18),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
              const Spacer(),
              if (!granted) Text('Allow', style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionalTile(IconData icon, String label, bool granted, Permission? permission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(granted ? Icons.check_circle_outline : Icons.warning_amber, color: granted ? Colors.green : Colors.amber, size: 16),
            const SizedBox(width: 8),
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(granted ? label : '$label Disabled', style: TextStyle(color: granted ? Colors.green : Colors.amber, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _missingMandatoryList() {
    final list = <Widget>[];
    if (!_callLogsGranted) list.add(_missingItem('Call Logs'));
    if (!_contactsGranted) list.add(_missingItem('Contacts'));
    if (!_micGranted) list.add(_missingItem('Microphone'));
    if (!_smsGranted) list.add(_missingItem('SMS'));
    if (!_cameraGranted) list.add(_missingItem('Camera'));
    if (!_notificationsGranted) list.add(_missingItem('Notifications'));
    return list;
  }

  Widget _missingItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('  ✗ ', style: TextStyle(color: Colors.red, fontSize: 12)),
          Text(label, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}