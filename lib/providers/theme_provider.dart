import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

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

  static const double wordbookCornerRadius = 30.0;
  static const double wordgroupCornerRadius = 15.0;
  static const double wordlistCornerRadius = 30.0;

  static const Alignment appBarAlignment = Alignment.centerLeft;
  static const String wordbookBarTitle = '메모리 メモリ';

  static const String fontAppBar = 'Jua';
  static const String fontWord = 'Roboto';
  static const String fontMeta = 'Jua';

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
    0.08,
    120,
    fontWeight: FontWeight.w700,
    fontFamily: fontWord,
  );
  static TextStyle wordReadMean(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    48,
    fontFamily: fontWord,
    color: Colors.grey[700],
  );

  static TextStyle wordTextSmall(BuildContext context) => adaptiveFontSize(
    context,
    0.06,
    96,
    fontWeight: FontWeight.w700,
    fontFamily: fontWord,
  );
  static TextStyle wordReadMeanSmall(BuildContext context) => adaptiveFontSize(
    context,
    0.02,
    32,
    fontFamily: fontWord,
    color: Colors.grey[700],
  );

  // 예문 관련
  static TextStyle exampleText(BuildContext context) => adaptiveFontSize(
    context,
    0.035,
    48,
    fontWeight: FontWeight.w700,
    fontFamily: fontWord,
  );
  static TextStyle exampleReadMean(BuildContext context) => adaptiveFontSize(
    context,
    0.02,
    32,
    fontFamily: fontWord,
    color: Colors.grey[700],
  );

  // 상단바 및 제목
  static TextStyle mainBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.05,
    60,
    fontWeight: FontWeight.w900,
    fontFamily: fontAppBar,
  );
  static TextStyle subBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.045,
    52,
    fontWeight: FontWeight.w400,
    fontFamily: fontAppBar,
  );
  static TextStyle mainListStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    32,
    fontWeight: FontWeight.w700,
    fontFamily: fontAppBar,
  );
  static TextStyle mainListNameStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.035,
    36,
    fontWeight: FontWeight.w400,
    fontFamily: fontWord,
  );
  static TextStyle settingsBarStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    40,
    fontWeight: FontWeight.w600,
    fontFamily: fontWord,
  );

  // 부가 정보
  static TextStyle metaCountStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.03,
    32,
    fontWeight: FontWeight.w400,
    fontFamily: fontMeta,
  );
  static TextStyle timeAgoStyle(BuildContext context) => adaptiveFontSize(
    context,
    0.025,
    28,
    fontFamily: fontMeta,
    color: Colors.grey,
  );
}
