import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/views/screens/word_group_screen.dart';
import 'package:japanese/widgets/card_container.dart';

class BasicWordBookCard extends StatelessWidget {
  final List<Wordbook> wordbooks;
  final ThemeProvider themeProvider;
  final bool Function(BuildContext) isDarkMode;

  const BasicWordBookCard({
    super.key,
    required this.wordbooks,
    required this.themeProvider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      isDarkMode: isDarkMode(context),
      children: [
        ...wordbooks.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final wordbook = entry.value;

          return InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordGroupScreen(wordbook: wordbook),
                  ),
                ),
            child: Padding(
              padding: ThemeProvider.cardPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: ThemeProvider.cardIconImage(context),
                        height: ThemeProvider.cardIconImage(context),
                        decoration: BoxDecoration(
                          color: themeProvider.mainColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Lv$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ThemeProvider.gap8,
                      ThemeProvider.gap8,
                      Text(
                        wordbook.title,
                        style: ThemeProvider.cardListStyle(context).copyWith(
                          color:
                              isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Consumer<StudyProvider>(
                    builder: (context, studyProvider, _) {
                      final totalWords = wordbook.wordgroups.values.fold(
                        0,
                        (sum, s) => sum + s.words.length,
                      );
                      final studiedWords = wordbook.wordgroups.values.fold(
                        0,
                        (sum, s) =>
                            sum + studyProvider.getStudiedWordsCount(s.words),
                      );
                      return Text(
                        '$studiedWords/$totalWords',
                        style: ThemeProvider.metaCountStyle(
                          context,
                        ).copyWith(color: themeProvider.mainColor),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        ThemeProvider.gap8,
      ],
    );
  }
}
