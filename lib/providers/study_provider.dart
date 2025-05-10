import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:japanese/models/word_book.dart';
import 'package:japanese/models/word_memory_state.dart';
import 'package:japanese/models/word_study_state.dart';

class StudyProvider extends ChangeNotifier {
  // 학습 상태 관련
  final Map<String, WordStudyState> _wordStates = {};
  final Map<String, DateTime> _tempWordStates = {};

  // 모드 관련
  bool _isFlashcardMode = false;
  bool _isShuffleMode = false;
  bool _showHiragana = false;
  bool _showMeaning = false;
  bool _isMemoryMode = false;

  // 메모리 상태
  final Map<String, WordMemoryState> _memoryStates = {};

  // 최근 본 단어장
  static const int _maxRecentLists = 1;
  List<Map<String, dynamic>> _recentWordLists = [];

  // Getter
  bool get isFlashcardMode => _isFlashcardMode;
  bool get isShuffleMode => _isShuffleMode;
  bool get showHiragana => _showHiragana;
  bool get showMeaning => _showMeaning;
  bool get isMemoryMode => _isMemoryMode;
  List<Map<String, dynamic>> get recentWordLists => _recentWordLists;

  StudyProvider() {
    _loadStates();
  }

  // 상태 불러오기
  Future<void> _loadStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesJson = prefs.getString('word_states');
    if (statesJson != null) {
      final Map<String, dynamic> statesMap = json.decode(statesJson);
      _wordStates.clear();
      statesMap.forEach((key, value) {
        _wordStates[key] = WordStudyState.fromJson(value);
      });
    }

    final memoryStatesJson = prefs.getString('memory_states');
    if (memoryStatesJson != null) {
      final Map<String, dynamic> memoryStatesMap = json.decode(memoryStatesJson);
      _memoryStates.clear();
      memoryStatesMap.forEach((key, value) {
        _memoryStates[key] = WordMemoryState.fromJson(value);
      });
    }

    notifyListeners();
  }

  Future<void> _saveStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesMap = _wordStates.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString('word_states', json.encode(statesMap));
  }

  // 모드 토글 함수들
  void toggleFlashcardMode() {
    _isFlashcardMode = !_isFlashcardMode;
    if (!_isFlashcardMode) _isShuffleMode = false;
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

  void toggleMemoryMode() {
    _isMemoryMode = !_isMemoryMode;
    notifyListeners();
  }

  // 학습 상태 업데이트
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

  WordStudyState? getWordState(String wordId) => _wordStates[wordId];

  int getStudiedWordsCount(List<WordCard> words) {
    return words.where((word) {
      final state = getWordState('${word.word}_${word.reading}');
      return state != null;
    }).length;
  }

  // 정렬 관련
  List<String> getSortedWordIds(List<String> originalIds) {
    if (_isMemoryMode) {
      return List<String>.from(originalIds)..sort((a, b) {
        final stateA = _memoryStates[a];
        final stateB = _memoryStates[b];

        if (stateA == null) return -1;
        if (stateB == null) return 1;

        final needsReviewA = stateA.needsReview();
        final needsReviewB = stateB.needsReview();

        if (needsReviewA != needsReviewB) {
          return needsReviewA ? -1 : 1;
        }

        return stateA.ef.compareTo(stateB.ef);
      });
    }

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

  List<Map<String, dynamic>> getSortedWords(List<Map<String, dynamic>> words) {
    if (!_isShuffleMode) return List<Map<String, dynamic>>.from(words);

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

  // 진행률 텍스트 생성
  String getProgressText(List<dynamic> words) {
    try {
      int totalWords = words.length;
      int studiedWords = words.where((word) {
        final wordMap = Map<String, dynamic>.from(word);
        final id = '${wordMap['단어']}_${wordMap['읽기']}';
        return getWordState(id) != null;
      }).length;

      return '$studiedWords/$totalWords';
    } catch (e) {
      debugPrint('Error calculating progress: $e');
      return '0/0';
    }
  }

  String getWordbookProgressText(Map<String, WordGroup> wordgroups) {
    int totalWords = 0;
    int studiedWords = 0;

    wordgroups.forEach((_, wordgroup) {
      totalWords += wordgroup.words.length;
      studiedWords += wordgroup.words.where((word) {
        final state = getWordState('${word.word}_${word.reading}');
        return state != null;
      }).length;
    });

    return '$studiedWords/$totalWords';
  }

  String getWordgroupProgressText(List<WordCard> words) {
    int totalWords = words.length;
    int studiedWords = words.where((word) {
      final state = getWordState('${word.word}_${word.reading}');
      return state != null;
    }).length;

    return '$studiedWords/$totalWords';
  }

  // 최근 단어장 관리
  Future<void> addToRecentLists(String title, List<Map<String, dynamic>> words) async {
    try {
      final newItem = {
        'title': title,
        'words': words.map((word) => Map<String, dynamic>.from(word)).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      _recentWordLists = [newItem];
      await _saveRecentLists();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to recent lists: $e');
    }
  }

  Future<void> loadRecentLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentListsJson = prefs.getString('recent_word_lists');
      if (recentListsJson != null) {
        final List<dynamic> decoded = json.decode(recentListsJson);
        if (decoded.isNotEmpty) {
          _recentWordLists = [Map<String, dynamic>.from(decoded.first)];
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recent lists: $e');
      _recentWordLists = [];
    }
  }

  Future<void> _saveRecentLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recent_word_lists', json.encode(_recentWordLists));
    } catch (e) {
      debugPrint('Error saving recent lists: $e');
    }
  }

  // 상태 초기화
  Future<void> resetAllStudyStates() async {
    _wordStates.clear();
    _tempWordStates.clear();
    _recentWordLists.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('word_states');
    await prefs.remove('recent_word_lists');

    notifyListeners();
  }

  Future<void> resetAllMemoryStates() async {
    for (final state in _memoryStates.values) {
      state.ef = 2.5;
      state.interval = 1;
      state.repetition = 0;
      state.lastReviewedAt = null;
    }

    await _saveMemoryStates();
    notifyListeners();
  }

  Future<void> _loadMemoryStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesJson = prefs.getString('memory_states');
    if (statesJson != null) {
      final Map<String, dynamic> statesMap = json.decode(statesJson);
      _memoryStates.clear();
      statesMap.forEach((key, value) {
        _memoryStates[key] = WordMemoryState.fromJson(value);
      });
    }
  }

  Future<void> _saveMemoryStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesMap = _memoryStates.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString('memory_states', json.encode(statesMap));
  }

  void updateMemoryState(String wordId, int quality) {
    final state = _memoryStates[wordId] ?? WordMemoryState(wordId: wordId);
    state.updateWithQuality(quality);
    _memoryStates[wordId] = state;
    _saveMemoryStates();
    notifyListeners();
  }

  List<Map<String, dynamic>> getSortedWordsForMemoryMode(List<Map<String, dynamic>> words) {
    return List<Map<String, dynamic>>.from(words)..sort((a, b) {
      final stateA = _memoryStates[a['id']];
      final stateB = _memoryStates[b['id']];

      if (stateA == null) return -1;
      if (stateB == null) return 1;

      final needsReviewA = stateA.needsReview();
      final needsReviewB = stateB.needsReview();

      if (needsReviewA != needsReviewB) {
        return needsReviewA ? -1 : 1;
      }

      return stateA.ef.compareTo(stateB.ef);
    });
  }

  WordMemoryState? getMemoryState(String wordId) => _memoryStates[wordId];
} 
