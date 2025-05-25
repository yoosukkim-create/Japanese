import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _showMemoryParams = true;
  Color _mainColor = const Color(0xFF7F7F7F);

  bool get isDarkMode => _isDarkMode;
  bool get showMemoryParams => _showMemoryParams;
  Color get mainColor => _mainColor;

  static const Color cardBlack = Color(0xFF1C1B1F);
  static const Color cardWhite = Color(0xFFFAFAFA);

  ThemeData get themeData {
    final isDark = _isDarkMode;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: _mainColor,

      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF1F4F6),

      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF1F4F6),
        elevation: 0,
      ),
    );
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setMainColor(Color color) {
    _mainColor = color;
    notifyListeners();
  }

  void toggleMemoryParams() {
    _showMemoryParams = !_showMemoryParams;
    notifyListeners();
  }

  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );

  static const String globalTitle = '메모리 メモリ';
  static const String globalFont = 'Inter';
  static const double globalCornerRadius = 30.0;
  static const Alignment globalBarAlignment = Alignment.centerLeft;

  static double adaptiveImageSize(
    BuildContext context,
    double ratio, [
    double max = 100,
  ]) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * ratio > max ? max : screenWidth * ratio;
  }

  static double mainIconImage(BuildContext context) =>
      adaptiveImageSize(context, 0.2, 50);
  static double memoryIconImage(BuildContext context) =>
      adaptiveImageSize(context, 0.35, 80);

  static TextStyle adaptiveFontSize(
    BuildContext context,
    double ratio,
    double maxSize, {
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    String fontFamily = 'Roboto',
  }) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double size = min(screenHeight * ratio, maxSize);
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // 텍스트 스타일 묶음 구간

  // Word 관련
  static TextStyle wordText(BuildContext context) => adaptiveFontSize(
    context,
    0.1,
    120,
    fontWeight: FontWeight.w700,
    fontFamily: globalFont,
  );
  static TextStyle wordReadMean(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    48,
    fontFamily: globalFont,
    color: Colors.grey[700],
  );

  static TextStyle wordTextSmall(BuildContext context) => adaptiveFontSize(
    context,
    0.06,
    96,
    fontWeight: FontWeight.w700,
    fontFamily: globalFont,
  );

  // 예문 관련
  static TextStyle exampleText(BuildContext context) => adaptiveFontSize(
    context,
    0.033,
    48,
    fontWeight: FontWeight.w700,
    fontFamily: globalFont,
  );
  static TextStyle exampleReadMean(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    32,
    fontFamily: globalFont,
    color: Colors.grey[700],
  );

  // 상단바 및 제목
  static TextStyle mainBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    60,
    fontWeight: FontWeight.w600,
    fontFamily: globalFont,
  );
  static TextStyle mainListStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.02,
    32,
    fontWeight: FontWeight.w900,
    fontFamily: globalFont,
  );
  static TextStyle mainListNameStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.025,
    36,
    fontWeight: FontWeight.w600,
    fontFamily: globalFont,
  );
  static TextStyle settingsBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    40,
    fontWeight: FontWeight.w600,
    fontFamily: globalFont,
  );

  // 부가 정보
  static TextStyle metaCountStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.02,
    24,
    fontWeight: FontWeight.w400,
    fontFamily: globalFont,
  );
  static TextStyle metaDataStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.02,
    24,
    fontFamily: globalFont,
    color: Colors.grey,
  );
  static TextStyle settingTitleStyle(BuildContext context) =>
      adaptiveFontSize(context, 0.025, 24, fontFamily: globalFont);
  static TextStyle settingExplainStyle(BuildContext context) =>
      adaptiveFontSize(
        context,
        0.02,
        24,
        fontFamily: globalFont,
        color: Colors.grey,
      );
}
