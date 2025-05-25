import 'package:flutter/foundation.dart';

class WordStudyState {
  final String wordId; // 단어의 고유 식별자
  final DateTime lastViewedAt; // 마지막으로 본 시간
  final bool wasHiraganaViewed; // 히라가나를 본 적이 있는지
  final bool wasMeaningViewed; // 뜻을 본 적이 있는지

  WordStudyState({
    required this.wordId,
    required this.lastViewedAt,
    this.wasHiraganaViewed = false,
    this.wasMeaningViewed = false,
  });

  factory WordStudyState.fromJson(Map<String, dynamic> json) {
    return WordStudyState(
      wordId: json['wordId'],
      lastViewedAt: DateTime.parse(json['lastViewedAt']),
      wasHiraganaViewed: json['wasHiraganaViewed'] ?? false,
      wasMeaningViewed: json['wasMeaningViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'lastViewedAt': lastViewedAt.toIso8601String(),
      'wasHiraganaViewed': wasHiraganaViewed,
      'wasMeaningViewed': wasMeaningViewed,
    };
  }

  WordStudyState copyWith({
    String? wordId,
    DateTime? lastViewedAt,
    bool? wasHiraganaViewed,
    bool? wasMeaningViewed,
  }) {
    return WordStudyState(
      wordId: wordId ?? this.wordId,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      wasHiraganaViewed: wasHiraganaViewed ?? this.wasHiraganaViewed,
      wasMeaningViewed: wasMeaningViewed ?? this.wasMeaningViewed,
    );
  }

  int get nextReviewDays {
    if (!wasHiraganaViewed && !wasMeaningViewed) return 0;

    final daysSinceLastView = DateTime.now().difference(lastViewedAt).inDays;

    if (daysSinceLastView < 1) return 1;
    if (daysSinceLastView < 3) return 3;
    if (daysSinceLastView < 7) return 7;
    if (daysSinceLastView < 15) return 15;
    if (daysSinceLastView < 30) return 30;
    return -1; // 학습 완료
  }
}
