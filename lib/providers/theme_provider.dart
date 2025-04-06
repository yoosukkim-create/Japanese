import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _mainColor = const Color(0xFF4A5568); // 기본값: 네이비 블루

  static const Color navyBlue = Color(0xFF4A5568);
  static const Color cherryBlossom = Color(0xFFFFB7C5);

  bool get isDarkMode => _isDarkMode;
  Color get mainColor => _mainColor;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setMainColor(Color color) {
    _mainColor = color;
    notifyListeners();
  }

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _mainColor,
    );
  }
} 