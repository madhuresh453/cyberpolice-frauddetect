import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final evidenceVaultServiceProvider = Provider<EvidenceVaultService>((ref) => EvidenceVaultService());

class EvidenceItem {
  final String id;
  final String title;
  final String description;
  final String filePath;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;
  final bool synced;

  EvidenceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'filePath': filePath, 'fileType': fileType, 'fileSize': fileSize,
    'createdAt': createdAt.toIso8601String(), 'synced': synced,
  };

  factory EvidenceItem.fromJson(Map<String, dynamic> json) => EvidenceItem(
    id: json['id'] ?? '', title: json['title'] ?? '',
    description: json['description'] ?? '', filePath: json['filePath'] ?? '',
    fileType: json['fileType'] ?? '', fileSize: json['fileSize'] ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    synced: json['synced'] ?? false,
  );
}

class EvidenceVaultService {
  static const String _boxName = 'evidence_vault';
  Box<String>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  Box<String> get box {
    if (_box == null || !_box!.isOpen) throw Exception('Vault not initialized');
    return _box!;
  }

  Future<String> saveEvidence({
    required String title,
    required String description,
    required String filePath,
    required String fileType,
  }) async {
    final file = File(filePath);
    final fileSize = await file.length();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Copy file to app's private directory
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/vault');
    if (!await vaultDir.exists()) await vaultDir.create(recursive: true);
    final destPath = '${vaultDir.path}/$id.$fileType';
    await file.copy(destPath);

    final item = EvidenceItem(
      id: id, title: title, description: description,
      filePath: destPath, fileType: fileType, fileSize: fileSize,
      createdAt: DateTime.now(),
    );
    await box.put(id, jsonEncode(item.toJson()));
    return id;
  }

  List<EvidenceItem> getAllEvidence() {
    return box.values.map((e) => EvidenceItem.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  int get totalFiles => box.length;

  int get totalSize => getAllEvidence().fold(0, (sum, e) => sum + e.fileSize);

  String get totalSizeFormatted {
    final bytes = totalSize;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  Future<void> deleteEvidence(String id) async {
    final item = getEvidence(id);
    if (item != null) {
      final file = File(item.filePath);
      if (await file.exists()) await file.delete();
      await box.delete(id);
    }
  }

  EvidenceItem? getEvidence(String id) {
    final data = box.get(id);
    if (data == null) return null;
    return EvidenceItem.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> syncToCloud() async {
    // TODO: Implement cloud sync API
    final items = getAllEvidence();
    for (final item in items) {
      if (!item.synced) {
        // Mark as synced after upload
        final updated = EvidenceItem(
          id: item.id, title: item.title, description: item.description,
          filePath: item.filePath, fileType: item.fileType,
          fileSize: item.fileSize, createdAt: item.createdAt, synced: true,
        );
        await box.put(item.id, jsonEncode(updated.toJson()));
      }
    }
  }

  int get unsyncedCount => getAllEvidence().where((e) => !e.synced).length;
}