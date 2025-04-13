import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:japanese/models/japanese_level.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';
import 'package:japanese/services/japanese_data_service.dart';
import 'package:japanese/views/screens/home_screen.dart';
import 'package:japanese/views/screens/level_list_screen.dart';
import 'package:japanese/views/screens/word_list_screen.dart';
import 'package:japanese/theme/app_theme.dart';
import 'package:japanese/views/screens/sublevel_screen.dart';
import 'package:japanese/views/screens/word_card_screen.dart';
import 'package:japanese/views/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '메모리 メモリ',
          theme: themeProvider.themeData,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JapaneseDataService _dataService = JapaneseDataService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _error = '';
  List<JapaneseLevel> _levels = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
    // 최근 본 단어장 목록 로드
    Provider.of<StudyProvider>(context, listen: false).loadRecentLists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final levels = await _dataService.loadJapaneseData();
      
      setState(() {
        _levels = levels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 검색 처리 함수
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) return;

      try {
        final results = await _dataService.searchWords(query);
        if (results.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordListScreen(
                title: '"$query" 검색 결과',
                words: results,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('검색 결과가 없습니다.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    });
  }

  // 최근 본 단어장 위젯
  Widget _buildRecentLists(StudyProvider studyProvider, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.push_pin,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '최근 본 단어장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.mainColor,
                ),
              ),
            ],
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: studyProvider.recentWordLists.isEmpty
            ? const ListTile(
                title: Text(
                  '아직 확인한 단어장이 없습니다',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              )
            : ListTile(
                title: Text(
                  studyProvider.recentWordLists[0]['title'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  studyProvider.getProgressText(
                    List<Map<String, dynamic>>.from(
                      studyProvider.recentWordLists[0]['words'] as List
                    )
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordListScreen(
                        title: studyProvider.recentWordLists[0]['title'].toString(),
                        words: List<Map<String, dynamic>>.from(
                          studyProvider.recentWordLists[0]['words'] as List
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBasicWordList(List<JapaneseLevel> levels, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '기본 단어장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.mainColor,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: const Color(0xFF1C1B1F),  // 다크 모드 카드 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: levels.map((level) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubLevelScreen(level: level),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        level.title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Consumer<StudyProvider>(
                        builder: (context, studyProvider, child) {
                          int totalWords = 0;
                          int studiedWords = 0;
                          level.subLevels.values.forEach((sublevel) {
                            totalWords += sublevel.words.length;
                            studiedWords += studyProvider.getStudiedWordsCount(sublevel.words);
                          });
                          return Text(
                            '$studiedWords/$totalWords',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomWordbooks(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.edit_note,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '커스텀 단어장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.mainColor,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: const Color(0xFF1C1B1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Text(
                  'Coming soon...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, StudyProvider>(
      builder: (context, themeProvider, studyProvider, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        if (_isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_error.isNotEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: $_error'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '메모리 メモリ',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: 1.2,
                  color: themeProvider.mainColor,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
              ? Center(child: Text(_error))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: '단어 검색...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      _buildRecentLists(studyProvider, themeProvider),
                      _buildBasicWordList(_levels, themeProvider),
                      _buildCustomWordbooks(context, themeProvider),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
