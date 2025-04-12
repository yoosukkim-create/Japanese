import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              '설정',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          body: ListView(
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
              // 마지막으로 본 시간 설정
              SwitchListTile(
                title: const Text('마지막으로 본 시간 표시'),
                subtitle: const Text('각 단어를 마지막으로 학습한 시간을 표시합니다'),
                value: themeProvider.showLastViewedTime,
                onChanged: (bool value) {
                  themeProvider.toggleLastViewedTime();
                },
              ),
              const Divider(),
            ],
          ),
        );
      },
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