import 'package:flutter/material.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/widgets/card_container.dart';

class RecentWordBookCard extends StatelessWidget {
  final StudyProvider studyProvider;
  final ThemeProvider themeProvider;
  final void Function(Map<String, dynamic>) onTap;

  const RecentWordBookCard({
    super.key,
    required this.studyProvider,
    required this.themeProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CardContainer(
      isDarkMode: isDark,
      children: [
        studyProvider.recentWordLists.isEmpty
            ? _buildEmptyCard(context)
            : _buildRecentListItem(context),
      ],
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Padding(
      padding: ThemeProvider.cardPadding,
      child: _buildPinnedRow(
        context,
        iconSize: ThemeProvider.cardIconImage(context),
        text: '아직 확인한 단어장이 없습니다',
        textStyle: ThemeProvider.cardExplainStyle(context),
      ),
    );
  }

  Widget _buildRecentListItem(BuildContext context) {
    final list = studyProvider.recentWordLists[0];
    final title = list['title'].toString();
    final words = List<Map<String, dynamic>>.from(list['words'] as List);

    return InkWell(
      onTap: () => onTap(list),
      child: Padding(
        padding: ThemeProvider.cardPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPinnedRow(
              context,
              iconSize: ThemeProvider.cardIconImage(context),
              text: title,
              textStyle: ThemeProvider.cardListStyle(context),
            ),
            Text(
              studyProvider.getProgressText(words),
              style: ThemeProvider.metaCountStyle(
                context,
              ).copyWith(color: themeProvider.mainColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedRow(
    BuildContext context, {
    required double iconSize,
    required String text,
    required TextStyle textStyle,
  }) {
    return Row(
      children: [
        Transform.rotate(
          angle: -3.14 / 4,
          child: Icon(
            Icons.push_pin,
            color: themeProvider.mainColor,
            size: iconSize,
          ),
        ),
        ThemeProvider.gap8,
        ThemeProvider.gap8,
        Text(text, style: textStyle),
      ],
    );
  }
}
