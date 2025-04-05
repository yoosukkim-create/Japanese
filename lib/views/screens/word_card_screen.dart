import 'package:flutter/material.dart';
import '../../models/japanese_level.dart';

// 단어 카드 화면
class WordCardScreen extends StatelessWidget {
  final SubLevel subLevel;

  const WordCardScreen({Key? key, required this.subLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subLevel.title)),
      body: ListView.builder(
        itemCount: subLevel.words.length,
        itemBuilder: (context, index) {
          return FlipWordCard(word: subLevel.words[index]);
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