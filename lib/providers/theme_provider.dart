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

  //// GLOBAL //////////////////////////////////////////////////
  static const String globalTitle = '메모리 メモリ';
  static const String globalFont = 'Inter';
  static const double globalCornerRadius = 20.0;
  static const Alignment globalBarAlignment = Alignment.centerLeft;
  static const Color cardBlack = Color(0xFF1C1B1F);
  static const Color cardWhite = Color(0xFFFAFAFA);
  static const gap4 = SizedBox(width: 4.0, height: 4.0);
  static const gap8 = SizedBox(width: 8.0, height: 8.0);
  static const gap12 = SizedBox(width: 12.0, height: 12.0);
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color textColor(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black87;
  }

  //// IMAGE ////////////////////////////////////////////////////
  static double adaptiveSize(
    BuildContext context,
    double ratio, [
    double max = 100,
  ]) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * ratio > max ? max : screenWidth * ratio;
  }

  static double mainIconImage(BuildContext context) =>
      adaptiveSize(context, 0.2, 40);
  static double memoryIconImage(BuildContext context) =>
      adaptiveSize(context, 0.26, 120);
  static double cardIconImage(BuildContext context) =>
      adaptiveSize(context, 0.1, 30);
  static double plusIconImage(BuildContext context) =>
      adaptiveSize(context, 0.2, 40);
  static double bottomBar(BuildContext context) =>
      adaptiveSize(context, 0.3, 120);
  static double bottomIcon(BuildContext context) =>
      adaptiveSize(context, 0.1, 80);
  static double memoryButton(BuildContext context) =>
      adaptiveSize(context, 0.3, 100);

  //// TEXT //////////////////////////////////////////////////////
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

  // 단어
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

  // 예문
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
  static TextStyle globalBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    60,
    fontWeight: FontWeight.w600,
    fontFamily: globalFont,
  );
  static TextStyle cardListStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.025,
    50,
    fontWeight: FontWeight.w300,
    fontFamily: globalFont,
  );
  static TextStyle cardExplainStyle(BuildContext context) =>
      adaptiveFontSize(context, 0.02, 40, fontFamily: globalFont);
  static TextStyle wordListBottomStyle(BuildContext context) =>
      adaptiveFontSize(context, 0.018, 24, fontFamily: globalFont);
  static TextStyle wordInIconStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.01,
    14,
    fontFamily: globalFont,
    fontWeight: FontWeight.bold,
  );
  static TextStyle wodListBottomStyle(BuildContext context) =>
      adaptiveFontSize(context, 0.02, 24, fontFamily: globalFont);

  static TextStyle memoryButtonStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.023,
    60,
    //fontWeight: FontWeight.bold,
    fontFamily: globalFont,
  );
  static TextStyle memoryQuestionStyle(BuildContext context) =>
      adaptiveFontSize(
        context,
        0.023,
        60,
        fontWeight: FontWeight.w500,
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

  // 설정
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
  static TextStyle settingsBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    40,
    fontWeight: FontWeight.w600,
    fontFamily: globalFont,
  );

  //// PADDING & MARGIN /////////////////////////////////////////////
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  static const EdgeInsets bottomPadding = EdgeInsets.only(bottom: 24.0);
  static const EdgeInsets memoryIconPadding = EdgeInsets.only(bottom: 12.0);
  static const EdgeInsets showUpPadding = EdgeInsets.only(bottom: 4.0);
  static const EdgeInsets showDownPadding = EdgeInsets.only(top: 4.0);
  static const EdgeInsets plusIconPadding = EdgeInsets.symmetric(
    vertical: 10.0,
  );
}
