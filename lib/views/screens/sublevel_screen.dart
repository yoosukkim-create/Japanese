import 'package:flutter/material.dart';
import '../../models/japanese_level.dart';
import 'word_list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'settings_screen.dart';

// 서브 레벨 선택 화면
class SubLevelScreen extends StatelessWidget {
  final JapaneseLevel level;

  const SubLevelScreen({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
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
        padding: const EdgeInsets.all(16.0),
        itemCount: level.subLevels.length,
        itemBuilder: (context, index) {
          String key = level.subLevels.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordListScreen(
                        title: key,
                        words: level.subLevels[key]!.words.map((word) => {
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
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 