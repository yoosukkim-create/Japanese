
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/viewmodels/home_viewmodel.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/word_group_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: '메모리 メモリ',
        theme: themeProvider.themeData,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    Provider.of<StudyProvider>(context, listen: false).loadRecentLists();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCardTitle(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 16, 16, 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.mainColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLists(StudyProvider studyProvider, ThemeProvider themeProvider) {
    return _buildCardContainer(
      children: [
        _buildCardTitle('최근 본 단어장', themeProvider),
        studyProvider.recentWordLists.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  '아직 확인한 단어장이 없습니다',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            : InkWell(
                onTap: () => _navigateToWordList(studyProvider.recentWordLists[0]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        studyProvider.recentWordLists[0]['title'].toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode(context) ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        studyProvider.getProgressText(
                          List<Map<String, dynamic>>.from(
                            studyProvider.recentWordLists[0]['words'] as List,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBasicWordList(List<Wordbook> wordbooks, ThemeProvider themeProvider) {
    return _buildCardContainer(
      children: [
        _buildCardTitle('기본 단어장', themeProvider),
        ...wordbooks.map((wordbook) => InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordGroupScreen(wordbook: wordbook),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      wordbook.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode(context) ? Colors.white : Colors.black87,
                      ),
                    ),
                    Consumer<StudyProvider>(
                      builder: (context, studyProvider, _) {
                        final totalWords = wordbook.wordgroups.values.fold(0, (sum, s) => sum + s.words.length);
                        final studiedWords = wordbook.wordgroups.values.fold(
                          0,
                          (sum, s) => sum + studyProvider.getStudiedWordsCount(s.words),
                        );
                        return Text(
                          '$studiedWords/$totalWords',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCustomWordbooks(ThemeProvider themeProvider) {
    return _buildCardContainer(
      children: [
        _buildCardTitle('커스텀 단어장', themeProvider),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Text(
            'Coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDarkMode(context) ? const Color(0xFF1C1B1F) : Theme.of(context).scaffoldBackgroundColor,
      elevation: isDarkMode(context) ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  void _navigateToWordList(Map<String, dynamic> wordList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordListScreen(
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (homeVM.error.isNotEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: ${homeVM.error}'),
                  ElevatedButton(onPressed: homeVM.loadData, child: const Text('다시 시도')),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '메모리 メモリ',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: 1.2,
                  color: themeProvider.mainColor,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: homeVM.searchController,
                    onChanged: (query) => homeVM.searchWords(
                      query,
                      (results) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordListScreen(title: '"$query" 검색 결과', words: results),
                          ),
                        );
                      },
                      (error) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                      },
                    ),
                    decoration: InputDecoration(
                      hintText: '단어 검색...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius),
                        borderSide: BorderSide(color: themeProvider.mainColor, width: 2),
                      ),
                    ),
                  ),
                ),
                _buildRecentLists(studyProvider, themeProvider),
                _buildBasicWordList(homeVM.wordbooks, themeProvider),
                _buildCustomWordbooks(themeProvider),
              ],
            ),
          ),

        );
      },
    );
  }
}
