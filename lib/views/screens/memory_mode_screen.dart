import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/japanese_level.dart';
import '../../providers/theme_provider.dart';
import '../../providers/study_provider.dart';

class MemoryModeScreen extends StatefulWidget {
  final JapaneseLevel level;

  const MemoryModeScreen({
    Key? key,
    required this.level,
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
    _allWords = _getAllWordsFromLevel(widget.level);
  }

  List<Map<String, dynamic>> _getAllWordsFromLevel(JapaneseLevel level) {
    List<Map<String, dynamic>> words = [];
    level.subLevels.values.forEach((sublevel) {
      words.addAll(sublevel.words.map((word) => {
        'id': '${word.word}_${word.reading}',
        '단어': word.word,
        '읽기': word.reading,
        '뜻': word.meaning,
      }));
    });
    return words;
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
        borderRadius: BorderRadius.circular(15.0),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word['단어'],
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_showAnswer) ...[
                const SizedBox(height: 24),
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
                const SizedBox(height: 32),
                const Text(
                  '이 단어를 얼마나 잘 기억하시나요?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<StudyProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMemoryButton(
                          context: context,
                          text: '모름',
                          color: Colors.redAccent,
                          onPressed: () {
                            provider.updateMemoryState(word['id'], 1);
                            _moveToNextWord();
                          },
                        ),
                        _buildMemoryButton(
                          context: context,
                          text: '애매함',
                          color: Colors.orangeAccent,
                          onPressed: () {
                            provider.updateMemoryState(word['id'], 3);
                            _moveToNextWord();
                          },
                        ),
                        _buildMemoryButton(
                          context: context,
                          text: '잘 암',
                          color: Colors.green,
                          onPressed: () {
                            provider.updateMemoryState(word['id'], 5);
                            _moveToNextWord();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
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
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 100,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
          _moveToNextWord();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, StudyProvider>(
      builder: (context, themeProvider, studyProvider, child) {
        final sortedWords = studyProvider.getSortedWordsForMemoryMode(_allWords);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${widget.level.title} - 메모리 모드',
              style: TextStyle(
                color: themeProvider.mainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
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