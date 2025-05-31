import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/widgets/resolution_guard.dart';
import 'package:japanese/widgets/word_list_card.dart';
import 'package:japanese/widgets/word_list_flash_card.dart';

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

            // ─────────────────────────────────────────────────────────
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

            // ─────────────────────────────────────────────────────────
            // 바텀 네비게이션 바 (토스 앱 스타일)
            bottomNavigationBar: _buildBottomNavBar(context, studyProvider),
          );
        },
      ),
    );
  }

  /// 바텀 네비게이션 바 전체를 만들고 반환
  Widget _buildBottomNavBar(BuildContext context, StudyProvider studyProvider) {
    // 현재 플래시카드 모드 활성 여부와 셔플 모드/읽기/뜻 상태
    final isFlash = studyProvider.isFlashcardMode;
    final isShuffle = studyProvider.isShuffleMode;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          // 살짝 그림자(토스 앱 느낌)
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      height: ThemeProvider.bottomBar(context), // 적당한 높이 (원하는 대로 조정)
      child: Row(
        children: [
          // 1) 카드/목록 토글
          Expanded(
            child: _buildNavItem(
              context: context,
              icon: isFlash ? Icons.view_list : Icons.credit_card,
              label: isFlash ? '목록' : '카드',
              isSelected: isFlash, // 플래시카드 모드 활성 시 파란색
              onTap: studyProvider.toggleFlashcardMode,
            ),
          ),

          // 2) 셔플
          Expanded(
            child: _buildNavItem(
              context: context,
              icon: Icons.shuffle,
              label: '셔플',
              isSelected: isShuffle,
              onTap: () {
                studyProvider.toggleShuffleMode();
                _shuffleWords();
              },
            ),
          ),

          // 3) 읽기(히라가나) 토글
          Expanded(
            child: _buildNavItem(
              context: context,
              icon: Icons.text_fields,
              label: '읽기',
              isSelected: showHiragana,
              onTap: () {
                setState(() {
                  showHiragana = !showHiragana;
                  for (var word in currentWords) {
                    final wordId = word['id'].toString();
                    _hiraganaShown[wordId] = showHiragana;
                  }
                });
              },
            ),
          ),

          // 4) 뜻(번역) 토글
          Expanded(
            child: _buildNavItem(
              context: context,
              icon: Icons.translate,
              label: '뜻',
              isSelected: showMeaning,
              onTap: () {
                setState(() {
                  showMeaning = !showMeaning;
                  for (var word in currentWords) {
                    final wordId = word['id'].toString();
                    _meaningShown[wordId] = showMeaning;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 바텀 네비게이션 바의 각각 아이템을 만드는 헬퍼
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).primaryColor;
    final color = isSelected ? primary : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: ThemeProvider.bottomIcon(context)),
          ThemeProvider.gap4,
          Text(
            label,
            style: ThemeProvider.wodListBottomStyle(
              context,
            ).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
