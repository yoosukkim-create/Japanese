import 'package:flutter/material.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/services/kuroshiro_service.dart';

/// WordListItem: 리스트 모드와 플래시카드 모드에서 공통으로 쓰이는 카드 위젯
class WordListItem extends StatefulWidget {
  final Map<String, dynamic> word;
  final bool showHiragana;
  final bool showMeaning;
  final bool showExamples;
  final bool isFlashcardMode;

  const WordListItem({
    super.key,
    required this.word,
    required this.showHiragana,
    required this.showMeaning,
    required this.showExamples,
    this.isFlashcardMode = false,
  });

  @override
  _WordListItemState createState() => _WordListItemState();
}

class _WordListItemState extends State<WordListItem> {
  List<KuroToken> _exampleTokens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExample();
  }

  Future<void> _loadExample() async {
    final sentence = widget.word['예문'] as String? ?? '';
    List<KuroToken> tokens;
    try {
      tokens = await KuroshiroService.instance.convert(sentence);
    } catch (_) {
      tokens = [];
    }

    // 위젯이 여전히 트리에 남아 있을 때만 setState
    if (!mounted) return;
    setState(() {
      _exampleTokens = tokens;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // 로딩 중 스피너
      return const Center(child: CircularProgressIndicator());
    }

    // 변환된 리스트에서 히라가나/본문을 각각 합쳐 두 문자열 생성
    final exampleReading = _exampleTokens.map((t) => t.furigana).join();
    final exampleText = _exampleTokens.map((t) => t.reibun).join();

    // 카드 배경 색을 다크/라이트 모드에 맞춤
    final bgColor =
        ThemeProvider.isDark(context)
            ? ThemeProvider.cardBlack
            : ThemeProvider.cardWhite;

    // 실제 카드 내부 콘텐츠
    final cardContent = Padding(
      padding: ThemeProvider.cardPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 상단: 단어/히라가나/뜻 ─────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: widget.showHiragana,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                  padding: ThemeProvider.showUpPadding,
                  child: Text(
                    widget.word['읽기'] ?? '',
                    style: ThemeProvider.wordReadMean(context),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                widget.word['단어'] ?? '',
                style:
                    widget.isFlashcardMode
                        ? ThemeProvider.wordText(context)
                        : ThemeProvider.wordTextSmall(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Visibility(
                visible: widget.showMeaning,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                  padding: ThemeProvider.showDownPadding,
                  child: Text(
                    widget.word['뜻'] ?? '',
                    style: ThemeProvider.wordReadMean(context),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          // ─── 예문 영역 ───────────────────────────────
          ThemeProvider.gap12,
          Visibility(
            visible: widget.showExamples,
            maintainSize: widget.isFlashcardMode,
            maintainAnimation: widget.isFlashcardMode,
            maintainState: widget.isFlashcardMode,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(
                  ThemeProvider.globalCornerRadius * 0.8,
                ),
              ),
              padding: ThemeProvider.cardPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: widget.showHiragana,
                    maintainSize: widget.showExamples,
                    maintainAnimation: widget.showExamples,
                    maintainState: widget.showExamples,
                    child: Text(
                      exampleReading,
                      style: ThemeProvider.exampleReadMean(context),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    exampleText,
                    style: ThemeProvider.exampleText(context),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Visibility(
                    visible: widget.showMeaning,
                    maintainSize: widget.showExamples,
                    maintainAnimation: widget.showExamples,
                    maintainState: widget.showExamples,
                    child: Text(
                      widget.word['예문뜻'] ?? '',
                      style: ThemeProvider.exampleReadMean(context),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // 플래시카드 모드일 때: 전체 화면 확장
    if (widget.isFlashcardMode) {
      return SizedBox.expand(
        child: Card(
          color: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeProvider.globalCornerRadius,
            ),
          ),
          child: cardContent,
        ),
      );
    }

    // 리스트 모드일 때
    return Card(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeProvider.globalCornerRadius),
      ),
      child: cardContent,
    );
  }
}
