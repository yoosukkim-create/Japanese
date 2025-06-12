import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/viewmodels/home_viewmodel.dart';
import 'package:japanese/widgets/resolution_guard.dart';
import 'package:japanese/views/screens/word_book_screen.dart';
import 'package:japanese/views/screens/web_kuroshiro_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..loadData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder:
          (context, themeProvider, _) => MaterialApp(
            title: '메모리',
            theme: themeProvider.themeData,
            debugShowCheckedModeBanner: false,
            //home: const ResolutionGuard(child: WordBookScreen()),
            home: const ResolutionGuard(child: WebKuroshiroScreen()),
          ),
    );
  }
}
