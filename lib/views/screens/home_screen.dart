import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/viewmodels/home_viewmodel.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/word_group_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';
import 'package:japanese/widgets/card_container.dart';

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

  Widget _buildRecentLists(
    StudyProvider studyProvider,
    ThemeProvider themeProvider,
  ) {
    return CardContainer(
      isDarkMode: isDarkMode(context),
      children: [
        studyProvider.recentWordLists.isEmpty
            ? Padding(
              padding: ThemeProvider.cardPadding,
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    color: themeProvider.mainColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '아직 확인한 단어장이 없습니다',
                    style: ThemeProvider.cardExplainStyle(context),
                  ),
                ],
              ),
            )
            : InkWell(
              onTap:
                  () => _navigateToWordList(studyProvider.recentWordLists[0]),
              child: Padding(
                padding: ThemeProvider.cardPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.rotate(
                          angle: -3.14 / 4,
                          child: Icon(
                            Icons.push_pin,
                            color: themeProvider.mainColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          studyProvider.recentWordLists[0]['title'].toString(),
                          style: ThemeProvider.cardListStyle(context),
                        ),
                      ],
                    ),
                    Text(
                      studyProvider.getProgressText(
                        List<Map<String, dynamic>>.from(
                          studyProvider.recentWordLists[0]['words'] as List,
                        ),
                      ),
                      style: ThemeProvider.metaCountStyle(
                        context,
                      ).copyWith(color: themeProvider.mainColor),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildBasicWordList(
    List<Wordbook> wordbooks,
    ThemeProvider themeProvider,
  ) {
    return CardContainer(
      isDarkMode: isDarkMode(context),
      children: [
        ...wordbooks.asMap().entries.map((entry) {
          final index = entry.key + 1; // 숫자 1부터 시작
          final wordbook = entry.value;
          return InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordGroupScreen(wordbook: wordbook),
                  ),
                ),
            child: Padding(
              padding: ThemeProvider.cardPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // ✅ 둥근 숫자 아이콘
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: themeProvider.mainColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Lv$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 단어장 제목
                      Text(
                        wordbook.title,
                        style: ThemeProvider.cardListStyle(context).copyWith(
                          color:
                              isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Consumer<StudyProvider>(
                    builder: (context, studyProvider, _) {
                      final totalWords = wordbook.wordgroups.values.fold(
                        0,
                        (sum, s) => sum + s.words.length,
                      );
                      final studiedWords = wordbook.wordgroups.values.fold(
                        0,
                        (sum, s) =>
                            sum + studyProvider.getStudiedWordsCount(s.words),
                      );
                      return Text(
                        '$studiedWords/$totalWords',
                        style: ThemeProvider.metaCountStyle(
                          context,
                        ).copyWith(color: themeProvider.mainColor),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCustomWordbooks(ThemeProvider themeProvider) {
    return CardContainer(
      isDarkMode: isDarkMode(context),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Icon(
              Icons.add_circle_outline,
              size: 48,
              color: themeProvider.mainColor,
            ),
          ),
        ),
      ],
    );
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
                  const SizedBox(width: 8),
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
                    _buildRecentLists(studyProvider, themeProvider),
                    _buildBasicWordList(homeVM.wordbooks, themeProvider),
                    _buildCustomWordbooks(themeProvider),
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
