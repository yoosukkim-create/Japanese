import 'dart:async';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 모델: 한 글자 및 후리가나 쌍
class KuroToken {
  final String reibun;
  final String furigana;

  KuroToken({required this.reibun, required this.furigana});

  factory KuroToken.fromMap(Map<String, dynamic> map) {
    return KuroToken(
      reibun: map['reibun'] as String,
      furigana: map['furigana'] as String,
    );
  }
}

/// Kuroshiro 변환용 서비스 (싱글톤)
class KuroshiroService {
  KuroshiroService._internal();
  static final KuroshiroService instance = KuroshiroService._internal();

  late final InAppLocalhostServer _server;
  late final HeadlessInAppWebView _headless;
  late final Completer<void> _ready;
  bool _busy = false; // 직렬화 락

  /// 초기화: 로컬 서버 실행 및 Headless WebView 기동
  Future<void> initialize() async {
    _ready = Completer<void>();

    // 1) 로컬 서버 띄우기
    _server = InAppLocalhostServer(documentRoot: 'assets/web');
    await _server.start();

    // 2) Headless WebView 생성
    _headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse('http://localhost:8080/index.html'),
      ),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
      ),
      onWebViewCreated: (controller) {
        // JS 초기화 완료 신호
        controller.addJavaScriptHandler(
          handlerName: 'ready',
          callback: (_) {
            if (!_ready.isCompleted) _ready.complete();
            return null;
          },
        );
      },
    );

    // 3) Headless 실행
    await _headless.run();
    // 페이지 준비 완료까지 대기
    await _ready.future;
  }

  /// 후리가나 변환 수행 (한 번에 하나씩만 동작)
  Future<List<KuroToken>> convert(String text) async {
    if (_busy) {
      // 앞 작업이 끝날 때까지 대기
      await Future.doWhile(
        () => Future.delayed(const Duration(milliseconds: 10), () => _busy),
      );
    }
    _busy = true; // 락

    try {
      final controller = _headless.webViewController;

      // 결과 Completer
      final completer = Completer<List<KuroToken>>();

      // JS 핸들러 등록 (동일 이름이지만 직렬화로 꼬이지 않습니다)
      controller.addJavaScriptHandler(
        handlerName: 'onResult',
        callback: (args) {
          final payload = jsonDecode(args[0] as String) as Map<String, dynamic>;
          if (payload['success'] == true) {
            final raw = payload['data'] as List;
            final tokens =
                raw
                    .map((e) => KuroToken.fromMap(e as Map<String, dynamic>))
                    .toList();
            completer.complete(tokens);
          } else {
            completer.completeError(Exception(payload['error']));
          }
          // 핸들러 해제
          controller.removeJavaScriptHandler(handlerName: 'onResult');
          return null;
        },
      );

      // JS 호출
      final payload = jsonEncode({'text': text});
      await controller.evaluateJavascript(source: 'convertText($payload);');

      // 결과 반환
      return await completer.future;
    } finally {
      _busy = false; // 락 해제
    }
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await _headless.dispose();
    await _server.close();
  }
}
