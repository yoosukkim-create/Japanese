import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese/providers/study_provider.dart';

class WordListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> words;
  final String title;

  const WordListScreen({
    Key? key,
    required this.words,
    required this.title,
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
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          body: studyProvider.isFlashcardMode
              ? FlashcardView(words: sortedWords)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: sortedWords.length,
                  itemBuilder: (context, index) {
                    final word = sortedWords[index];
                    final wordState = studyProvider.getWordState(word['id'].toString());
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: WordListItem(
                        word: word,
                        showHiragana: studyProvider.showHiragana,
                        showMeaning: studyProvider.showMeaning,
                        timeAgo: wordState?.timeAgoText,
                        isFlashcardMode: studyProvider.isFlashcardMode,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
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
  final bool isFlashcardMode;

  const WordListItem({
    Key? key,
    required this.word,
    required this.showHiragana,
    required this.showMeaning,
    this.timeAgo,
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
            if (timeAgo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  timeAgo!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: WordListItem(
              word: word,
              showHiragana: context.watch<StudyProvider>().showHiragana,
              showMeaning: context.watch<StudyProvider>().showMeaning,
              timeAgo: wordState?.timeAgoText,
              isFlashcardMode: true,
            ),
          ),
        );
      },
    );
  }
} 