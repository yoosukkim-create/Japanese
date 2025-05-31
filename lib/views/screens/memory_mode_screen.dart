import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/widgets/resolution_guard.dart';

import 'package:japanese/views/screens/settings_screen.dart';

class MemoryModeScreen extends StatefulWidget {
  final Wordbook wordbook;

  const MemoryModeScreen({super.key, required this.wordbook});

  @override
  State<MemoryModeScreen> createState() => _MemoryModeScreenState();
}

class _MemoryModeScreenState extends State<MemoryModeScreen> {
  List<Map<String, dynamic>> _allWords = [];
  bool _showAnswer = false;
  int _currentIndex = 0;
  late SignatureController _sigControllerWord;
  late SignatureController _sigControllerExample;

  @override
  void initState() {
    super.initState();
    _sigControllerWord = SignatureController(
      penStrokeWidth: 3,
      penColor: Provider.of<ThemeProvider>(context, listen: false).mainColor,
      exportBackgroundColor: Colors.transparent,
    );
    _sigControllerExample = SignatureController(
      penStrokeWidth: 3,
      penColor: Provider.of<ThemeProvider>(context, listen: false).mainColor,
      exportBackgroundColor: Colors.transparent,
    );
    final rawWords = _getAllWordsFromWordbook(widget.wordbook);
    _allWords = _shuffleWithoutConsecutiveDuplicates(rawWords);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newColor = Provider.of<ThemeProvider>(context).mainColor;

    // 단어용 컨트롤러 색상이 달라졌으면
    if (_sigControllerWord.penColor != newColor) {
      final oldPoints = List.of(_sigControllerWord.points);
      _sigControllerWord.dispose();
      _sigControllerWord = SignatureController(
        points: oldPoints,
        penStrokeWidth: 3,
        penColor: newColor,
        exportBackgroundColor: Colors.transparent,
      );
    }

    // 예문용 컨트롤러 색상이 달라졌으면
    if (_sigControllerExample.penColor != newColor) {
      final oldPoints = List.of(_sigControllerExample.points);
      _sigControllerExample.dispose();
      _sigControllerExample = SignatureController(
        points: oldPoints,
        penStrokeWidth: 3,
        penColor: newColor,
        exportBackgroundColor: Colors.transparent,
      );
    }
  }

  @override
  void dispose() {
    _sigControllerWord.dispose();
    _sigControllerExample.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getAllWordsFromWordbook(Wordbook wordbook) {
    List<Map<String, dynamic>> words = [];
    for (var wordgroup in wordbook.wordgroups.values) {
      words.addAll(
        wordgroup.words.map(
          (word) => {
            'id': '${word.word}_${word.reading}',
            '단어': word.word,
            '읽기': word.reading,
            '뜻': word.meaning,
            '예문': word.example,
            '예문읽기': word.exampleReading,
            '예문뜻': word.exampleMeaning,
          },
        ),
      );
    }
    return words;
  }

  List<Map<String, dynamic>> _shuffleWithoutConsecutiveDuplicates(
    List<Map<String, dynamic>> words,
  ) {
    if (words.isEmpty) return [];

    final random = Random();
    int attempt = 0;
    const maxAttempts = 100;

    while (attempt < maxAttempts) {
      final shuffled = List<Map<String, dynamic>>.from(words)..shuffle(random);
      bool hasConsecutiveDuplicate = false;

      for (int i = 0; i < shuffled.length - 1; i++) {
        if (shuffled[i]['id'] == shuffled[i + 1]['id']) {
          hasConsecutiveDuplicate = true;
          break;
        }
      }

      if (!hasConsecutiveDuplicate) {
        return shuffled;
      }
      attempt++;
    }

    return words; // fallback
  }

  void _moveToNextWord() {
    setState(() {
      _sigControllerWord.clear();
      _sigControllerExample.clear();
      _showAnswer = false;
      if (_currentIndex < _allWords.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  /// ========================
  /// ✅ 수정된 _buildMemoryCard:
  ///   - card를 가득 채우되 Visibility(maintainSize: true)로 toggle 시 공간 유지
  ///   - 상단 정보 / 중앙 콘텐츠 / 하단 평가 버튼을 `Column(mainAxisAlignment: spaceBetween)`으로 분리
  /// ========================
  Widget _buildMemoryCard(
    Map<String, dynamic> word,
    bool showExamples,
    bool showCanvas,
  ) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? ThemeProvider.cardBlack : ThemeProvider.cardWhite;

    return SizedBox.expand(
      child: Card(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeProvider.globalCornerRadius),
        ),
        child: InkWell(
          onTap: () => setState(() => _showAnswer = !_showAnswer),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // 상단 정보 / 중앙 콘텐츠 / 하단 평가 버튼을 세로로 분리
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ──────────────────────────────────
                // 1) 상단 정보(학습 상태) 영역
                Consumer<StudyProvider>(
                  builder: (ctx, prov, _) {
                    final mem = prov.getMemoryState(word['id']);
                    if (!Provider.of<ThemeProvider>(
                      ctx,
                      listen: false,
                    ).showMemoryParams) {
                      // showMemoryParams가 false면 빈 공간만 확보
                      return const SizedBox(height: 20);
                    }
                    final interval = mem?.interval.toString() ?? '0';
                    final rep = mem?.repetition.toString() ?? '0';
                    final last =
                        (mem != null && mem.lastReviewedAt != null)
                            ? _formatDate(mem.lastReviewedAt!)
                            : '미학습';
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '복습간격: $interval일  •  연속정답: $rep회  •  최근학습: $last',
                        style: ThemeProvider.metaDataStyle(ctx),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                // ──────────────────────────────────
                // 2) 중앙 콘텐츠 영역 (단어/읽기/뜻/예문/캔버스)
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 히라가나 (toggle)
                      Visibility(
                        visible: _showAnswer,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word['읽기'] ?? '',
                            style: ThemeProvider.wordReadMean(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 단어 본문 혹은 캔버스
                      if (showCanvas) ...[
                        // 캔버스 모드: Signature 위에 단어 텍스트로 표시
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(
                                ThemeProvider.globalCornerRadius,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (_) {}, // 탭만 소비
                                  child: Signature(
                                    controller: _sigControllerWord,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Visibility(
                                  visible: _showAnswer,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      word['단어'] ?? '',
                                      style: ThemeProvider.wordText(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // 일반 모드: 텍스트만
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word['단어'] ?? '',
                            style: ThemeProvider.wordText(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ──────────────────────────────────
                      // 뜻 영역: showCanvas==true면 항상 보이고, 그렇지 않으면 _showAnswer 기준으로 보임
                      Visibility(
                        visible: showCanvas || _showAnswer,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word['뜻'] ?? '',
                            style: ThemeProvider.wordReadMean(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ──────────────────────────────────
                      // 예문 영역
                      Visibility(
                        visible: showExamples,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Column(
                          children: [
                            // 예문 읽기 (히라가나)
                            Visibility(
                              visible: _showAnswer,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word['예문읽기'] ?? '',
                                  style: ThemeProvider.wordReadMean(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // 예문 본문
                            Visibility(
                              visible: !showCanvas || _showAnswer,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word['예문'] ?? '',
                                  style: ThemeProvider.exampleText(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // 예문 뜻
                            Visibility(
                              visible: _showAnswer,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word['예문뜻'] ?? '',
                                  style: ThemeProvider.exampleReadMean(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ──────────────────────────────────
                // 3) 하단 평가 버튼 영역
                //    (_showAnswer == true)일 때만 보이되, 유지 공간 확보
                Expanded(
                  flex: 3,
                  child: Visibility(
                    visible: _showAnswer,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '이 단어를 얼마나 잘 기억하시나요?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // 버튼 3개: FittedBox로 가로 공간 부족 시 축소
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMemoryButton(
                                context: context,
                                text: '모름',
                                color: Colors.redAccent,
                                onPressed:
                                    _showAnswer
                                        ? () {
                                          Provider.of<StudyProvider>(
                                            context,
                                            listen: false,
                                          ).updateMemoryState(word['id'], 1);
                                          _moveToNextWord();
                                        }
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              _buildMemoryButton(
                                context: context,
                                text: '애매함',
                                color: Colors.orangeAccent,
                                onPressed:
                                    _showAnswer
                                        ? () {
                                          Provider.of<StudyProvider>(
                                            context,
                                            listen: false,
                                          ).updateMemoryState(word['id'], 3);
                                          _moveToNextWord();
                                        }
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              _buildMemoryButton(
                                context: context,
                                text: '잘 암',
                                color: Colors.green,
                                onPressed:
                                    _showAnswer
                                        ? () {
                                          Provider.of<StudyProvider>(
                                            context,
                                            listen: false,
                                          ).updateMemoryState(word['id'], 5);
                                          _moveToNextWord();
                                        }
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    // 버튼 크기는 최대한 반응형으로, 가로폭에 맞게 줄어들도록 Flexible로 감싸도 됩니다.
    return SizedBox(
      width: 100,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeProvider.globalCornerRadius,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResolutionGuard(
      child: Consumer<StudyProvider>(
        builder: (context, studyProvider, child) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final showExamples = studyProvider.showExamples;
          final showCanvas = studyProvider.showCanvas;
          final sortedWords = studyProvider.getSortedWordsForMemoryMode(
            _allWords,
          );

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Align(
                alignment: ThemeProvider.globalBarAlignment,
                child: Text(
                  widget.wordbook.title,
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
                          study.showCanvas ? Icons.draw : Icons.draw_outlined,
                        ),
                        tooltip: study.showCanvas ? '캔버스 숨기기' : '캔버스 보기',
                        onPressed: study.toggleShowCanvas,
                      ),
                ),
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

            // Body 부분: Column + Expanded(_buildMemoryCard)로 변경
            body: Column(
              children: [
                Expanded(
                  child:
                      sortedWords.isEmpty
                          ? const Center(child: Text('학습할 단어가 없습니다.'))
                          : _buildMemoryCard(
                            sortedWords[_currentIndex],
                            showExamples,
                            showCanvas,
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
