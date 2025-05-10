import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const double defaultCornerRadius = 30.0;


  //// Manage Every Text Here

  // 1. wordbook list Screen (Main)
  static const Alignment wordbookBarAlignment = Alignment.centerLeft;
  static const String wordbookBarTitle = '메모리 メモリ'; 
  static final TextStyle wordbookBarStyle = GoogleFonts.getFont(
    'Do Hyeon',
    fontSize:  24.0,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
  );
  static final TextStyle wordbookListStyle = GoogleFonts.getFont(
    'Do Hyeon',
    fontSize:  14.0,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle wordbookNameStyle = GoogleFonts.getFont(
    'Roboto',
    fontSize:  16.0,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle wordbookCountStyle = GoogleFonts.getFont(
    'Roboto',
    fontSize:  14.0,
    fontWeight: FontWeight.w400,
  );

  // 2. wordgroup list Screen (Sub)
  static final TextStyle wordgroupBarStyle = GoogleFonts.getFont(
    'Roboto',
    fontSize:  20.0,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle wordgroupNameStyle = GoogleFonts.getFont(
    'Roboto',
    fontSize:  16.0,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle wordgroupCountStyle = GoogleFonts.getFont(
    'Roboto',
    fontSize:  14.0,
    fontWeight: FontWeight.w400,
  );

  // 3. word list Screen - flash card 
  // 4. word list Screen - list card 
  // 5. word list Screen - memory card 
  // 6. settings Screen 
} 
