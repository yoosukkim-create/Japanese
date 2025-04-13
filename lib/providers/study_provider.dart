import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:japanese/models/word_study_state.dart';
import 'package:japanese/models/japanese_level.dart';

class StudyProvider extends ChangeNotifier {
  final Map<String, WordStudyState> _wordStates = {};
  final Map<String, DateTime> _tempWordStates = {};
  
  bool _isFlashcardMode = false;
  bool _isShuffleMode = false;
  bool _showHiragana = false;
  bool _showMeaning = false;

  bool get isFlashcardMode => _isFlashcardMode;
  bool get isShuffleMode => _isShuffleMode;
  bool get showHiragana => _showHiragana;
  bool get showMeaning => _showMeaning;

  StudyProvider() {
    _loadStates();
  }

  Future<void> _loadStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesJson = prefs.getString('word_states');
    if (statesJson != null) {
      final Map<String, dynamic> statesMap = json.decode(statesJson);
      _wordStates.clear();
      statesMap.forEach((key, value) {
        _wordStates[key] = WordStudyState.fromJson(value);
      });
      notifyListeners();
    }
  }

  Future<void> _saveStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesMap = _wordStates.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString('word_states', json.encode(statesMap));
  }

  void toggleFlashcardMode() {
    _isFlashcardMode = !_isFlashcardMode;
    if (!_isFlashcardMode) {
      _isShuffleMode = false;
    }
    notifyListeners();
  }

  void setShuffleMode(bool value) {
    _isShuffleMode = value;
  }

  void toggleShuffleMode() {
    _isShuffleMode = !_isShuffleMode;
    notifyListeners();
  }

  void toggleHiragana() {
    _showHiragana = !_showHiragana;
    notifyListeners();
  }

  void toggleMeaning() {
    _showMeaning = !_showMeaning;
    notifyListeners();
  }

  void updateWordState(String wordId) {
    final now = DateTime.now();
    final currentState = _wordStates[wordId];
    
    _wordStates[wordId] = WordStudyState(
      wordId: wordId,
      lastViewedAt: now,
      wasHiraganaViewed: _showHiragana || (currentState?.wasHiraganaViewed ?? false),
      wasMeaningViewed: _showMeaning || (currentState?.wasMeaningViewed ?? false),
    );
    
    _saveStates();
    notifyListeners();
  }

  void updateTempWordState(String wordId) {
    _tempWordStates[wordId] = DateTime.now();
  }

  Future<void> commitTempStates() async {
    if (_tempWordStates.isEmpty) return;

    _tempWordStates.forEach((wordId, lastViewedAt) {
      final currentState = _wordStates[wordId];
      _wordStates[wordId] = WordStudyState(
        wordId: wordId,
        lastViewedAt: lastViewedAt,
        wasHiraganaViewed: _showHiragana || (currentState?.wasHiraganaViewed ?? false),
        wasMeaningViewed: _showMeaning || (currentState?.wasMeaningViewed ?? false),
      );
    });

    _tempWordStates.clear();

    await _saveStates();
    notifyListeners();
  }

  void clearTempStates() {
    _tempWordStates.clear();
  }

  WordStudyState? getEffectiveWordState(String wordId) {
    if (_tempWordStates.containsKey(wordId)) {
      final currentState = _wordStates[wordId];
      return WordStudyState(
        wordId: wordId,
        lastViewedAt: _tempWordStates[wordId]!,
        wasHiraganaViewed: _showHiragana || (currentState?.wasHiraganaViewed ?? false),
        wasMeaningViewed: _showMeaning || (currentState?.wasMeaningViewed ?? false),
      );
    }
    return _wordStates[wordId];
  }

  List<String> getSortedWordIds(List<String> originalIds) {
    if (!_isShuffleMode) return originalIds;

    return List<String>.from(originalIds)..sort((a, b) {
      final stateA = _wordStates[a];
      final stateB = _wordStates[b];
      
      if (stateA == null) return -1;
      if (stateB == null) return 1;
      
      final daysA = stateA.nextReviewDays;
      final daysB = stateB.nextReviewDays;
      
      if (daysA == daysB) {
        return stateA.lastViewedAt.compareTo(stateB.lastViewedAt);
      }
      return daysA.compareTo(daysB);
    });
  }

  WordStudyState? getWordState(String wordId) => _wordStates[wordId];

  List<Map<String, dynamic>> getSortedWords(List<Map<String, dynamic>> words) {
    if (!_isShuffleMode) {
      return List<Map<String, dynamic>>.from(words);
    }

    final shuffledWords = List<Map<String, dynamic>>.from(words);
    final random = Random();
    
    for (var i = shuffledWords.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffledWords[i];
      shuffledWords[i] = shuffledWords[j];
      shuffledWords[j] = temp;
    }

    return shuffledWords;
  }

  // 특정 단어 목록의 학습 현황을 반환하는 메서드
  String getProgressText(List<Map<String, dynamic>> words) {
    int totalWords = words.length;
    int studiedWords = words.where((word) {
      final state = getWordState(word['id'].toString());
      return state != null;
    }).length;
    
    return '$studiedWords/$totalWords';
  }

  // 레벨의 전체 학습 현황을 반환하는 메서드
  String getLevelProgressText(Map<String, SubLevel> subLevels) {
    int totalWords = 0;
    int studiedWords = 0;

    subLevels.forEach((_, subLevel) {
      totalWords += subLevel.words.length;
      studiedWords += subLevel.words.where((word) {
        final state = getWordState('${word.word}_${word.reading}');
        return state != null;
      }).length;
    });

    return '$studiedWords/$totalWords';
  }

  // 서브레벨의 학습 현황을 반환하는 메서드
  String getSubLevelProgressText(List<WordCard> words) {
    int totalWords = words.length;
    int studiedWords = words.where((word) {
      final state = getWordState('${word.word}_${word.reading}');
      return state != null;
    }).length;
    
    return '$studiedWords/$totalWords';
  }
} 