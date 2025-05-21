class WordMemoryState {
  final String wordId;
  double ef; // Easiness Factor
  int interval; // 다음 복습까지 남은 날짜
  int repetition; // 연속 정답 횟수
  DateTime? lastReviewedAt; // 마지막 복습 시간

  WordMemoryState({
    required this.wordId,
    this.ef = 2.5,
    this.interval = 1,
    this.repetition = 0,
    this.lastReviewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'ef': ef,
      'interval': interval,
      'repetition': repetition,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    };
  }

  factory WordMemoryState.fromJson(Map<String, dynamic> json) {
    return WordMemoryState(
      wordId: json['wordId'],
      ef: json['ef'] ?? 2.5,
      interval: json['interval'] ?? 1,
      repetition: json['repetition'] ?? 0,
      lastReviewedAt:
          json['lastReviewedAt'] != null
              ? DateTime.parse(json['lastReviewedAt'])
              : null,
    );
  }

  void updateWithQuality(int quality) {
    if (quality < 3) {
      repetition = 0;
      interval = 1;
    } else {
      repetition += 1;
      if (repetition == 1) {
        interval = 1;
      } else if (repetition == 2) {
        interval = 6;
      } else {
        interval = (interval * ef).round();
      }
    }

    // EF 업데이트
    ef += (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    ef = ef < 1.3 ? 1.3 : ef;

    lastReviewedAt = DateTime.now();
  }

  bool needsReview() {
    if (lastReviewedAt == null) return true;
    final daysSinceLastReview =
        DateTime.now().difference(lastReviewedAt!).inDays;
    return daysSinceLastReview >= interval;
  }
}
