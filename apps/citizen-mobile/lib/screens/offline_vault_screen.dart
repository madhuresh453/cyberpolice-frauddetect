import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_theme.dart';
import '../services/evidence_vault_service.dart';

class OfflineVaultScreen extends ConsumerStatefulWidget {
  const OfflineVaultScreen({super.key});
  @override
  ConsumerState<OfflineVaultScreen> createState() => _OfflineVaultScreenState();
}

class _OfflineVaultScreenState extends ConsumerState<OfflineVaultScreen> {
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(evidenceVaultServiceProvider);
    final evidence = vault.getAllEvidence();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Evidence Vault'), actions: [
        IconButton(icon: const Icon(Icons.cloud_upload), onPressed: () async {
          await vault.syncToCloud();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed'), backgroundColor: AppTheme.successGreen));
        }),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Stats
        Container(decoration: AppTheme.neonBorder(color: AppTheme.successGreen), padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(children: [
            Text('${vault.totalFiles}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
            const Text('Files', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
          Column(children: [
            Text(vault.totalSizeFormatted, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const Text('Storage', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
          Column(children: [
            Text('${vault.unsyncedCount}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: vault.unsyncedCount > 0 ? AppTheme.warningOrange : AppTheme.successGreen)),
            const Text('Unsynced', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ])),
        const SizedBox(height: 16),
        // Add evidence buttons
        Row(children: [
          Expanded(child: _addButton(Icons.camera_alt, 'Camera', () => _addFromCamera())),
          const SizedBox(width: 8),
          Expanded(child: _addButton(Icons.photo_library, 'Gallery', () => _addFromGallery())),
          const SizedBox(width: 8),
          Expanded(child: _addButton(Icons.mic, 'Audio', () {})),
          const SizedBox(width: 8),
          Expanded(child: _addButton(Icons.description, 'File', () {})),
        ]),
        const SizedBox(height: 20),
        Text('Evidence (${evidence.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        if (evidence.isEmpty)
          Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(24), child: const Column(children: [
            Icon(Icons.lock, size: 48, color: AppTheme.textSecondary), SizedBox(height: 12),
            Text('No evidence stored', style: TextStyle(color: AppTheme.textSecondary)), SizedBox(height: 4),
            Text('Tap camera or gallery to add evidence', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]))
        else
          ...evidence.map((item) => Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), color: AppTheme.dangerRed, child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) async {
              await vault.deleteEvidence(item.id);
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: AppTheme.glassCard(),
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: _getIconColor(item.fileType).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(_getIcon(item.fileType), color: _getIconColor(item.fileType), size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('${item.fileType.toUpperCase()} · ${_formatSize(item.fileSize)} · ${_formatDate(item.createdAt)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: (item.synced ? AppTheme.successGreen : AppTheme.warningOrange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(item.synced ? Icons.cloud_done : Icons.cloud_off, color: item.synced ? AppTheme.successGreen : AppTheme.warningOrange, size: 14),
                ),
              ]),
            ),
          )),
      ]),
    );
  }

  Widget _addButton(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: AppTheme.glassCard(), child: Column(children: [
      Icon(icon, color: AppTheme.primaryBlue, size: 24), const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
    ])),
  );

  Future<void> _addFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      final vault = ref.read(evidenceVaultServiceProvider);
      await vault.saveEvidence(title: 'Camera Evidence', description: 'Captured at ${DateTime.now()}', filePath: image.path, fileType: 'jpg');
      setState(() {});
    }
  }

  Future<void> _addFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final vault = ref.read(evidenceVaultServiceProvider);
      await vault.saveEvidence(title: 'Gallery Evidence', description: 'Selected from gallery', filePath: image.path, fileType: 'jpg');
      setState(() {});
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'jpg': case 'png': return Icons.image;
      case 'mp3': case 'wav': return Icons.mic;
      case 'mp4': return Icons.videocam;
      default: return Icons.description;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'jpg': case 'png': return AppTheme.primaryBlue;
      case 'mp3': case 'wav': return AppTheme.successGreen;
      case 'mp4': return AppTheme.dangerRed;
      default: return AppTheme.warningOrange;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}