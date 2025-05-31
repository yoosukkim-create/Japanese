import 'package:flutter/material.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/widgets/card_container.dart';

class CustomWordbookCard extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool Function(BuildContext) isDarkMode;

  const CustomWordbookCard({
    super.key,
    required this.themeProvider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      isDarkMode: isDarkMode(context),
      children: [
        Center(
          child: Padding(
            padding: ThemeProvider.plusIconPadding,
            child: Icon(
              Icons.add_circle_outline,
              size: ThemeProvider.plusIconImage(context),
              color: themeProvider.mainColor,
            ),
          ),
        ),
      ],
    );
  }
}
