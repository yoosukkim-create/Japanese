import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/viewmodels/home_viewmodel.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/models/word_book.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';

import 'package:japanese/widgets/word_book_recent_card.dart';
import 'package:japanese/widgets/word_book_basic_card.dart';
import 'package:japanese/widgets/word_book_custom_card.dart';

class WordBookScreen extends StatefulWidget {
  const WordBookScreen({super.key});

  @override
  State<WordBookScreen> createState() => _WordBookScreenState();
}

class _WordBookScreenState extends State<WordBookScreen> {
  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    Provider.of<StudyProvider>(context, listen: false).loadRecentLists();
  }

  Widget _buildLoadingView() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildErrorView(HomeViewModel homeVM) {
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return AppBar(
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
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    ThemeProvider themeProvider,
    HomeViewModel homeVM,
  ) {
    return Padding(
      padding: ThemeProvider.cardPadding,
      child: TextField(
        controller: homeVM.searchController,
        onChanged:
            (query) => homeVM.searchWords(
              query,
              (results) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => WordListScreen(
                        title: '"$query" 검색 결과',
                        words: results,
                      ),
                ),
              ),
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
            borderSide: BorderSide(color: themeProvider.mainColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildWordbookList(
    ThemeProvider themeProvider,
    StudyProvider studyProvider,
    List<Wordbook> wordbooks,
  ) {
    return ListView(
      padding: ThemeProvider.bottomPadding,
      children: [
        RecentWordBookCard(
          studyProvider: studyProvider,
          themeProvider: themeProvider,
          onTap: _navigateToWordList,
        ),
        BasicWordBookCard(
          wordbooks: wordbooks,
          themeProvider: themeProvider,
          isDarkMode: isDarkMode,
        ),
        CustomWordbookCard(
          themeProvider: themeProvider,
          isDarkMode: isDarkMode,
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
        if (homeVM.isLoading) return _buildLoadingView();
        if (homeVM.error.isNotEmpty) return _buildErrorView(homeVM);

        return Scaffold(
          appBar: _buildAppBar(context, themeProvider),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context, themeProvider, homeVM),
              Expanded(
                child: _buildWordbookList(
                  themeProvider,
                  studyProvider,
                  homeVM.wordbooks,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
