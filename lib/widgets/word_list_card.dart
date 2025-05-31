// lib/views/widgets/word_list_item.dart

import 'package:flutter/material.dart';
import 'package:japanese/providers/theme_provider.dart';

/// WordListItem: 리스트 모드와 플래시카드 모드에서 공통으로 쓰이는 카드 위젯
class WordListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 카드 배경 색을 다크/라이트 모드에 맞춤
    final bgColor =
        ThemeProvider.isDark(context)
            ? ThemeProvider.cardBlack
            : ThemeProvider.cardWhite;

    // 실제 카드 내부 콘텐츠 부분 (Padding 포함)
    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 상단: 단어/히라가나/뜻 영역 ────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ───── 히라가나 ────────────────────────────
              Visibility(
                visible: showHiragana,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    word['읽기'] ?? '',
                    style: ThemeProvider.wordReadMean(context),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // ───── 단어 (한자) ──────────────────────────
              Text(
                word['단어'] ?? '',
                style:
                    isFlashcardMode
                        ? ThemeProvider.wordText(context)
                        : ThemeProvider.wordTextSmall(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // ───── 뜻 ─────────────────────────────────
              Visibility(
                visible: showMeaning,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    word['뜻'] ?? '',
                    style: ThemeProvider.wordReadMean(context),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          // ─── 예문 영역: 리스트 모드에서는 '예문 숨김 시 공간 제거',
          //               '예문 보임 시에는 자식(예문읽기/예문본문/예문뜻) 크기 고정'
          const SizedBox(height: 12.0),
          Visibility(
            visible: showExamples,
            // 리스트 모드일 때는 (isFlashcardMode == false)이므로
            // showExamples==false면 container가 사라져서 공간 없음 → showExamples==true면 보임.
            // 플래시카드 모드에서는 `maintainSize`로 고정(기존 기능 유지)
            maintainSize: isFlashcardMode,
            maintainAnimation: isFlashcardMode,
            maintainState: isFlashcardMode,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(
                  ThemeProvider.globalCornerRadius * 0.8,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── 예문 읽기(히라가나) ─────────────────
                  Visibility(
                    visible: showHiragana,
                    // ★ 예문이 보이는 상태(showExamples==true)라면 항상 공간을 유지
                    // → 리스트 모드에서도 예문 보임 상태에서는 공간 유지를 위해 showExamples 사용
                    maintainSize: showExamples,
                    maintainAnimation: showExamples,
                    maintainState: showExamples,
                    child: Text(
                      word['예문읽기'] ?? '',
                      style: ThemeProvider.exampleReadMean(context),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // ─── 예문 본문 (항상 visible) ─────────────────────────────
                  Text(
                    word['예문'] ?? '',
                    style: ThemeProvider.exampleText(context),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ─── 예문 뜻 ───────────────────────────────
                  Visibility(
                    visible: showMeaning,
                    // ★ 예문이 보이는 상태(showExamples==true)라면 항상 공간을 유지
                    maintainSize: showExamples,
                    maintainAnimation: showExamples,
                    maintainState: showExamples,
                    child: Text(
                      word['예문뜻'] ?? '',
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

    // ──────────────────────────────────────────────────────────────────────────────
    // ★ 플래시카드 모드일 때: 카드가 화면 전체(패딩 제외)만큼 꽉 차도록 SizedBox.expand 사용
    if (isFlashcardMode) {
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

    // ──────────────────────────────────────────────────────────────────────────────
    // ★ 리스트 모드일 때: 예문숨김 시(container Visibility false → 공간 사라짐),
    //   예문보임 시(container Visibility true)에는 '예문읽기'와 '예문뜻' 모두
    //   ***항상 공간 유지*** → showExamples==true 이므로 유지
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
