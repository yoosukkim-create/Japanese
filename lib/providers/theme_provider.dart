import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  Color _mainColor = const Color(0xFFFFB7C5); // 기본값: 체리 블러썸
  bool _showLastViewedTime = true;  // 마지막으로 본 시간 표시 여부

  static const Color navyBlue = Color(0xFF4A5568);
  static const Color cherryBlossom = Color(0xFFFFB7C5);

  bool get isDarkMode => _isDarkMode;
  Color get mainColor => _mainColor;
  bool get showLastViewedTime => _showLastViewedTime;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setMainColor(Color color) {
    _mainColor = color;
    notifyListeners();
  }

  void toggleLastViewedTime() {
    _showLastViewedTime = !_showLastViewedTime;
    notifyListeners();
  }

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _mainColor,
    );
  }
} 