import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:japanese/providers/theme_provider.dart';
import 'package:japanese/providers/study_provider.dart';

class MemoryCard extends StatelessWidget {
  final Map<String, dynamic> word;
  final bool showExamples;
  final bool showCanvas;
  final bool showAnswer;
  final SignatureController sigController;
  final VoidCallback onToggleAnswer;
  final VoidCallback onClearSignature;
  final VoidCallback onMoveToNext;
  final StudyProvider studyProvider;

  const MemoryCard({
    super.key,
    required this.word,
    required this.showExamples,
    required this.showCanvas,
    required this.showAnswer,
    required this.sigController,
    required this.onToggleAnswer,
    required this.onClearSignature,
    required this.onMoveToNext,
    required this.studyProvider,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? ThemeProvider.cardBlack : ThemeProvider.cardWhite;
    final mainColor = Theme.of(context).primaryColor;

    return SizedBox.expand(
      child: Card(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeProvider.globalCornerRadius),
        ),
        child: InkWell(
          // 카드 전체를 탭하면 정답 토글
          onTap: onToggleAnswer,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: ThemeProvider.memoryPadding,
            child: Column(
              // 상단 정보 / 중앙 콘텐츠 / 하단 버튼을 세로로 분리
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ──────────────────────────────────
                // 1) 상단 정보(학습 상태) 영역
                Builder(
                  builder: (ctx) {
                    final mem = studyProvider.getMemoryState(word['id']);

                    final interval = mem?.interval.toString() ?? '0';
                    final rep = mem?.repetition.toString() ?? '0';
                    final last =
                        (mem != null && mem.lastReviewedAt != null)
                            ? _formatDate(mem.lastReviewedAt!)
                            : '미학습';

                    final text =
                        '복습간격: $interval일  •  연속정답: $rep회  •  최근학습: $last';

                    return Visibility(
                      visible: Provider.of<ThemeProvider>(ctx).showMemoryParams,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          style: ThemeProvider.metaDataStyle(ctx),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),

                // ──────────────────────────────────
                // 2) 중앙 콘텐츠 영역 (단어/읽기/뜻/예문/캔버스)
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 히라가나 (toggle)
                      Visibility(
                        visible: showAnswer,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word['읽기'] ?? '',
                            style: ThemeProvider.wordReadMean(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      ThemeProvider.gap4,

                      // 단어 본문 혹은 캔버스
                      if (showCanvas) ...[
                        // 캔버스 모드: Signature 위에 단어 텍스트로 표시
                        SizedBox(
                          height: ThemeProvider.memoryCanvas(context),
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(
                                ThemeProvider.globalCornerRadius,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (_) {}, // 탭만 소비
                                  child: Signature(
                                    controller: sigController,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Visibility(
                                  visible: showAnswer,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      word['단어'] ?? '',
                                      style: ThemeProvider.wordText(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // 일반 모드: 텍스트만
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word['단어'] ?? '',
                            style: ThemeProvider.wordText(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      ThemeProvider.gap4,

                      // ──────────────────────────────────
                      // 뜻 영역: showCanvas==true면 항상 보이고, 그렇지 않으면 showAnswer 기준으로 보임
                      Visibility(
                        visible: showCanvas || showAnswer,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word['뜻'] ?? '',
                            style: ThemeProvider.wordReadMean(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      ThemeProvider.gap12,
                      ThemeProvider.gap12,

                      // ──────────────────────────────────
                      // 예문 영역
                      Visibility(
                        visible: showExamples,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Column(
                          children: [
                            // 예문 읽기 (히라가나)
                            Visibility(
                              visible: showAnswer,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word['예문읽기'] ?? '',
                                  style: ThemeProvider.wordReadMean(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            ThemeProvider.gap4,

                            // 예문 본문
                            Visibility(
                              visible: !showCanvas || showAnswer,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word['예문'] ?? '',
                                  style: ThemeProvider.exampleText(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            ThemeProvider.gap4,

                            // 예문 뜻
                            Visibility(
                              visible: showAnswer,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word['예문뜻'] ?? '',
                                  style: ThemeProvider.exampleReadMean(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ──────────────────────────────────
                // 3) 하단 평가 버튼 영역
                //    (showAnswer == true)일 때만 보이되, 공간 유지
                Expanded(
                  flex: 2,
                  child: Visibility(
                    visible: showAnswer,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '이 단어를 얼마나 잘 기억하시나요?',
                          style: ThemeProvider.memoryQuestionStyle(
                            context,
                          ).copyWith(color: mainColor),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // 버튼 3개: FittedBox로 가로 공간 부족 시 축소
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMemoryButton(
                                context: context,
                                text: '모름',
                                color: Colors.redAccent,
                                onPressed:
                                    showAnswer
                                        ? () {
                                          studyProvider.updateMemoryState(
                                            word['id'],
                                            1,
                                          );
                                          onClearSignature();
                                          onMoveToNext();
                                        }
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              _buildMemoryButton(
                                context: context,
                                text: '애매함',
                                color: Colors.orangeAccent,
                                onPressed:
                                    showAnswer
                                        ? () {
                                          studyProvider.updateMemoryState(
                                            word['id'],
                                            3,
                                          );
                                          onClearSignature();
                                          onMoveToNext();
                                        }
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              _buildMemoryButton(
                                context: context,
                                text: '잘 암',
                                color: Colors.green,
                                onPressed:
                                    showAnswer
                                        ? () {
                                          studyProvider.updateMemoryState(
                                            word['id'],
                                            5,
                                          );
                                          onClearSignature();
                                          onMoveToNext();
                                        }
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: ThemeProvider.memoryButton(context),
      height: ThemeProvider.memoryButton(context) / 1.5,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeProvider.globalCornerRadius,
            ),
          ),
        ),
        child: FittedBox(
          // ✅ 글자가 너무 크면 자동으로 줄어듦
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: ThemeProvider.memoryButtonStyle(
              context,
            ).copyWith(color: ThemeProvider.textColor(context)),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}
