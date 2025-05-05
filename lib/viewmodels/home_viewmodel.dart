// ✅ home_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:japanese/models/word_book.dart';
import 'package:japanese/services/japanese_data_service.dart';

class HomeViewModel extends ChangeNotifier {
  final JapaneseDataService _dataService = JapaneseDataService();

  List<Wordbook> _wordbooks = [];
  bool _isLoading = true;
  String _error = '';
  Timer? _debounce;

  final TextEditingController searchController = TextEditingController();

  List<Wordbook> get wordbooks => _wordbooks;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _wordbooks = await _dataService.loadJapaneseData();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchWords(String query, Function(List<Map<String, dynamic>>) onResult, Function(String) onError) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) return;

      try {
        final results = await _dataService.searchWords(query);
        if (results.isNotEmpty) {
          onResult(results);
        } else {
          onError('검색 결과가 없습니다.');
        }
      } catch (e) {
        onError('검색 중 오류가 발생했습니다: \$e');
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}