import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';

class HomeViewModel extends ChangeNotifier {
  List<VocabularyItem> _vocabularyItems = [];
  
  List<VocabularyItem> get vocabularyItems => _vocabularyItems;

  // 나중에 구현할 메서드들
  void addVocabulary() {
    // 구현 예정
  }

  void removeVocabulary(int index) {
    // 구현 예정
  }
} 