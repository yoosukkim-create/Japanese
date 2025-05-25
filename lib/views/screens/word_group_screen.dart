import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/memory_mode_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';

class WordGroupScreen extends StatelessWidget {
  final Wordbook wordbook;

  const WordGroupScreen({super.key, required this.wordbook});

  @override
  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  Color cardColor(BuildContext context) =>
      isDarkMode(context) ? ThemeProvider.cardBlack : ThemeProvider.cardWhite;
  Color textColor(BuildContext context) =>
      isDarkMode(context) ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Align(
          alignment: ThemeProvider.appBarAlignment,
          child: Text(
            wordbook.title,
            style: ThemeProvider.mainBarStyle(
              context,
            ).copyWith(color: themeProvider.mainColor),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24.0),
        children: [
          Card(
            margin: ThemeProvider.cardMargin,
            elevation: 0,
            color: cardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ThemeProvider.wordbookCornerRadius,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: ThemeProvider.cardPadding,
                  child: Text(
                    '단어 그룹 목록',
                    style: ThemeProvider.mainListStyle(
                      context,
                    ).copyWith(color: themeProvider.mainColor),
                  ),
                ),
                ...wordbook.wordgroups.entries.map((entry) {
                  final key = entry.key;
                  final wordgroup = entry.value;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => WordListScreen(
                                title: key,
                                words:
                                    wordgroup.words
                                        .map(
                                          (word) => {
                                            'id': word.id,
                                            '단어': word.word,
                                            '읽기': word.reading,
                                            '뜻': word.meaning,
                                            '예문': word.example,
                                            '예문읽기': word.exampleReading,
                                            '예문뜻': word.exampleMeaning,
                                          },
                                        )
                                        .toList(),
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: ThemeProvider.cardPadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            key,
                            style: ThemeProvider.mainListNameStyle(
                              context,
                            ).copyWith(color: textColor(context)),
                          ),
                          Text(
                            studyProvider.getWordgroupProgressText(
                              wordgroup.words,
                            ),
                            style: ThemeProvider.metaCountStyle(
                              context,
                            ).copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: SizedBox(
          width: 100,
          height: 100,
          child: FloatingActionButton(
            backgroundColor: themeProvider.mainColor.withOpacity(0.7),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryModeScreen(wordbook: wordbook),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 32, color: textColor(context)),
                const SizedBox(height: 4),
                Text(
                  '메모리 모드',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: textColor(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
