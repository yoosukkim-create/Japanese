import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/widgets/resolution_guard.dart';

import 'package:japanese/views/screens/settings_screen.dart';

class WordListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final String title;

  const WordListScreen({super.key, required this.words, required this.title});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  bool showHiragana = false;
  bool showMeaning = false;
  late List<Map<String, dynamic>> currentWords;
  late StudyProvider _studyProvider;
  final Map<String, bool> _hiraganaShown = {};
  final Map<String, bool> _meaningShown = {};

  @override
  void initState() {
    super.initState();
    // 위젯 생성 시 단어 목록 복사
    currentWords = List<Map<String, dynamic>>.from(widget.words);
    _studyProvider = Provider.of<StudyProvider>(context, listen: false);
    // 최근 본 단어장에 추가
    _studyProvider.addToRecentLists(widget.title, widget.words);
  }

  void _toggleWordState(String wordId) {
    // 단어별 히라가나/뜻 표시 상태를 토글
    final currentHira = _hiraganaShown[wordId] ?? showHiragana;
    final currentMean = _meaningShown[wordId] ?? showMeaning;
    final shouldTurnOff = currentHira && currentMean;

    setState(() {
      if (shouldTurnOff) {
        // 둘 다 켜져 있으면 모두 끔
        _hiraganaShown[wordId] = false;
        _meaningShown[wordId] = false;
      } else {
        // 하나라도 꺼져 있으면 모두 켬
        _hiraganaShown[wordId] = true;
        _meaningShown[wordId] = true;
      }
    });
  }

  @override
  void dispose() {
    // 화면 나갈 때 임시 스테이트 커밋(저장)
    _studyProvider.commitTempStates();
    // 셔플 모드 해제
    _studyProvider.setShuffleMode(false);
    super.dispose();
  }

  /// 단어 셔플 모드를 토글하고, 순서를 다시 계산
  void _shuffleWords() {
    setState(() {
      if (_studyProvider.isShuffleMode) {
        // 셔플 모드 활성화: 무작위 정렬
        currentWords = _studyProvider.getSortedWords(widget.words);
      } else {
        // 셔플 모드 비활성화: 원래 순서 복원
        currentWords = List<Map<String, dynamic>>.from(widget.words);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResolutionGuard(
      child: Consumer<StudyProvider>(
        builder: (context, studyProvider, child) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final showExamples = studyProvider.showExamples;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Align(
                alignment: ThemeProvider.globalBarAlignment,
                child: Text(
                  widget.title,
                  style: ThemeProvider.globalBarStyle(
                    context,
                  ).copyWith(color: themeProvider.mainColor),
                ),
              ),
              actions: [
                Consumer<StudyProvider>(
                  builder:
                      (context, study, _) => IconButton(
                        icon: Icon(
                          study.showExamples
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        tooltip: study.showExamples ? '예문 숨기기' : '예문 보기',
                        onPressed: study.toggleShowExamples,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // 바디: 플래시카드 모드냐 리스트 모드냐 선택
            body:
                studyProvider.isFlashcardMode
                    ? FlashcardView(
                      words: currentWords,
                      showHiragana: showHiragana,
                      showMeaning: showMeaning,
                      showExamples: showExamples,
                    )
                    : ListView.builder(
                      padding: ThemeProvider.cardPadding,
                      itemCount: currentWords.length,
                      itemBuilder: (context, index) {
                        final word = currentWords[index];
                        final wordId = word['id'].toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              _toggleWordState(wordId);
                              studyProvider.updateTempWordState(wordId);
                            },
                            child: WordListItem(
                              word: word,
                              showHiragana: _hiraganaShown[wordId] ?? false,
                              showMeaning: _meaningShown[wordId] ?? false,
                              showExamples: showExamples,
                              isFlashcardMode: false,
                            ),
                          ),
                        );
                      },
                    ),

            // 하단 네비게이션 버튼 4개
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: ThemeProvider.cardPadding,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      Expanded(child: _buildButtonByIndex(context, i)),
                      if (i < 3) ThemeProvider.gap8,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonByIndex(BuildContext context, int index) {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    switch (index) {
      case 0:
        return _buildButton(
          context,
          text: studyProvider.isFlashcardMode ? '목록모드' : '단어장모드',
          isSelected: studyProvider.isFlashcardMode,
          onPressed: studyProvider.toggleFlashcardMode,
          alwaysActive: true,
        );

      case 1:
        return _buildButton(
          context,
          text: 'シャッフル',
          isSelected: studyProvider.isShuffleMode,
          onPressed: () {
            studyProvider.toggleShuffleMode();
            _shuffleWords();
          },
        );

      case 2:
        return _buildButton(
          context,
          text: '히라가나',
          isSelected: showHiragana,
          onPressed: () {
            setState(() {
              showHiragana = !showHiragana;
              for (var word in currentWords) {
                final wordId = word['id'].toString();
                _hiraganaShown[wordId] = showHiragana;
              }
            });
          },
        );

      case 3:
        return _buildButton(
          context,
          text: '뜻',
          isSelected: showMeaning,
          onPressed: () {
            setState(() {
              showMeaning = !showMeaning;
              for (var word in currentWords) {
                final wordId = word['id'].toString();
                _meaningShown[wordId] = showMeaning;
              }
            });
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
    bool alwaysActive = false,
  }) {
    final color =
        (alwaysActive || isSelected)
            ? Theme.of(context).primaryColor
            : Colors.grey;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeProvider.globalCornerRadius),
        ),
        side: BorderSide(color: color),
        backgroundColor:
            (alwaysActive || isSelected) ? color.withOpacity(0.1) : null,
        padding: ThemeProvider.memoryButtonPadding,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: TextAlign.center,
        style: ThemeProvider.wordListBottomStyle(
          context,
        ).copyWith(color: color),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//                              WordListItem (카드 한 줄)
// ──────────────────────────────────────────────────────────────────────────────
class WordListItem extends StatelessWidget {
  final Map<String, dynamic> word;
  final bool showHiragana;
  final bool showMeaning;
  final bool showExamples;
  final bool isFlashcardMode;

  const WordListItem({
    super.key,
    required this.word,
    required this.showHiragana,
    required this.showMeaning,
    required this.showExamples,
    this.isFlashcardMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // 카드 배경 색을 다크/라이트 모드에 맞춤
    final bgColor =
        ThemeProvider.isDark(context)
            ? ThemeProvider.cardBlack
            : ThemeProvider.cardWhite;

    return Card(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeProvider.globalCornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        // Column에 mainAxisSize.min을 지정하여, 자식들이 필요한 만큼만 높이를 차지
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── 상단 단어/히라가나/뜻 영역 ────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ───── 히라가나 ────────────────────────────
                Visibility(
                  visible: showHiragana,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      word['읽기'] ?? '',
                      style: ThemeProvider.wordReadMean(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // ───── 단어 (한자) ──────────────────────────
                Text(
                  word['단어'] ?? '',
                  style:
                      isFlashcardMode
                          ? ThemeProvider.wordText(context)
                          : ThemeProvider.wordTextSmall(context),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // ───── 뜻 ─────────────────────────────────
                Visibility(
                  visible: showMeaning,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      word['뜻'] ?? '',
                      style: ThemeProvider.wordReadMean(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            // ─── 예문 영역 (showExamples 토글 시 투명/표시) ───────────
            const SizedBox(height: 12.0),
            Visibility(
              visible: showExamples,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(
                    ThemeProvider.globalCornerRadius * 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─── 예문 읽기(히라가나) ─────────────────
                    Visibility(
                      visible: showHiragana,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Text(
                        word['예문읽기'] ?? '',
                        style: ThemeProvider.exampleReadMean(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ─── 예문 본문 ─────────────────────────────
                    Text(
                      word['예문'] ?? '',
                      style: ThemeProvider.exampleText(context),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ─── 예문 뜻 ───────────────────────────────
                    Visibility(
                      visible: showMeaning,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Text(
                        word['예문뜻'] ?? '',
                        style: ThemeProvider.exampleReadMean(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//                             FlashcardView (플래시카드 모드)
// ──────────────────────────────────────────────────────────────────────────────
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: WordListItem(
                word: word,
                showHiragana: _hiraganaShown[wordId] ?? false,
                showMeaning: _meaningShown[wordId] ?? false,
                showExamples: widget.showExamples,
                isFlashcardMode: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
