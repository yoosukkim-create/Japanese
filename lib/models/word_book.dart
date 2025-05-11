// 최상위 레벨 (JLPT N5 등)
class Wordbook {
  final String title;  // "레벨 1 (JLPT N5)"
  final Map<String, WordGroup> wordgroups;  // "레벨 1-1" 등

  Wordbook({
    required this.title,
    required this.wordgroups,
  });

  factory Wordbook.fromJson(String title, Map<String, dynamic> json) {
    Map<String, WordGroup> wordgroups = {};
    json.forEach((key, value) {
      wordgroups[key] = WordGroup.fromJson(key, value as List<dynamic>);
    });
    return Wordbook(title: title, wordgroups: wordgroups);
  }
}

// 서브 레벨 (레벨 1-1 등)
class WordGroup {
  final String title;  // "레벨 1-1"
  final List<WordCard> words;

  WordGroup({
    required this.title,
    required this.words,
  });

  factory WordGroup.fromJson(String title, List<dynamic> json) {
    return WordGroup(
      title: title,
      words: json.map((word) => WordCard.fromJson(word)).toList(),
    );
  }
}

// 단어 카드
class WordCard {
  final String id;           // 고유 식별자
  final String word;         // 단어
  final String reading;      // 읽기
  final String meaning;      // 뜻
  final String example;      // 예문
  final String exampleReading; // 예문 읽기
  final String exampleMeaning; // 예문 뜻

  WordCard({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    required this.example,
    required this.exampleReading,
    required this.exampleMeaning,
  });

  factory WordCard.fromJson(Map<String, dynamic> json) {
    return WordCard(
      id: '${json['단어']}_${json['읽기']}',
      word: json['단어'] ?? '',
      reading: json['읽기'] ?? '',
      meaning: json['뜻'] ?? '',
      example: json['예문'] ?? '',
      exampleReading: json['예문읽기'] ?? '',
      exampleMeaning: json['예문뜻'] ?? '',
    );
  }
}
