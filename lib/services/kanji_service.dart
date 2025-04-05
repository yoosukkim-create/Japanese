import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/kanji_item.dart';

class KanjiService {
  Future<List<KanjiItem>> loadKanjiData() async {
    try {
      // assets에서 JSON 파일 로드
      final String jsonString = 
          await rootBundle.loadString('assets/data/kanji_data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // JSON 데이터를 KanjiItem 객체로 변환
      return jsonData.map((data) => KanjiItem.fromJson(data)).toList();
    } catch (e) {
      throw Exception('한자 데이터를 불러오는데 실패했습니다: $e');
    }
  }
} 