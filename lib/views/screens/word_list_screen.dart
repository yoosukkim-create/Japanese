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

class _WordListScreenState extends State<WordListScreen>
    with SingleTickerProviderStateMixin {
  bool showHiragana = false;
  bool showMeaning = false;
  late List<Map<String, dynamic>> currentWords;
  late StudyProvider _studyProvider;
  final Map<String, bool> _hiraganaShown = {};
  final Map<String, bool> _meaningShown = {};

  @override
  void initState() {
    super.initState();
    currentWords = List<Map<String, dynamic>>.from(widget.words);
    _studyProvider = Provider.of<StudyProvider>(context, listen: false);
    _studyProvider.addToRecentLists(widget.title, widget.words);
  }

  void _toggleWordState(String wordId) {
    final currentHira = _hiraganaShown[wordId] ?? showHiragana;
    final currentMean = _meaningShown[wordId] ?? showMeaning;

    final shouldTurnOff = currentHira && currentMean;

    setState(() {
      // 둘 다 켜져 있으면 -> 둘 다 끔
      if (shouldTurnOff) {
        _hiraganaShown[wordId] = false;
        _meaningShown[wordId] = false;
      } else {
        // 하나라도 꺼져 있으면 -> 둘 다 켬
        _hiraganaShown[wordId] = true;
        _meaningShown[wordId] = true;
      }

      // 이걸 여기에 두면 안됨: 전역 상태는 개별 토글 시 바꾸면 안돼!
      // showHiragana = _hiraganaShown[wordId]!;
      // showMeaning = _meaningShown[wordId]!;
    });
  }

  @override
  void dispose() {
    _studyProvider.commitTempStates();
    _studyProvider.setShuffleMode(false);
    super.dispose();
  }

  // 단어 순서를 섞는 함수
  void _shuffleWords() {
    setState(() {
      if (_studyProvider.isShuffleMode) {
        // 셔플 모드가 켜질 때마다 새로운 순서로 섞기
        currentWords = _studyProvider.getSortedWords(widget.words);
      } else {
        // 셔플 모드가 꺼지면 원래 순서로 복원
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
                alignment: ThemeProvider.appBarAlignment,
                child: Text(
                  widget.title,
                  style: ThemeProvider.mainBarStyle(
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
            body:
                studyProvider.isFlashcardMode
                    ? FlashcardView(
                      words: currentWords,
                      showHiragana: showHiragana,
                      showMeaning: showMeaning,
                      showExamples: showExamples,
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
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
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      Expanded(child: _buildButtonByIndex(context, i)),
                      if (i < 3) const SizedBox(width: 8),
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

  void _toggleBoth() {
    setState(() {
      if (showHiragana && showMeaning) {
        showHiragana = false;
        showMeaning = false;
      } else {
        showHiragana = true;
        showMeaning = true;
      }
    });
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
    bool alwaysActive = false,
  }) {
    final color =
        alwaysActive || isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ThemeProvider.wordlistCornerRadius,
          ),
        ),
        side: BorderSide(color: color),
        backgroundColor:
            alwaysActive || isSelected ? color.withOpacity(0.1) : null,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: color),
      ),
    );
  }
}

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
    // padding 상하 합 32, 섹션 사이 간격 12
    const double verticalPadding = 32.0;
    const double midSpacing = 12.0;

    // 1) 전체 높이(fullHeight)와 반절 높이(halfHeight) 계산
    final double fullHeight =
        isFlashcardMode ? MediaQuery.of(context).size.height * 0.7 : 320.0;
    final double halfHeight = (fullHeight - verticalPadding - midSpacing) / 2;

    // 2) collapsedHeight: 예문 숨김 시 카드 전체 높이
    final double collapsedHeight = fullHeight - halfHeight - midSpacing;

    // 3) 카드 높이 결정 (flashcard 모드면 무조건 fullHeight)
    final bool hasExampleForHeight = isFlashcardMode || showExamples;
    final double containerHeight =
        hasExampleForHeight ? fullHeight : collapsedHeight;

    // 4) 섹션 높이 계산
    final double sectionHeight =
        hasExampleForHeight ? halfHeight : (containerHeight - verticalPadding);

    // 5) 예문 섹션 렌더링 여부 (오직 showExamples 만 체크)
    final bool hasExampleForContent = showExamples;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeProvider.wordlistCornerRadius),
      ),
      child: Container(
        width: double.infinity,
        height: containerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // 상단 단어 영역
            SizedBox(
              height: sectionHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 히라가나
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      showHiragana ? (word['읽기'] ?? '') : ' ',
                      style: ThemeProvider.wordReadMean(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 단어 (한자)
                  Text(
                    word['단어'] ?? '',
                    style:
                        isFlashcardMode
                            ? ThemeProvider.wordText(context)
                            : ThemeProvider.wordTextSmall(context),
                    textAlign: TextAlign.center,
                  ),
                  // 뜻
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      showMeaning ? (word['뜻'] ?? '') : ' ',
                      style: ThemeProvider.wordReadMean(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // 예문 영역 (오직 showExamples가 true일 때만)
            if (hasExampleForContent) ...[
              const SizedBox(height: midSpacing),
              SizedBox(
                height: sectionHeight,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 예문 읽기(히라가나)
                      Flexible(
                        child: Text(
                          showHiragana ? (word['예문읽기'] ?? '') : ' ',
                          style: ThemeProvider.exampleReadMean(context),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      // 예문
                      Flexible(
                        child: Text(
                          word['예문'] ?? '',
                          style: ThemeProvider.exampleText(context),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                      // 예문 뜻
                      Flexible(
                        child: Text(
                          showMeaning ? (word['예문뜻'] ?? '') : ' ',
                          style: ThemeProvider.exampleReadMean(context),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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

    // 초기 상태 반영
    for (var word in widget.words) {
      final wordId = word['id'].toString();
      _hiraganaShown[wordId] = widget.showHiragana;
      _meaningShown[wordId] = widget.showMeaning;
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 히라가나 전역 토글 반영
    if (oldWidget.showHiragana != widget.showHiragana) {
      setState(() {
        for (var word in widget.words) {
          final wordId = word['id'].toString();
          _hiraganaShown[wordId] = widget.showHiragana;
        }
      });
    }

    // 뜻 전역 토글 반영
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
        context.read<StudyProvider>().updateWordState(
          widget.words[index]['id'].toString(),
        );
      },
      itemBuilder: (context, index) {
        final word = widget.words[index];
        final wordId = word['id'].toString();
        final wordState = context.read<StudyProvider>().getWordState(wordId);

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
