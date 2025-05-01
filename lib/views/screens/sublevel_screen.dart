import 'package:flutter/material.dart';
import '../../models/japanese_level.dart';
import 'word_list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'settings_screen.dart';
import '../../providers/study_provider.dart';
import 'memory_mode_screen.dart';
class SubLevelScreen extends StatelessWidget {

  final JapaneseLevel level;

  const SubLevelScreen({Key? key, required this.level}) : super(key: key);

  @override
  bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  Color cardColor(BuildContext context) => isDarkMode(context) ? const Color(0xFF1C1B1F) : Theme.of(context).scaffoldBackgroundColor;// const Color(0xFFF8F4F6);
  double cardElevation(BuildContext context) => isDarkMode(context) ? 0.0 : 2.0;
  Color textColor(BuildContext context) => isDarkMode(context) ? Colors.white : Colors.black87;
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          level.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: themeProvider.mainColor,
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
        itemCount: level.subLevels.length,
        itemBuilder: (context, index) {
          String key = level.subLevels.keys.elementAt(index);
          final sublevel = level.subLevels[key]!;

          return Card(
            color: cardColor(context),
            elevation:cardElevation(context),
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordListScreen(
                      title: key,
                      words: sublevel.words.map((word) => {
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor(context),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      studyProvider.getSubLevelProgressText(sublevel.words),
                      style: const TextStyle(
                        fontSize: 14,
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
        padding: const EdgeInsets.only(bottom: 12.0), // 약간 띄워주기
        child: SizedBox(
          height: 60, // 💡 기존보다 큼직한 높이
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryModeScreen(level: level),
                ),
              );
            },
            backgroundColor: themeProvider.mainColor,
            label: const Text(
              '메모리 모드',
              style: TextStyle(
                fontSize: 18, // 💡 글자도 크게!
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(
              Icons.psychology,
              size: 26, // 💡 아이콘도 키움!
            ),
          ),
        ),
      ),

    );
  }
}
