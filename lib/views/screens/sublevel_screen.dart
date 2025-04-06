import 'package:flutter/material.dart';
import '../../models/japanese_level.dart';
import 'word_list_screen.dart';

// 서브 레벨 선택 화면
class SubLevelScreen extends StatelessWidget {
  final JapaneseLevel level;

  const SubLevelScreen({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: ListView.builder(
        itemCount: level.subLevels.length,
        itemBuilder: (context, index) {
          String key = level.subLevels.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordListScreen(
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
              child: Text(key),
            ),
          );
        },
      ),
    );
  }
} 