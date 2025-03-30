import 'package:flutter/material.dart';

class AppTheme {
  // 메인 색상: 차분한 네이비 블루
  static const Color primaryColor = Color(0xFF4A5568);
  // 보조 색상: 부드러운 그레이
  static const Color secondaryColor = Color(0xFFA0AEC0);
  // 배경 색상: 밝은 오프화이트
  static const Color backgroundColor = Color(0xFFF7FAFC);
  // 텍스트 색상: 진한 그레이
  static const Color textColor = Color(0xFF2D3748);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
    );
  }
} 