import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/views/screens/settings_screen.dart';

class WordListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final String title;

  const WordListScreen({
    Key? key,
    required this.words,
    required this.title,
  }) : super(key: key);

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> with SingleTickerProviderStateMixin {
  bool showHiragana = false;
  bool showMeaning = false;
  late List<Map<String, dynamic>> currentWords;
  late StudyProvider _studyProvider;

  @override
  void initState() {
    super.initState();
    currentWords = List<Map<String, dynamic>>.from(widget.words);
    _studyProvider = Provider.of<StudyProvider>(context, listen: false);
    _studyProvider.addToRecentLists(widget.title, widget.words);
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
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: themeProvider.mainColor,
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
          body: studyProvider.isFlashcardMode
              ? FlashcardView(
                  words: currentWords,
                  showHiragana: showHiragana,
                  showMeaning: showMeaning,
                  onCardTap: _toggleBoth,
                  showTimeAgo: themeProvider.showLastViewedTime,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: currentWords.length,
                  itemBuilder: (context, index) {
                    final word = currentWords[index];
                    final wordId = word['id'].toString();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _toggleBoth();
                          studyProvider.updateTempWordState(wordId);
                        },
                        child: WordListItem(
                          word: word,
                          showHiragana: showHiragana,
                          showMeaning: showMeaning,
                          isFlashcardMode: false,
                          timeAgo: themeProvider.showLastViewedTime
                              ? _getTimeAgoText(studyProvider, wordId)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    context,
                    text: studyProvider.isFlashcardMode ? '목록모드' : '단어장모드',
                    isSelected: studyProvider.isFlashcardMode,
                    onPressed: studyProvider.toggleFlashcardMode,
                    alwaysActive: true,
                  ),
                  _buildButton(
                    context,
                    text: 'シャッフル',
                    isSelected: studyProvider.isShuffleMode,
                    onPressed: () {
                      studyProvider.toggleShuffleMode();
                      _shuffleWords();  // 셔플 모드 토글 시 항상 새로운 순서로 섞기
                    },
                  ),
                  _buildButton(
                    context,
                    text: '히라가나',
                    isSelected: showHiragana,
                    onPressed: () {
                      setState(() {
                        showHiragana = !showHiragana;
                      });
                    },
                  ),
                  _buildButton(
                    context,
                    text: '뜻',
                    isSelected: showMeaning,
                    onPressed: () {
                      setState(() {
                        showMeaning = !showMeaning;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        side: BorderSide(
          color: alwaysActive || isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
        backgroundColor: alwaysActive || isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: alwaysActive || isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
      ),
    );
  }

  String _getTimeAgoText(StudyProvider studyProvider, String wordId) {
    // getWordState 대신 getEffectiveWordState 사용
    final wordState = studyProvider.getEffectiveWordState(wordId);
    return wordState?.timeAgoText ?? '아직 학습하지 않음';
  }
}

class WordListItem extends StatelessWidget {
  final Map<String, dynamic> word;
  final bool showHiragana;
  final bool showMeaning;
  final bool isFlashcardMode;
  final String? timeAgo;

  const WordListItem({
    Key? key,
    required this.word,
    required this.showHiragana,
    required this.showMeaning,
    this.isFlashcardMode = false,
    this.timeAgo,
  }) : super(key: key);

  Widget _buildMemoryQualityButtons(BuildContext context, String wordId) {
    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        if (!provider.isMemoryMode) return const SizedBox.shrink();
        
        return Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              '기억한 정도',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return ElevatedButton(
                  onPressed: () {
                    provider.updateMemoryState(wordId, index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text('$index'),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isFlashcardMode ? MediaQuery.of(context).size.height * 0.7 : 180,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (timeAgo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  timeAgo!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            Container(
              height: 32,
              alignment: Alignment.center,
              child: showHiragana
                ? Text(
                    word['읽기'],
                    style: TextStyle(
                      fontSize: word['단어'].toString().length > 2 ? 16 : 18,
                      color: Colors.grey[700],
                    ),
                  )
                : null,
            ),
            Text(
              word['단어'],
              style: TextStyle(
                fontSize: word['단어'].toString().length > 2 ? 48 : 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 32,
              alignment: Alignment.center,
              child: showMeaning
                ? Text(
                    word['뜻'],
                    style: TextStyle(
                      fontSize: word['단어'].toString().length > 2 ? 16 : 18,
                      color: Colors.grey[700],
                    ),
                  )
                : null,
            ),
            if (showHiragana && showMeaning)
              _buildMemoryQualityButtons(context, word['id']),
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
  final VoidCallback onCardTap;
  final bool showTimeAgo;

  const FlashcardView({
    Key? key,
    required this.words,
    required this.showHiragana,
    required this.showMeaning,
    required this.onCardTap,
    required this.showTimeAgo,
  }) : super(key: key);

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
        final wordState = context.read<StudyProvider>().getWordState(word['id'].toString());
        
        return GestureDetector(
          onTap: widget.onCardTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: WordListItem(
                word: word,
                showHiragana: widget.showHiragana,
                showMeaning: widget.showMeaning,
                isFlashcardMode: true,
                timeAgo: widget.showTimeAgo ? wordState?.timeAgoText : null,
              ),
            ),
          ),
        );
      },
    );
  }
} 