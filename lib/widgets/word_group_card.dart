// lib/views/widgets/word_group_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/widgets/card_container.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// WordGroupBasicCard:
/// - Wordbook 안의 한 그룹(key)과 그 그룹에 속한 단어 리스트(words) 정보를 받아
///   왼쪽에는 그룹 이름, 오른쪽에는 progress 텍스트를 보여주는 카드 한 줄(Row) 위젯
/// - 클릭 시 onTap 콜백을 호출
class WordGroupBasicCard extends StatelessWidget {
  final String groupKey;
  final List<WordCard> words;
  final StudyProvider studyProvider;
  final VoidCallback onTap;

  const WordGroupBasicCard({
    super.key,
    required this.groupKey,
    required this.words,
    required this.studyProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: ThemeProvider.cardPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 그룹 이름
            Text(
              groupKey,
              style: ThemeProvider.cardListStyle(
                context,
              ).copyWith(color: ThemeProvider.textColor(context)),
            ),

            // 진도(progress) 텍스트
            Text(
              studyProvider.getWordgroupProgressText(words),
              style: ThemeProvider.metaCountStyle(
                context,
              ).copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// WordGroupList:
/// - Wordbook 객체 하나를 받아 내부의 wordgroups Map을 순회하며
///   WordGroupBasicCard를 생성
/// - 카드 클릭 시 자동으로 WordListScreen으로 네비게이션 처리
class WordGroupList extends StatelessWidget {
  final Wordbook wordbook;

  const WordGroupList({super.key, required this.wordbook});

  void _navigateToWordList(
    BuildContext context,
    String groupKey,
    List<WordCard> words,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WordListScreen(
              title: groupKey,
              words:
                  words
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
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);

    return CardContainer(
      isDarkMode: ThemeProvider.isDark(context),
      children: [
        // wordbook.wordgroups는 Map<String, WordGroup> 형태라고 가정
        ...wordbook.wordgroups.entries.map((entry) {
          final groupKey = entry.key;
          final wordgroup = entry.value; // WordGroup 객체 안에 List<WordCard> words

          return WordGroupBasicCard(
            groupKey: groupKey,
            words: wordgroup.words,
            studyProvider: studyProvider,
            onTap:
                () => _navigateToWordList(context, groupKey, wordgroup.words),
          );
        }),

        // 맨 아래 여유 공간
        ThemeProvider.gap8,
      ],
    );
  }
}
