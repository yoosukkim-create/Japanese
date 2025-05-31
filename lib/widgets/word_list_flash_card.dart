// lib/views/widgets/flashcard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';

// WordListItem을 먼저 import
import 'package:japanese/widgets/word_list_card.dart';

/// FlashcardView: 플래시카드 모드 전용 위젯
class FlashcardView extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final bool showHiragana;
  final bool showMeaning;
  final bool showExamples;

  const FlashcardView({
    super.key,
    required this.words,
    required this.showHiragana,
    required this.showMeaning,
    required this.showExamples,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  final Map<String, bool> _hiraganaShown = {};
  final Map<String, bool> _meaningShown = {};
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 처음 생성 시, 전달받은 플래시카드 모드 초기값 반영
    for (var word in widget.words) {
      final wordId = word['id'].toString();
      _hiraganaShown[wordId] = widget.showHiragana;
      _meaningShown[wordId] = widget.showMeaning;
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상단 히라가나 토글이 바뀌면 전부 반영
    if (oldWidget.showHiragana != widget.showHiragana) {
      setState(() {
        for (var word in widget.words) {
          final wordId = word['id'].toString();
          _hiraganaShown[wordId] = widget.showHiragana;
        }
      });
    }
    // 상단 뜻 토글이 바뀌면 전부 반영
    if (oldWidget.showMeaning != widget.showMeaning) {
      setState(() {
        for (var word in widget.words) {
          final wordId = word['id'].toString();
          _meaningShown[wordId] = widget.showMeaning;
        }
      });
    }
  }

  void _toggleCardState(String wordId) {
    // 카드 한 장에 한해서만 히라가나/뜻 토글
    final currentHira = _hiraganaShown[wordId] ?? false;
    final currentMean = _meaningShown[wordId] ?? false;
    final shouldTurnOff = currentHira && currentMean;

    setState(() {
      _hiraganaShown[wordId] = !shouldTurnOff;
      _meaningShown[wordId] = !shouldTurnOff;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.words.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
        // 페이지가 바뀔 때마다 상태 저장
        context.read<StudyProvider>().updateWordState(
          widget.words[index]['id'].toString(),
        );
      },
      itemBuilder: (context, index) {
        final word = widget.words[index];
        final wordId = word['id'].toString();

        return GestureDetector(
          onTap: () => _toggleCardState(wordId),
          child: Padding(
            // 화면 가장자리에는 동일한 패딩을 주고, 그 안에서 카드가 꽉 차도록
            padding: const EdgeInsets.all(16.0),
            child: WordListItem(
              word: word,
              showHiragana: _hiraganaShown[wordId] ?? false,
              showMeaning: _meaningShown[wordId] ?? false,
              showExamples: widget.showExamples,
              isFlashcardMode: true,
            ),
          ),
        );
      },
    );
  }
}
