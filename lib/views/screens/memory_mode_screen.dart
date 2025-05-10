import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/word_book.dart';
import '../../providers/theme_provider.dart';
import '../../providers/study_provider.dart';


class MemoryModeScreen extends StatefulWidget {
  final Wordbook wordbook;

  const MemoryModeScreen({
    Key? key,
    required this.wordbook,
  }) : super(key: key);

  @override
  State<MemoryModeScreen> createState() => _MemoryModeScreenState();
}

class _MemoryModeScreenState extends State<MemoryModeScreen> {
  List<Map<String, dynamic>> _allWords = [];
  bool _showAnswer = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final rawWords = _getAllWordsFromWordbook(widget.wordbook);
    _allWords = _shuffleWithoutConsecutiveDuplicates(rawWords);
  }

  List<Map<String, dynamic>> _getAllWordsFromWordbook(Wordbook wordbook) {
    List<Map<String, dynamic>> words = [];
    wordbook.wordgroups.values.forEach((wordgroup) {
      words.addAll(wordgroup.words.map((word) => {
        'id': '${word.word}_${word.reading}',
        '단어': word.word,
        '읽기': word.reading,
        '뜻': word.meaning,
      }));
    });
    return words;
  }

  List<Map<String, dynamic>> _shuffleWithoutConsecutiveDuplicates(List<Map<String, dynamic>> words) {
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
      _showAnswer = false;
      if (_currentIndex < _allWords.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  Widget _buildMemoryCard(Map<String, dynamic> word) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _showAnswer = !_showAnswer;
          });
        },
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: Consumer<StudyProvider>(
                  builder: (context, provider, child) {
                    final memoryState = provider.getMemoryState(word['id']);
                    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

                    if (!themeProvider.showMemoryParams) return const SizedBox.shrink();

                    final ef = memoryState?.ef.toStringAsFixed(1) ?? '2.5';
                    final interval = memoryState?.interval.toString() ?? '0';
                    final repetition = memoryState?.repetition.toString() ?? '0';
                    final lastReviewedText = (memoryState != null && memoryState.lastReviewedAt != null)
                        ? _formatDate(memoryState.lastReviewedAt!)
                        : '미학습';

                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '아는정도: $ef\n복습간격: ${interval}일\n연속정답: ${repetition}회\n최근학습: $lastReviewedText',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Text(
                          word['단어'],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: _showAnswer ? 300 : 0),
                        opacity: _showAnswer ? 1.0 : 0.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              word['읽기'],
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              word['뜻'],
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedOpacity(
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
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMemoryButton(
                                context: context,
                                text: '모름',
                                color: Colors.redAccent,
                                onPressed: _showAnswer
                                    ? () {
                                        Provider.of<StudyProvider>(context, listen: false)
                                            .updateMemoryState(word['id'], 1);
                                        _moveToNextWord();
                                      }
                                    : null,
                              ),
                              _buildMemoryButton(
                                context: context,
                                text: '애매함',
                                color: Colors.orangeAccent,
                                onPressed: _showAnswer
                                    ? () {
                                        Provider.of<StudyProvider>(context, listen: false)
                                            .updateMemoryState(word['id'], 3);
                                        _moveToNextWord();
                                      }
                                    : null,
                              ),
                              _buildMemoryButton(
                                context: context,
                                text: '잘 암',
                                color: Colors.green,
                                onPressed: _showAnswer
                                    ? () {
                                        Provider.of<StudyProvider>(context, listen: false)
                                            .updateMemoryState(word['id'], 5);
                                        _moveToNextWord();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
            borderRadius: BorderRadius.circular(ThemeProvider.defaultCornerRadius),
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
    return Consumer2<ThemeProvider, StudyProvider>(
      builder: (context, themeProvider, studyProvider, child) {
        final sortedWords = studyProvider.getSortedWordsForMemoryMode(_allWords);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${widget.wordbook.title}',
              style: TextStyle(
                color: themeProvider.mainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: sortedWords.isEmpty
                ? const Center(child: Text('학습할 단어가 없습니다.'))
                : _buildMemoryCard(sortedWords[_currentIndex]),
          ),
        );
      },
    );
  }
} 