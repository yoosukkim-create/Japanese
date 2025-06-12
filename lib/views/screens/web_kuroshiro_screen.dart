import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebKuroshiroScreen extends StatefulWidget {
  const WebKuroshiroScreen({Key? key}) : super(key: key);

  @override
  State<WebKuroshiroScreen> createState() => _WebKuroshiroScreenState();
}

class _WebKuroshiroScreenState extends State<WebKuroshiroScreen> {
  late final InAppLocalhostServer localhostServer;
  late InAppWebViewController _controller;
  final TextEditingController _textController =
      TextEditingController(text: '階段を上るたびに、運動不足を痛感させられる');

  List<Map<String, String>> _tokens = [];

  @override
  void initState() {
    super.initState();

    localhostServer = InAppLocalhostServer(documentRoot: 'assets/web');
    localhostServer.start().then((_) {
      // 서버 실행 후 WebView 로드
      _controller.loadUrl(
        urlRequest: URLRequest(url: Uri.parse('http://localhost:8080/index.html')),
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    localhostServer.close();
    super.dispose();
  }

  void _convert() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final payload = jsonEncode({'text': text});
    _controller.evaluateJavascript(source: 'convertText($payload);');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kuroshiro 후리가나')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration:
                        const InputDecoration(labelText: '일본어 입력'),
                    onSubmitted: (_) => _convert(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _convert),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: _tokens.map((t) {
                  final hasFuri = t['furigana']!.isNotEmpty;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasFuri)
                        SizedBox(
                          height: 16,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              t['furigana']!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                      Text(
                        t['reibun']!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // 숨겨진 Offstage WebView
          Offstage(
            offstage: true,
            child: SizedBox(
              width: 1,
              height: 1,
              child: InAppWebView(
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                  ),
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  _controller.addJavaScriptHandler(
                    handlerName: 'ready',
                    callback: (_) => _convert(),
                  );
                  _controller.addJavaScriptHandler(
                    handlerName: 'onResult',
                    callback: (args) {
                      final payload = jsonDecode(args[0]);
                      if (payload['success'] == true) {
                        final raw = payload['data'] as List<dynamic>;
                        setState(() {
                          _tokens = raw
                              .map((e) => {
                                    'furigana': e['furigana'] as String,
                                    'reibun': e['reibun'] as String,
                                  })
                              .toList();
                        });
                      }
                    },
                  );

                  // 페이지 로드 완료 후 핸들러 등록 후 변환 트리거
                  _controller.loadUrl(
                    urlRequest: URLRequest(
                        url: Uri.parse('http://localhost:8080/index.html')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
