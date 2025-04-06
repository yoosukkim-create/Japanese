import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:japanese/models/word_study_state.dart';

class StudyProvider extends ChangeNotifier {
  final Map<String, WordStudyState> _wordStates = {};
  bool _isFlashcardMode = false;
  bool _isMemoryMode = false;
  bool _showHiragana = false;
  bool _showMeaning = false;

  bool get isFlashcardMode => _isFlashcardMode;
  bool get isMemoryMode => _isMemoryMode;
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
      _isMemoryMode = false;
    }
    notifyListeners();
  }

  void toggleMemoryMode() {
    _isMemoryMode = !_isMemoryMode;
    if (_isMemoryMode) {
      _isFlashcardMode = true;
    }
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

  List<String> getSortedWordIds(List<String> originalIds) {
    if (!_isMemoryMode) return originalIds;

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
} 