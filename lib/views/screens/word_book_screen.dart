import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/word_book.dart';
import '../../providers/theme_provider.dart';
import 'word_group_screen.dart';
import '../../providers/study_provider.dart';

// 메인 레벨 선택 화면
class WordbookListScreen extends StatelessWidget {
  final List<Wordbook> wordbooks;

  const WordbookListScreen({Key? key, required this.wordbooks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: wordbooks.length,
      itemBuilder: (context, index) {
        return WordbookButton(wordbook: wordbooks[index]);
      },
    );
  }
}

// 레벨 버튼 위젯
class WordbookButton extends StatelessWidget {
  final Wordbook wordbook;

  const WordbookButton({Key? key, required this.wordbook}) : super(key: key);

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
                builder: (context) => WordGroupScreen(wordbook: wordbook),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  wordbook.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  studyProvider.getWordbookProgressText(wordbook.wordgroups),
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