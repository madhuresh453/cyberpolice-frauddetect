import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Dual storage for production - uses FlutterSecureStorage with Hive fallback
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._();
  factory SecureStorage() => _instance;
  SecureStorage._();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> save(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
    } catch (e) {
      debugPrint('[SecureStorage] Secure write failed, using Hive fallback: $e');
      final box = await Hive.openBox('auth');
      await box.put(key, value);
    }
  }

  Future<String?> get(String key) async {
    try {
      final value = await _secure.read(key: key);
      if (value != null) return value;
    } catch (e) {
      debugPrint('[SecureStorage] Secure read failed, trying Hive fallback: $e');
    }
    try {
      final box = await Hive.openBox('auth');
      return box.get(key) as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (_) {}
    try {
      final box = await Hive.openBox('auth');
      await box.delete(key);
    } catch (_) {}
  }

  Future<void> deleteAll() async {
    try {
      await _secure.deleteAll();
    } catch (_) {}
    try {
      final box = await Hive.openBox('auth');
      await box.clear();
    } catch (_) {}
  }
}