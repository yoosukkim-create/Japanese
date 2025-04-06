import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/models/word_study_state.dart';

class WordListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> words;

  const WordListScreen({
    Key? key,
    required this.words,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        final sortedWords = studyProvider.isMemoryMode
            ? studyProvider.getSortedWordIds(words.map((w) => w['id'].toString()).toList())
                .map((id) => words.firstWhere((w) => w['id'].toString() == id))
                .toList()
            : words;

        return Scaffold(
          body: studyProvider.isFlashcardMode
              ? FlashcardView(words: sortedWords)
              : ListView.builder(
                  itemCount: sortedWords.length,
                  itemBuilder: (context, index) {
                    final word = sortedWords[index];
                    final wordState = studyProvider.getWordState(word['id'].toString());
                    
                    return WordListItem(
                      word: word,
                      showHiragana: studyProvider.showHiragana,
                      showMeaning: studyProvider.showMeaning,
                      timeAgo: wordState?.timeAgoText,
                    );
                  },
                ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(8.0),
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
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    context,
                    text: studyProvider.isFlashcardMode ? '목록모드' : '단어장모드',
                    isSelected: studyProvider.isFlashcardMode,
                    onPressed: studyProvider.toggleFlashcardMode,
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
                    isSelected: studyProvider.showHiragana,
                    onPressed: studyProvider.toggleHiragana,
                  ),
                  _buildButton(
                    context,
                    text: '뜻',
                    isSelected: studyProvider.showMeaning,
                    onPressed: studyProvider.toggleMeaning,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
        backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
      ),
    );
  }
}

class WordListItem extends StatelessWidget {
  final Map<String, dynamic> word;
  final bool showHiragana;
  final bool showMeaning;
  final String? timeAgo;

  const WordListItem({
    Key? key,
    required this.word,
    required this.showHiragana,
    required this.showMeaning,
    this.timeAgo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHiragana) Text(
              word['읽기'],
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              word['단어'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (showMeaning) Text(
              word['뜻'],
              style: const TextStyle(fontSize: 14),
            ),
            if (timeAgo != null) Text(
              timeAgo!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardView extends StatefulWidget {
  final List<Map<String, dynamic>> words;

  const FlashcardView({
    Key? key,
    required this.words,
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
        
        return Center(
          child: WordListItem(
            word: word,
            showHiragana: context.watch<StudyProvider>().showHiragana,
            showMeaning: context.watch<StudyProvider>().showMeaning,
            timeAgo: wordState?.timeAgoText,
          ),
        );
      },
    );
  }
} 