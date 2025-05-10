import 'package:flutter/material.dart';
import '../../models/word_book.dart';
import 'word_list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'settings_screen.dart';
import '../../providers/study_provider.dart';
import 'memory_mode_screen.dart';
import 'package:japanese/utils/top_bounce_only_scroll_physics.dart';
class WordGroupScreen extends StatelessWidget {

  final Wordbook wordbook;

  const WordGroupScreen({Key? key, required this.wordbook}) : super(key: key);

  @override
  bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  Color cardColor(BuildContext context) => isDarkMode(context) ? const Color(0xFF1C1B1F) : Theme.of(context).scaffoldBackgroundColor;
  double cardElevation(BuildContext context) => isDarkMode(context) ? 0.0 : 2.0;
  Color textColor(BuildContext context) => isDarkMode(context) ? Colors.white : Colors.black87;
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Align(
          alignment: Alignment.centerLeft,
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
        physics: const TopBounceOnlyScrollPhysics(),
        padding: const EdgeInsets.all(6.0),
        itemCount: wordbook.wordgroups.length,
        itemBuilder: (context, index) {
          String key = wordbook.wordgroups.keys.elementAt(index);
          final wordgroup = wordbook.wordgroups[key]!;

          return Card(
            color: cardColor(context),
            elevation:cardElevation(context),
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordListScreen(
                      title: key,
                      words: wordgroup.words.map((word) => {
                        'id': word.id,
                        '단어': word.word,
                        '읽기': word.reading,
                        '뜻': word.meaning,
                      }).toList(),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
              children: const [
                Icon(Icons.psychology, size: 32),
                SizedBox(height: 4),
                Text(
                  '메모리 모드',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
        

    );
  }
}
