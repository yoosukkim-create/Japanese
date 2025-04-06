import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/study_provider.dart';

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

class _WordListScreenState extends State<WordListScreen> {
  bool showHiragana = false;
  bool showMeaning = false;
  int currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        final sortedWords = studyProvider.isMemoryMode
            ? studyProvider.getSortedWordIds(widget.words.map((w) => w['id'].toString()).toList())
                .map((id) => widget.words.firstWhere((w) => w['id'].toString() == id))
                .toList()
            : widget.words;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          body: studyProvider.isFlashcardMode
              ? FlashcardView(
                  words: sortedWords,
                  showHiragana: showHiragana,
                  showMeaning: showMeaning,
                  onCardTap: _toggleBoth,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: sortedWords.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: _toggleBoth,
                      child: WordListItem(
                        word: sortedWords[index],
                        showHiragana: showHiragana,
                        showMeaning: showMeaning,
                        isFlashcardMode: false,
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
                    text: studyProvider.isFlashcardMode ? '단어장모드' : '목록모드',
                    isSelected: false,
                    onPressed: studyProvider.toggleFlashcardMode,
                    alwaysActive: true,
                  ),
                  _buildButton(
                    context,
                    text: '메모리모드',
                    isSelected: studyProvider.isMemoryMode,
                    onPressed: studyProvider.toggleMemoryMode,
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
}

class WordListItem extends StatelessWidget {
  final Map<String, dynamic> word;
  final bool showHiragana;
  final bool showMeaning;
  final bool isFlashcardMode;

  const WordListItem({
    Key? key,
    required this.word,
    required this.showHiragana,
    required this.showMeaning,
    this.isFlashcardMode = false,
  }) : super(key: key);

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
            if (showHiragana)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  word['읽기'],
                  style: TextStyle(
                    fontSize: word['단어'].toString().length > 2 ? 16 : 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            Text(
              word['단어'],
              style: TextStyle(
                fontSize: word['단어'].toString().length > 2 ? 48 : 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showMeaning)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  word['뜻'],
                  style: TextStyle(
                    fontSize: word['단어'].toString().length > 2 ? 16 : 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),
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

  const FlashcardView({
    Key? key,
    required this.words,
    required this.showHiragana,
    required this.showMeaning,
    required this.onCardTap,
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
              ),
            ),
          ),
        );
      },
    );
  }
} 