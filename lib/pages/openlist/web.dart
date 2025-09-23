import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenlistWeb extends StatefulWidget {
  const OpenlistWeb({super.key});

  @override
  State<OpenlistWeb> createState() => _OpenlistWebState();
}

class _OpenlistWebState extends State<OpenlistWeb> {
  late final _controller =
      WebViewController()
        ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('http://localhost:5244'));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
