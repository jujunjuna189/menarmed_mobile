import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleViewScreen extends StatefulWidget {
  const ArticleViewScreen({super.key, required this.data});
  final String data;

  @override
  State<ArticleViewScreen> createState() => _ArticleViewScreenState();
}

class _ArticleViewScreenState extends State<ArticleViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final arguments = jsonDecode(widget.data) as Map<String, dynamic>;
    final url = Uri.parse(Api.artikelView).replace(
      queryParameters: {
        'artikel_id': arguments['article_id'].toString(),
        'mobile': '1',
      },
    );
    _controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _failed = false;
              _progress = 0;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() {
              _failed = true;
              _progress = 100;
            });
          },
          onHttpError: (error) {
              if (!mounted || error.request?.uri != url) return;
            setState(() {
              _failed = true;
              _progress = 100;
            });
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Artikel',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => _controller.reload(),
          tooltip: 'Muat ulang',
          icon: const Icon(Icons.refresh, size: 20),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          if (_progress < 100 && !_failed)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
              minHeight: 2,
            ),
          Expanded(
            child: _failed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 32,
                          color: Color(0xFF73777D),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Artikel belum dapat dimuat',
                          style: TextStyle(fontSize: 13),
                        ),
                        TextButton.icon(
                          onPressed: () => _controller.reload(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    ),
  );
}
