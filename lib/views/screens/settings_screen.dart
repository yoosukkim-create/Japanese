import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _showMemoryResetConfirmDialog(BuildContext context) async {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? ThemeProvider.cardBlack
                  : ThemeProvider.cardWhite,
          title: Text(
            '메모리 학습 기록 초기화',
            style: ThemeProvider.settingsBarStyle(context),
          ),
          content: Text(
            '모든 단어장의 학습 기록이 초기화됩니다.\n정말 초기화하시겠습니까?',
            style: ThemeProvider.settingExplainStyle(context),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('예', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await studyProvider.resetAllMemoryStates();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 단어장 학습 기록이 초기화되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // 메인 색상을 기반으로 연한 색상 생성
        final Color lightColor = Color.alphaBlend(
          Colors.white.withOpacity(0.85),
          themeProvider.mainColor,
        );
        final Color trackColor = themeProvider.mainColor.withOpacity(0.3);

        return Scaffold(
          appBar: AppBar(
            title: Text('설정', style: ThemeProvider.settingsBarStyle(context)),
          ),
          body: ListView(
            children: [
              // 계정 섹션 추가
              ListTile(
                leading: const Icon(Icons.account_circle, size: 32),
                title: Text(
                  '로그인',
                  style: ThemeProvider.settingTitleStyle(context),
                ),
                subtitle: Text(
                  'Coming soon...',
                  style: ThemeProvider.settingExplainStyle(context),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('준비 중인 기능입니다.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  '테마',
                  style: ThemeProvider.settingTitleStyle(context),
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[800]
                            : Colors.white,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              ),
              const Divider(),

              SwitchListTile(
                title: Text(
                  '메모리 학습 정보 표시',
                  style: ThemeProvider.settingTitleStyle(context),
                ),
                subtitle: Text(
                  '복습간격, 연속정답, 최근학습 정보를 표시합니다',
                  style: ThemeProvider.settingExplainStyle(context),
                ),
                value: themeProvider.showMemoryParams,
                onChanged: (_) => themeProvider.toggleMemoryParams(),
                activeColor: themeProvider.mainColor,
                activeTrackColor: trackColor,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),

              ListTile(
                title: Text(
                  '메모리 학습 정보 초기화',
                  style: ThemeProvider.settingTitleStyle(context),
                ),
                subtitle: Text(
                  '복습간격, 연속정답, 최근학습 정보를 초기화합니다',
                  style: ThemeProvider.settingExplainStyle(context),
                ),
                trailing: Icon(Icons.restore, color: themeProvider.mainColor),
                onTap: () => _showMemoryResetConfirmDialog(context),
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
