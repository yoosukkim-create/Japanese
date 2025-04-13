import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/japanese_level.dart';
import '../../providers/theme_provider.dart';
import 'sublevel_screen.dart';
import '../../providers/study_provider.dart';

// 메인 레벨 선택 화면
class LevelListScreen extends StatelessWidget {
  final List<JapaneseLevel> levels;

  const LevelListScreen({Key? key, required this.levels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        return LevelButton(level: levels[index]);
      },
    );
  }
}

// 레벨 버튼 위젯
class LevelButton extends StatelessWidget {
  final JapaneseLevel level;

  const LevelButton({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    
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
                builder: (context) => SubLevelScreen(level: level),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  studyProvider.getLevelProgressText(level.subLevels),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 