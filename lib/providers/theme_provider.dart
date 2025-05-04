import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // 상태 변수들
  bool _isDarkMode = true;
  bool _showLastViewedTime = true;
  bool _showMemoryParams = true;
  Color _mainColor = const Color(0xFFFFB7C5); // 기본 색상: 체리 블러썸

  // 정적 색상 정의
  static const Color navyBlue = Color(0xFF4A5568);
  static const Color cherryBlossom = Color(0xFFFFB7C5);

  // Getter
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
