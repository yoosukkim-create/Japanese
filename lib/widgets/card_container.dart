import 'package:flutter/material.dart';
import 'package:japanese/providers/theme_provider.dart';

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
