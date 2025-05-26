import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/theme_provider.dart';

/// 카드 제목 위젯 (카드 바깥에 쓸 수도 있음)
class CardTitle extends StatelessWidget {
  final String title;

  const CardTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: ThemeProvider.cardPadding,
      child: Row(
        children: [
          Text(
            title,
            style: ThemeProvider.cardTitleStyle(
              context,
            ).copyWith(color: themeProvider.mainColor),
          ),
        ],
      ),
    );
  }
}

/// 카드 컨테이너 (배경 + 라운딩 + 내부 children 감쌈)
class CardContainer extends StatelessWidget {
  final List<Widget> children;
  final bool isDarkMode;

  const CardContainer({
    super.key,
    required this.children,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: ThemeProvider.cardMargin,
      elevation: 0,
      color: isDarkMode ? ThemeProvider.cardBlack : ThemeProvider.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeProvider.globalCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
