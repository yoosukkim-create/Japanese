import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('테마'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              ),
              ListTile(
                title: const Text('메인 색상'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ColorOption(
                      color: ThemeProvider.navyBlue,
                      isSelected: themeProvider.mainColor == ThemeProvider.navyBlue,
                      onTap: () => themeProvider.setMainColor(ThemeProvider.navyBlue),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.cherryBlossom,
                      isSelected: themeProvider.mainColor == ThemeProvider.cherryBlossom,
                      onTap: () => themeProvider.setMainColor(ThemeProvider.cherryBlossom),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
} 