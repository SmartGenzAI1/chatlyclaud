// ============================================================================
// FILE: lib/providers/theme_provider.dart
// PURPOSE: Theme and appearance state management
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 14.0;
  String _selectedWallpaper = 'default';
  
  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  String get selectedWallpaper => _selectedWallpaper;
  
  ThemeProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    _selectedWallpaper = prefs.getString('selectedWallpaper') ?? 'default';
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    
    notifyListeners();
  }
  
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    
    notifyListeners();
  }
  
  Future<void> setWallpaper(String wallpaper) async {
    _selectedWallpaper = wallpaper;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedWallpaper', wallpaper);
    
    notifyListeners();
  }
}
