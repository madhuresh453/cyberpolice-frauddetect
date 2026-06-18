import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/family_provider.dart';

class FamilyDashboard extends ConsumerStatefulWidget {
  const FamilyDashboard({super.key});

  @override
  ConsumerState<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends ConsumerState<FamilyDashboard> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedRole = 'member';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final familyState = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Protection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMemberDialog,
            tooltip: 'Add Member',
          ),
        ],
      ),
      body: familyState.members.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.family_restroom, size: 64, color: Colors.grey[500]),
                  const SizedBox(height: 16),
                  Text('No family members added', style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddMemberDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Member'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.family_restroom, color: theme.colorScheme.primary, size: 32),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Family Protection', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('${familyState.members.length} member(s) protected',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Member cards
                ...familyState.members.map((m) => _buildMemberCard(m, theme)),
              ],
            ),
    );
  }

  Widget _buildMemberCard(FamilyMember member, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: member.isProtected
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                member.role == 'senior' ? Icons.elderly : 
                member.role == 'child' ? Icons.child_care : Icons.person,
                color: member.isProtected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(member.phone, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: member.isProtected ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.isProtected ? 'Protected' : 'At Risk',
                          style: TextStyle(
                            color: member.isProtected ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(member.role.toUpperCase(),
                          style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text('${member.riskScore}', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: member.riskScore > 60 ? Colors.red : member.riskScore > 30 ? Colors.orange : Colors.green,
                )),
                Text('Risk', style: TextStyle(color: Colors.grey[500], fontSize: 9)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => ref.read(familyProvider.notifier).removeMember(member.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _selectedRole = 'member';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Family Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'Enter name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone', hintText: '+91XXXXXXXXXX'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'member', child: Text('Family Member')),
                DropdownMenuItem(value: 'senior', child: Text('Senior Citizen')),
                DropdownMenuItem(value: 'child', child: Text('Child')),
              ],
              onChanged: (v) => _selectedRole = v ?? 'member',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) return;
              ref.read(familyProvider.notifier).addMember(FamilyMember(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameCtrl.text,
                phone: _phoneCtrl.text,
                role: _selectedRole,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}