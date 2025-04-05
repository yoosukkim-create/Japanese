import 'package:flutter/material.dart';
import '../../models/japanese_level.dart';
import 'sublevel_screen.dart';

// 메인 레벨 선택 화면
class LevelListScreen extends StatelessWidget {
  final List<JapaneseLevel> levels;

  const LevelListScreen({Key? key, required this.levels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일본어 학습')),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return LevelButton(level: levels[index]);
        },
      ),
    );
  }
}

// 레벨 버튼 위젯
class LevelButton extends StatelessWidget {
  final JapaneseLevel level;

  const LevelButton({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubLevelScreen(level: level),
            ),
          );
        },
        child: Text(level.title),
      ),
    );
  }
} 