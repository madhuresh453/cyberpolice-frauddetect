import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = ref.read(authProvider);
    final phone = authState.user?.phoneNumber ?? '';
    if (phone.isNotEmpty) {
      ref.read(homeProvider.notifier).loadDashboard(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: homeState.loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            : RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Welcome, ${user?.name ?? 'User'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? 'No email', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ]),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryBlue, Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // Trust Score Card
                    Container(
                      decoration: AppTheme.neonBorder(color: AppTheme.successGreen),
                      padding: const EdgeInsets.all(20),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Column(children: [
                          Text('${homeState.trustScore?.score ?? 0}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                          const SizedBox(height: 4),
                          Text(homeState.trustScore?.status ?? 'Safe', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          const Text('Trust Score', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ]),
                        Container(width: 1, height: 60, color: AppTheme.borderColor),
                        Column(children: [
                          Text('${homeState.trustScore?.totalReports ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                          const SizedBox(height: 4),
                          const Text('Reports', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ]),
                        Container(width: 1, height: 60, color: AppTheme.borderColor),
                        Column(children: [
                          Text('${homeState.familyData?['count'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEC4899))),
                          const SizedBox(height: 4),
                          const Text('Protected', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    // Quick Actions
                    const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      _action(context, Icons.emergency, 'SOS', AppTheme.dangerRed, '/emergency'),
                      _action(context, Icons.phone, 'Call', AppTheme.primaryBlue, '/call-protection'),
                      _action(context, Icons.sms, 'SMS', AppTheme.warningOrange, '/sms-protection'),
                      _action(context, Icons.chat, 'WhatsApp', AppTheme.successGreen, '/whatsapp-protection'),
                      _action(context, Icons.qr_code_scanner, 'QR', const Color(0xFF8B5CF6), '/qr-scanner'),
                    ]),
                    const SizedBox(height: 20),
                    // Protection Status
                    Container(
                      decoration: AppTheme.glassCard(),
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Protection Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        _statusItem(Icons.phone, true, 'Call Blocking', '${homeState.familyData?['blockedCount'] ?? 0} numbers blocked'),
                        _statusItem(Icons.shield, true, 'Fraud Detection', 'Active monitoring'),
                        _statusItem(Icons.family_restroom, true, 'Family Shield', '${homeState.familyData?['count'] ?? 0} members'),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    // Recent Reports
                    const Text('Recent Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    if (homeState.recentReports.isEmpty)
                      Container(
                        decoration: AppTheme.glassCard(),
                        padding: const EdgeInsets.all(24),
                        child: const Center(child: Text('No recent reports', style: TextStyle(color: AppTheme.textSecondary))),
                      )
                    else
                      ...homeState.recentReports.take(5).map((report) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: AppTheme.glassCard(),
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(_getReportIcon(report.type), color: AppTheme.dangerRed, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(report.fraudType, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                            Text(report.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ])),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: _getReportColor(report.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(report.status, style: TextStyle(color: _getReportColor(report.status), fontSize: 11, fontWeight: FontWeight.w600))),
                        ]),
                      )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _action(BuildContext c, IconData icon, String label, Color color, String route) =>
    GestureDetector(onTap: () => context.push(route), child: Column(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 24)),
      const SizedBox(height: 6), Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]));

  Widget _statusItem(IconData icon, bool active, String status, String desc) =>
    ListTile(
      leading: Icon(icon, color: active ? AppTheme.successGreen : AppTheme.dangerRed, size: 22),
      title: Text(status, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      trailing: Icon(active ? Icons.check_circle : Icons.error, color: active ? AppTheme.successGreen : AppTheme.dangerRed, size: 18),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'CALL': return Icons.phone;
      case 'SMS': return Icons.sms;
      case 'WHATSAPP': return Icons.chat;
      case 'UPI': return Icons.payments;
      default: return Icons.report;
    }
  }

  Color _getReportColor(String status) {
    switch (status) {
      case 'PENDING': return AppTheme.warningOrange;
      case 'REVIEWING': return AppTheme.primaryBlue;
      case 'RESOLVED': return AppTheme.successGreen;
      default: return AppTheme.textSecondary;
    }
  }

  Widget _bottomNav() => Container(
    decoration: BoxDecoration(color: AppTheme.cardBackground, border: Border(top: BorderSide(color: AppTheme.borderColor.withValues(alpha: 0.3)))),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _navItem(Icons.home, 'Home', true, () {}),
      _navItem(Icons.shield, 'Protect', false, () => context.push('/call-protection')),
      _navItem(Icons.report, 'Report', false, () => context.push('/report')),
      _navItem(Icons.person, 'Profile', false, () => context.push('/profile')),
    ]),
  );

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: active ? AppTheme.primaryBlue : AppTheme.textSecondary, size: 24),
      const SizedBox(height: 4), Text(label, style: TextStyle(color: active ? AppTheme.primaryBlue : AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
    ]));
}