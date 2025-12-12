// lib/ui/settings/theme_manager.dart

import 'package:flutter/material.dart';

class ThemeManager {
  // Singleton: Chỉ 1 ông quản lý thôi
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  // Biến thông báo thay đổi giao diện (Mặc định là theo hệ thống hoặc Sáng)
  final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  // Hàm đổi giao diện
  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}