import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ELearningViewScreen extends StatefulWidget {
  const ELearningViewScreen({Key? key, required this.data}) : super(key: key);

  final String data;

  @override
  State<ELearningViewScreen> createState() => _ELearningViewScreenState();
}

class _ELearningViewScreenState extends State<ELearningViewScreen> {
  String _apiELearningView = '';
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    ToastLoader.instance.showLoader();
    setUrlELearninge();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (finished) {
            ToastLoader.instance.hideLoader();
          },
        ),
      )
      ..loadRequest(Uri.parse(_apiELearningView));
  }

  void setUrlELearninge() {
    _apiELearningView += jsonDecode(widget.data)['path'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
