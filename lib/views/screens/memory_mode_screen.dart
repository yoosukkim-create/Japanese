import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/widgets/resolution_guard.dart';
import 'package:japanese/widgets/memory_card.dart';

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

  @override
  void initState() {
    super.initState();
    _sigControllerWord = SignatureController(
      penStrokeWidth: 3,
      penColor: Provider.of<ThemeProvider>(context, listen: false).mainColor,
      exportBackgroundColor: Colors.transparent,
    );
    final rawWords = _getAllWordsFromWordbook(widget.wordbook);
    _allWords = rawWords;
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
  }

  @override
  void dispose() {
    _sigControllerWord.dispose();
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
      _showAnswer = false;
      if (_currentIndex < _allWords.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
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
                          : MemoryCard(
                            word: sortedWords[_currentIndex],
                            showExamples: showExamples,
                            showCanvas: showCanvas,
                            showAnswer: _showAnswer,
                            sigController: _sigControllerWord,
                            onToggleAnswer: () {
                              setState(() => _showAnswer = !_showAnswer);
                            },
                            onClearSignature: () {
                              _sigControllerWord.clear();
                            },
                            onMoveToNext: _moveToNextWord,
                            studyProvider: studyProvider,
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
