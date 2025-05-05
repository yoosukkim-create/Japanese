import 'package:flutter/material.dart';
import '../../models/word_book.dart';

// 단어 카드 화면
class WordCardScreen extends StatelessWidget {
  final WordGroup wordgroup;

  const WordCardScreen({Key? key, required this.wordgroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(wordgroup.title)),
      body: ListView.builder(
        itemCount: wordgroup.words.length,
        itemBuilder: (context, index) {
          return FlipWordCard(word: wordgroup.words[index]);
        },
      ),
    );
  }
}

// 뒤집히는 단어 카드 위젯
class FlipWordCard extends StatefulWidget {
  final WordCard word;

  const FlipWordCard({Key? key, required this.word}) : super(key: key);

  @override
  State<FlipWordCard> createState() => _FlipWordCardState();
}

class _FlipWordCardState extends State<FlipWordCard> {
  bool isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipped = !isFlipped;
        });
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                widget.word.word,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isFlipped) ...[
                const SizedBox(height: 8),
                Text(
                  widget.word.reading,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.word.meaning,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 