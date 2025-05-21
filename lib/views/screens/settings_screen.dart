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
          title: const Text('메모리 학습 기록 초기화'),
          content: const Text(
            '메모리 단어장의 학습 기록이 초기화됩니다.\n정말 초기화하시겠습니까?',
            style: TextStyle(fontSize: 16),
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
                      content: Text('메모리 단어장 학습 기록이 초기화되었습니다.'),
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

  // 초기화 확인 다이얼로그를 보여주는 메서드
  Future<void> _showResetConfirmDialog(BuildContext context) async {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('학습 기록 초기화'),
          content: const Text(
            '모든 단어의 학습 기록이 삭제됩니다.\n정말 초기화하시겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '예',
                style: TextStyle(color: Colors.red), // 위험 동작임을 표시
              ),
              onPressed: () async {
                await studyProvider.resetAllStudyStates();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  // 초기화 완료 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 학습 기록이 초기화되었습니다.'),
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
            title: Text('설정', style: ThemeProvider.settingsBarStyle),
          ),
          body: ListView(
            children: [
              // 계정 섹션 추가
              ListTile(
                leading: const Icon(Icons.account_circle, size: 32),
                title: const Text('로그인'),
                subtitle: const Text('Coming soon...'),
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
                title: const Text('테마'),
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
              ListTile(
                title: const Text('메인 색상'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ColorOption(
                      color: ThemeProvider.gray,
                      isSelected: themeProvider.mainColor == ThemeProvider.gray,
                      onTap:
                          () => themeProvider.setMainColor(ThemeProvider.gray),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.pastelRed,
                      isSelected:
                          themeProvider.mainColor == ThemeProvider.pastelRed,
                      onTap:
                          () => themeProvider.setMainColor(
                            ThemeProvider.pastelRed,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.pastelOrange,
                      isSelected:
                          themeProvider.mainColor == ThemeProvider.pastelOrange,
                      onTap:
                          () => themeProvider.setMainColor(
                            ThemeProvider.pastelOrange,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.pastelYellow,
                      isSelected:
                          themeProvider.mainColor == ThemeProvider.pastelYellow,
                      onTap:
                          () => themeProvider.setMainColor(
                            ThemeProvider.pastelYellow,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.pastelGreen,
                      isSelected:
                          themeProvider.mainColor == ThemeProvider.pastelGreen,
                      onTap:
                          () => themeProvider.setMainColor(
                            ThemeProvider.pastelGreen,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.pastelBlue,
                      isSelected:
                          themeProvider.mainColor == ThemeProvider.pastelBlue,
                      onTap:
                          () => themeProvider.setMainColor(
                            ThemeProvider.pastelBlue,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _ColorOption(
                      color: ThemeProvider.pastelIndigo,
                      isSelected:
                          themeProvider.mainColor == ThemeProvider.pastelIndigo,
                      onTap:
                          () => themeProvider.setMainColor(
                            ThemeProvider.pastelIndigo,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // 마지막으로 본 시간 설정
              SwitchListTile(
                title: const Text('단어장 학습 시간 표시'),
                subtitle: const Text('단어장에서 마지막으로 학습한 시간을 표시합니다'),
                value: themeProvider.showLastViewedTime,
                onChanged: (bool value) {
                  themeProvider.toggleLastViewedTime();
                },
                activeColor: themeProvider.mainColor,
                activeTrackColor: trackColor,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),

              // 학습 기록 초기화 옵션
              ListTile(
                title: const Text('단어장 학습 시간 초기화'),
                subtitle: const Text('단어장에서 마지막으로 학습한 시간을 초기화합니다'),
                trailing: Icon(Icons.restore, color: themeProvider.mainColor),
                onTap: () => _showResetConfirmDialog(context),
              ),
              const Divider(),

              SwitchListTile(
                title: const Text('메모리 학습 정보 표시'),
                subtitle: const Text('아는정도, 복습간격, 연속정답, 최근학습 정보를 표시합니다'),
                value: themeProvider.showMemoryParams,
                onChanged: (_) => themeProvider.toggleMemoryParams(),
                activeColor: themeProvider.mainColor,
                activeTrackColor: trackColor,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),

              ListTile(
                title: const Text('메모리 학습 정보 초기화'),
                subtitle: const Text('메모리 학습 정보를 초기화합니다'),
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
