import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/app_theme.dart';
import '../repositories/trust_score_repository.dart';
import '../models/user_model.dart';

class FamilyProtectionScreen extends ConsumerStatefulWidget {
  const FamilyProtectionScreen({super.key});
  @override
  ConsumerState<FamilyProtectionScreen> createState() => _FamilyProtectionScreenState();
}

class _FamilyProtectionScreenState extends ConsumerState<FamilyProtectionScreen> {
  bool _loading = true;
  String? _error;
  List<FamilyMemberModel> _members = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  String _selectedRelation = 'Mother';

  @override
  void initState() {
    super.initState();
    _loadFamily();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _loadFamily() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(trustScoreRepositoryProvider);
      final data = await repo.getFamilyProtection();
      final members = (data['members'] as List?)
          ?.map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];
      setState(() { _members = members; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load family data: $e'; _loading = false; });
    }
  }

  Future<void> _addMember() async {
    _nameController.clear();
    _phoneController.clear();
    _selectedRelation = 'Mother';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Add Family Member', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRelation,
              dropdownColor: AppTheme.cardBackground,
              items: ['Mother', 'Father', 'Brother', 'Sister', 'Spouse', 'Child', 'Other'].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
              onChanged: (v) => setState(() => _selectedRelation = v ?? 'Mother'),
              decoration: const InputDecoration(labelText: 'Relation'),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); _submitMember(); }, child: const Text('Add')),
        ],
      ),
    );
  }

  Future<void> _submitMember() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    // TODO: Call backend API to add member
    setState(() {
      _members.add(FamilyMemberModel(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameController.text, phone: _phoneController.text, relation: _selectedRelation, status: 'active'));
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added'), backgroundColor: AppTheme.successGreen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Family Protection')),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
        : RefreshIndicator(
            onRefresh: _loadFamily,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(decoration: AppTheme.neonBorder(color: const Color(0xFFEC4899)), padding: const EdgeInsets.all(20), child: Column(children: [
                const Icon(Icons.family_restroom, size: 48, color: Color(0xFFEC4899)),
                const SizedBox(height: 12),
                Text('Protecting ${_members.length} Members', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Family protection shield active', style: TextStyle(color: AppTheme.textSecondary)),
              ])),
              const SizedBox(height: 20),
              if (_error != null) Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_error!, style: const TextStyle(color: AppTheme.dangerRed, fontSize: 13)),
              ),
              const Text('Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              if (_members.isEmpty)
                Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(24), child: const Center(child: Text('No family members added', style: TextStyle(color: AppTheme.textSecondary)))),
              ..._members.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: AppTheme.glassCard(),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: Color(0xFFEC4899))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    Text('${m.relation} · ${m.phone}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: (m.status == 'active' ? AppTheme.successGreen : AppTheme.warningOrange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(m.status, style: TextStyle(color: m.status == 'active' ? AppTheme.successGreen : AppTheme.warningOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
              )),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: _addMember, icon: const Icon(Icons.add), label: const Text('Add Family Member'),
              )),
            ]),
          ),
  );
}