import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(),
            SizedBox(height: 20),
            WordListPlaceholder(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 단어 추가 기능 구현 예정
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        tooltip: '단어 추가',
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('일본어 학습'),
      centerTitle: true,
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: '단어 검색...',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }
}

class WordListPlaceholder extends StatelessWidget {
  const WordListPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 0, // TODO: 단어 개수로 교체
        itemBuilder: (context, index) {
          return const SizedBox.shrink(); // TODO: 단어 카드 위젯으로 교체
        },
      ),
    );
  }
}
