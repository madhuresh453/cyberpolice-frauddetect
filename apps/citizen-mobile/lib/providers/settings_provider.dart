import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final bool darkMode;
  final bool threatNotifications;
  final bool autoBlockScammers;
  final bool emergencySOS;
  final bool exportReports;
  final String language;
  final bool biometricLock;
  final bool pinProtection;

  AppSettings({
    this.darkMode = true,
    this.threatNotifications = true,
    this.autoBlockScammers = true,
    this.emergencySOS = true,
    this.exportReports = false,
    this.language = 'en',
    this.biometricLock = false,
    this.pinProtection = false,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? threatNotifications,
    bool? autoBlockScammers,
    bool? emergencySOS,
    bool? exportReports,
    String? language,
    bool? biometricLock,
    bool? pinProtection,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      threatNotifications: threatNotifications ?? this.threatNotifications,
      autoBlockScammers: autoBlockScammers ?? this.autoBlockScammers,
      emergencySOS: emergencySOS ?? this.emergencySOS,
      exportReports: exportReports ?? this.exportReports,
      language: language ?? this.language,
      biometricLock: biometricLock ?? this.biometricLock,
      pinProtection: pinProtection ?? this.pinProtection,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
  void toggleNotifications() => state = state.copyWith(threatNotifications: !state.threatNotifications);
  void toggleAutoBlock() => state = state.copyWith(autoBlockScammers: !state.autoBlockScammers);
  void toggleEmergencySOS() => state = state.copyWith(emergencySOS: !state.emergencySOS);
  void toggleExportReports() => state = state.copyWith(exportReports: !state.exportReports);
  void setLanguage(String lang) => state = state.copyWith(language: lang);
  void toggleBiometric() => state = state.copyWith(biometricLock: !state.biometricLock);
  void togglePin() => state = state.copyWith(pinProtection: !state.pinProtection);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});