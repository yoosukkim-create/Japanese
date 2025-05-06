import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _showLastViewedTime = true;
  bool _showMemoryParams = true;
  Color _mainColor = const Color(0xFF7F7F7F); 

  static const Color gray = Color(0xFF7F7F7F);
  static const Color pastelRed = Color(0xFFFFC1CC);
  static const Color pastelOrange = Color(0xFFFFD8A8);
  static const Color pastelYellow = Color(0xFFFFF5A5);
  static const Color pastelGreen = Color(0xFFB9FBC0);
  static const Color pastelBlue = Color(0xFFA0C4FF);
  static const Color pastelIndigo = Color(0xFFBDB2FF);

  bool get isDarkMode => _isDarkMode;
  bool get showLastViewedTime => _showLastViewedTime;
  bool get showMemoryParams => _showMemoryParams;
  Color get mainColor => _mainColor;

  ThemeData get themeData => ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _mainColor,
      );

  // Setter 및 토글 함수들
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

  void toggleMemoryParams() {
    _showMemoryParams = !_showMemoryParams;
    notifyListeners();
  }
} 
