import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/viewmodels/home_viewmodel.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';

import 'package:japanese/widgets/recent_word_book_card.dart';
import 'package:japanese/widgets/basic_word_book_card.dart';
import 'package:japanese/widgets/custom_word_book_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    Provider.of<StudyProvider>(context, listen: false).loadRecentLists();
  }

  void _navigateToWordList(Map<String, dynamic> wordList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WordListScreen(
              title: wordList['title'].toString(),
              words: List<Map<String, dynamic>>.from(wordList['words'] as List),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeViewModel, ThemeProvider, StudyProvider>(
      builder: (context, homeVM, themeProvider, studyProvider, _) {
        if (homeVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (homeVM.error.isNotEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: ${homeVM.error}'),
                  ElevatedButton(
                    onPressed: homeVM.loadData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Align(
              alignment: ThemeProvider.globalBarAlignment,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/memory_transparent.png',
                    width: ThemeProvider.mainIconImage(context),
                    height: ThemeProvider.mainIconImage(context),
                  ),
                  ThemeProvider.gap8,
                  Text(
                    ThemeProvider.globalTitle,
                    style: ThemeProvider.globalBarStyle(
                      context,
                    ).copyWith(color: themeProvider.mainColor),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 고정된 검색창
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: homeVM.searchController,
                  onChanged:
                      (query) => homeVM.searchWords(
                        query,
                        (results) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => WordListScreen(
                                    title: '"$query" 검색 결과',
                                    words: results,
                                  ),
                            ),
                          );
                        },
                        (error) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        },
                      ),
                  decoration: InputDecoration(
                    hintText: '단어 검색...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeProvider.globalCornerRadius,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeProvider.globalCornerRadius,
                      ),
                      borderSide: BorderSide(
                        color: themeProvider.mainColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // 📜 나머지 리스트는 스크롤 가능하게
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  children: [
                    RecentWordBookCard(
                      studyProvider: studyProvider,
                      themeProvider: themeProvider,
                      onTap: _navigateToWordList,
                    ),
                    BasicWordBookCard(
                      wordbooks: homeVM.wordbooks,
                      themeProvider: themeProvider,
                      isDarkMode: isDarkMode,
                    ),
                    CustomWordbookCard(
                      themeProvider: themeProvider,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
