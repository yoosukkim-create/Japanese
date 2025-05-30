import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/views/screens/memory_mode_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';
import 'package:japanese/widgets/card_container.dart';

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
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = ThemeProvider.memoryIconImage(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final haloColor =
                  ThemeProvider.isDark(context)
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4);
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _HaloPainter(color: haloColor),
                ),
              );
            },
          ),
          RawMaterialButton(
            onPressed: widget.onPressed,
            shape: const CircleBorder(),
            fillColor: Colors.transparent,
            constraints: BoxConstraints.tightFor(width: size, height: size),
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

class _HaloPainter extends CustomPainter {
  final Color color;
  const _HaloPainter({required this.color});

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

  void _navigateToWordList(
    BuildContext context,
    String title,
    List<WordCard> words,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WordListScreen(
              title: title,
              words:
                  words
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
  }

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
        padding: ThemeProvider.bottomPadding,
        children: [
          CardContainer(
            isDarkMode: ThemeProvider.isDark(context),
            children: [
              ...wordbook.wordgroups.entries.map((entry) {
                final key = entry.key;
                final wordgroup = entry.value;

                return InkWell(
                  onTap:
                      () => _navigateToWordList(context, key, wordgroup.words),
                  child: Padding(
                    padding: ThemeProvider.cardPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          key,
                          style: ThemeProvider.cardListStyle(
                            context,
                          ).copyWith(color: ThemeProvider.textColor(context)),
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
              ThemeProvider.gap8,
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: ThemeProvider.memoryIconPadding,
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
