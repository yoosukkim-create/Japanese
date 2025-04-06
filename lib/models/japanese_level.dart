// 최상위 레벨 (JLPT N5 등)
class JapaneseLevel {
  final String title;  // "레벨 1 (JLPT N5)"
  final Map<String, SubLevel> subLevels;  // "레벨 1-1" 등

  JapaneseLevel({
    required this.title,
    required this.subLevels,
  });

  factory JapaneseLevel.fromJson(String title, Map<String, dynamic> json) {
    Map<String, SubLevel> subLevels = {};
    json.forEach((key, value) {
      subLevels[key] = SubLevel.fromJson(key, value as List<dynamic>);
    });
    return JapaneseLevel(title: title, subLevels: subLevels);
  }
}

// 서브 레벨 (레벨 1-1 등)
class SubLevel {
  final String title;  // "레벨 1-1"
  final List<WordCard> words;

  SubLevel({
    required this.title,
    required this.words,
  });

  factory SubLevel.fromJson(String title, List<dynamic> json) {
    return SubLevel(
      title: title,
      words: json.map((word) => WordCard.fromJson(word)).toList(),
    );
  }
}

// 단어 카드
class WordCard {
  final String id;     // 고유 식별자
  final String word;    // 단어
  final String reading; // 읽기
  final String meaning; // 뜻

  WordCard({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
  });

  factory WordCard.fromJson(Map<String, dynamic> json) {
    return WordCard(
      id: '${json['단어']}_${json['읽기']}',  // 단어와 읽기를 조합하여 고유 ID 생성
      word: json['단어'] ?? '',
      reading: json['읽기'] ?? '',
      meaning: json['뜻'] ?? '',
    );
  }
} 