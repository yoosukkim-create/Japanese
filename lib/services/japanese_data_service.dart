import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/japanese_level.dart';

class JapaneseDataService {
  Future<List<JapaneseLevel>> loadJapaneseData() async {
    try {
      // assets에서 JSON 파일 로드
      final String jsonString = 
          await rootBundle.loadString('assets/data/kanji_data.json');
      
      // JSON 파싱
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // JapaneseLevel 객체 리스트로 변환
      List<JapaneseLevel> levels = [];
      jsonData.forEach((key, value) {
        levels.add(JapaneseLevel.fromJson(key, value));
      });
      
      return levels;
    } catch (e) {
      throw Exception('데이터 로드 실패: $e');
    }
  }
} 