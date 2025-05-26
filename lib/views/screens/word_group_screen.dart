import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/memory_mode_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';
import 'package:japanese/widgets/list_card.dart';

class AnimatedHaloButton extends StatefulWidget {
  final VoidCallback onPressed;
  const AnimatedHaloButton({super.key, required this.onPressed});

  @override
  State<AnimatedHaloButton> createState() => _AnimatedHaloButtonState();
}

class _AnimatedHaloButtonState extends State<AnimatedHaloButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // 계속 회전
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ThemeProvider.memoryIconImage(context),
      height: ThemeProvider.memoryIconImage(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 회전 애니메이션
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final haloColor =
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4);
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: CustomPaint(
                  size: Size(
                    ThemeProvider.memoryIconImage(context),
                    ThemeProvider.memoryIconImage(context),
                  ),
                  painter: HaloPainter(color: haloColor),
                ),
              );
            },
          ),
          // 버튼 이미지
          RawMaterialButton(
            onPressed: widget.onPressed,
            shape: const CircleBorder(),
            fillColor: Colors.transparent,
            constraints: BoxConstraints.tightFor(
              width: ThemeProvider.memoryIconImage(context),
              height: ThemeProvider.memoryIconImage(context),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/memory_transparent.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HaloPainter extends CustomPainter {
  final Color color;

  HaloPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final path =
        Path()
          ..addArc(Rect.fromLTWH(0, 0, size.width, size.height), 0, pi * 1.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WordGroupScreen extends StatelessWidget {
  final Wordbook wordbook;

  const WordGroupScreen({super.key, required this.wordbook});

  @override
  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  Color cardColor(BuildContext context) =>
      isDarkMode(context) ? ThemeProvider.cardBlack : ThemeProvider.cardWhite;
  Color textColor(BuildContext context) =>
      isDarkMode(context) ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Align(
          alignment: ThemeProvider.globalBarAlignment,
          child: Text(
            wordbook.title,
            style: ThemeProvider.globalBarStyle(
              context,
            ).copyWith(color: themeProvider.mainColor),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24.0),
        children: [
          CardContainer(
            isDarkMode: isDarkMode(context),
            children: [
              const CardTitle('단어 그룹 목록'),
              ...wordbook.wordgroups.entries.map((entry) {
                final key = entry.key;
                final wordgroup = entry.value;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WordListScreen(
                              title: key,
                              words:
                                  wordgroup.words
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
                  },
                  child: Padding(
                    padding: ThemeProvider.cardPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          key,
                          style: ThemeProvider.cardListStyle(
                            context,
                          ).copyWith(color: textColor(context)),
                        ),
                        Text(
                          studyProvider.getWordgroupProgressText(
                            wordgroup.words,
                          ),
                          style: ThemeProvider.metaCountStyle(
                            context,
                          ).copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AnimatedHaloButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemoryModeScreen(wordbook: wordbook),
              ),
            );
          },
        ),
      ),
    );
  }
}
