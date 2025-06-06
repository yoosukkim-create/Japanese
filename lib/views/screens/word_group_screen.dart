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
      isDarkMode(context)
          ? const Color(0xFF1C1B1F)
          : Theme.of(context).scaffoldBackgroundColor;
  double cardElevation(BuildContext context) => isDarkMode(context) ? 0.0 : 2.0;
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
            style: ThemeProvider.wordgroupBarStyle.copyWith(
              color: themeProvider.mainColor,
            ),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(6.0),
        itemCount: wordbook.wordgroups.length,
        itemBuilder: (context, index) {
          String key = wordbook.wordgroups.keys.elementAt(index);
          final wordgroup = wordbook.wordgroups[key]!;

          return Card(
            color: cardColor(context),
            elevation: cardElevation(context),
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ThemeProvider.wordgroupCornerRadius,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                ThemeProvider.wordgroupCornerRadius,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          key,
                          style: ThemeProvider.wordgroupNameStyle.copyWith(
                            color: textColor(context),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      studyProvider.getWordgroupProgressText(wordgroup.words),
                      style: ThemeProvider.wordgroupCountStyle.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: SizedBox(
          width: 100, // 원하는 너비
          height: 100, // 원하는 높이
          child: FloatingActionButton(
            backgroundColor: themeProvider.mainColor,
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
