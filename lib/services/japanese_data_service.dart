import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:japanese/models/word_book.dart';

class JapaneseDataService {
  Future<List<Wordbook>> loadJapaneseData() async {
    try {
      // assets에서 JSON 파일 로드
      final String jsonString = 
          await rootBundle.loadString('assets/data/kanji_data.json');
      
      // JSON 파싱
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Wordbook 객체 리스트로 변환
      List<Wordbook> wordbooks = [];
      jsonData.forEach((key, value) {
        wordbooks.add(Wordbook.fromJson(key, value));
      });
      
      return wordbooks;
    } catch (e) {
      throw Exception('데이터 로드 실패: $e');
    }
  }

  // 검색 결과를 담을 클래스
  Future<List<Map<String, dynamic>>> searchWords(String query) async {
    if (query.isEmpty) return [];

    try {
      final String jsonString = await rootBundle.loadString('assets/data/kanji_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      List<Map<String, dynamic>> results = [];

      // 모든 레벨과 서브레벨을 순회하며 검색
      jsonData.forEach((wordbookKey, wordbookData) {
        wordbookData.forEach((wordgroupKey, words) {
          for (var word in words) {
            // 한자 검색 (단어)
            if (_isKanji(query) && word['단어'].toString().contains(query)) {
              results.add({
                'id': '${word['단어']}_${word['읽기']}',
                '단어': word['단어'],
                '읽기': word['읽기'],
                '뜻': word['뜻'],
              });
            }
            // 히라가나 검색 (읽기)
            else if (_isHiragana(query) && word['읽기'].toString().contains(query)) {
              results.add({
                'id': '${word['단어']}_${word['읽기']}',
                '단어': word['단어'],
                '읽기': word['읽기'],
                '뜻': word['뜻'],
              });
            }
            // 한글 검색 (뜻)
            else if (_isKorean(query) && word['뜻'].toString().contains(query)) {
              results.add({
                'id': '${word['단어']}_${word['읽기']}',
                '단어': word['단어'],
                '읽기': word['읽기'],
                '뜻': word['뜻'],
              });
            }
          }
        });
      });

      return results;
    } catch (e) {
      throw Exception('검색 중 오류 발생: $e');
    }
  }

  // 문자열이 한자를 포함하는지 확인
  bool _isKanji(String text) {
    return RegExp(r'[\u4e00-\u9faf]').hasMatch(text);
  }

  // 문자열이 히라가나를 포함하는지 확인
  bool _isHiragana(String text) {
    return RegExp(r'[\u3040-\u309f]').hasMatch(text);
  }

  // 문자열이 한글을 포함하는지 확인
  bool _isKorean(String text) {
    return RegExp(r'[가-힣]').hasMatch(text);
  }
} 