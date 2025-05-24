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
      // 기존에 그린 포인트들 보관
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

  // ✅ 오버플로우 없이 레이아웃을 자동으로 줄이도록 수정한 buildMemoryCard 버전
  Widget _buildMemoryCard(
    Map<String, dynamic> word,
    bool showExamples,
    bool showCanvas,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeProvider.wordlistCornerRadius),
      ),
      child: InkWell(
        onTap: () => setState(() => _showAnswer = !_showAnswer),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 상단 정보
              Align(
                alignment: Alignment.topRight,
                child: Consumer<StudyProvider>(
                  builder: (ctx, prov, _) {
                    final mem = prov.getMemoryState(word['id']);
                    if (!Provider.of<ThemeProvider>(
                      ctx,
                      listen: false,
                    ).showMemoryParams) {
                      return const SizedBox.shrink();
                    }
                    final ef = mem?.ef.toStringAsFixed(1) ?? '2.5';
                    final interval = mem?.interval.toString() ?? '0';
                    final rep = mem?.repetition.toString() ?? '0';
                    final last =
                        (mem != null && mem.lastReviewedAt != null)
                            ? _formatDate(mem.lastReviewedAt!)
                            : '미학습';
                    return Text(
                      '아는정도: $ef\n복습간격: $interval일\n연속정답: $rep회\n최근학습: $last',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ),

              // 중앙 컨텐츠
              Flexible(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 히라가나
                    Text(
                      _showAnswer ? (word['읽기'] ?? '') : ' ',
                      style: ThemeProvider.wordReadMean(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // ✅ 캔버스 모드일 때
                    if (showCanvas) ...[
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
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
                              Text(
                                _showAnswer ? (word['단어'] ?? '') : ' ',
                                style: ThemeProvider.wordText(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ] else ...[
                      // 일반 모드일 때
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          word['단어'] ?? '',
                          style: ThemeProvider.wordText(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    // 뜻
                    Text(
                      !showCanvas
                          ? (_showAnswer ? (word['뜻'] ?? '') : ' ')
                          : (word['뜻'] ?? ''),
                      style: ThemeProvider.wordReadMean(context),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // 예문 영역
                    if (showExamples) ...[
                      Text(
                        _showAnswer ? (word['예문읽기'] ?? '') : ' ',
                        style: ThemeProvider.wordReadMean(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),

                      if (showCanvas) ...[
                        SizedBox(
                          height: 80,
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (_) {},
                                  child: Signature(
                                    controller: _sigControllerExample,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Text(
                                  _showAnswer ? (word['예문'] ?? '') : ' ',
                                  style: ThemeProvider.exampleText(context),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          word['예문'] ?? '',
                          style: ThemeProvider.exampleText(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      Text(
                        _showAnswer ? (word['예문뜻'] ?? '') : ' ',
                        style: ThemeProvider.exampleReadMean(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              // 하단 평가 영역
              Flexible(
                flex: 3,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: _showAnswer ? 300 : 0),
                  opacity: _showAnswer ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      const Text(
                        '이 단어를 얼마나 잘 기억하시나요?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ FittedBox 적용: 버튼 3개를 줄바꿈 없이 축소해서 보여줌
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
    return SizedBox(
      width: 100,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeProvider.wordlistCornerRadius,
            ),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
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
                alignment: ThemeProvider.appBarAlignment,
                child: Text(
                  widget.wordbook.title,
                  style: ThemeProvider.subBarStyle(
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
                        tooltip: study.showCanvas ? '캔버스 숨기기' : '캔버 보기',
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
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  sortedWords.isEmpty
                      ? const Center(child: Text('학습할 단어가 없습니다.'))
                      : _buildMemoryCard(
                        sortedWords[_currentIndex],
                        showExamples,
                        showCanvas,
                      ),
            ),
          );
        },
      ),
    );
  }
}
