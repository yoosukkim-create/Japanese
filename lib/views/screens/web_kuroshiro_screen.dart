import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_html/flutter_html.dart';

class WebKuroshiroScreen extends StatefulWidget {
  const WebKuroshiroScreen({Key? key}) : super(key: key);

  @override
  State<WebKuroshiroScreen> createState() => _WebKuroshiroScreenState();
}

class _WebKuroshiroScreenState extends State<WebKuroshiroScreen> {
  late final InAppLocalhostServer localhostServer;
  late final InAppWebViewController _controller;
  // 1) 기본 텍스트를 여기에 설정
  final TextEditingController _textController =
      TextEditingController(text: '階段を上るたびに、運動不足を痛感させられる');
  String _outputHtml = '결과가 여기에…';

  @override
  void initState() {
    super.initState();
    localhostServer = InAppLocalhostServer(documentRoot: 'assets/web');
    localhostServer.start();
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
    _controller.evaluateJavascript(
      source: "convertText(${jsonEncode(text)});",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView Kuroshiro')),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              // 2) URL 경로에서 `/web` 부분 제거
              initialUrlRequest: URLRequest(
                url: Uri.parse('http://localhost:8080/index.html'),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;

                _controller.addJavaScriptHandler(
                  handlerName: 'debug',
                  callback: (args) => debugPrint('[JS DEBUG] ${args[0]}'),
                );

                _controller.addJavaScriptHandler(
                  handlerName: 'ready',
                  callback: (args) {
                    debugPrint('[Flutter] ready → ${args[0]}');
                    // 3) 페이지 준비되면 자동 변환 호출
                    _convert();
                  },
                );

                _controller.addJavaScriptHandler(
                  handlerName: 'onResult',
                  callback: (args) {
                    final data = jsonDecode(args[0]);
                    setState(() {
                      _outputHtml = data['success'] == true
                          ? data['result']
                          : '<p>에러: ${data['error']}</p>';
                    });
                  },
                );
              },
            ),
          ),

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
              child: Html(data: _outputHtml),
            ),
          ),
        ],
      ),
    );
  }
}
