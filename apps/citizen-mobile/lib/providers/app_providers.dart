import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/permission_manager.dart';

class PermissionsNotifier extends StateNotifier<bool> {
  PermissionsNotifier(super.initial);
  
  void grant() => state = true;
  void deny() => state = false;
  
  Future<void> requestAndUpdate(BuildContext context) async {
    final granted = await RaksaarPermissionManager.requestMandatoryPermissions(context: context);
    if (granted) {
      state = true;
    }
  }
}

final permissionsGrantedProvider = StateNotifierProvider<PermissionsNotifier, bool>((ref) {
  return PermissionsNotifier(false);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
  void toggle() => state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});