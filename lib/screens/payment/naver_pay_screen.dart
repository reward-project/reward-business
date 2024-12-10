import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_config.dart';

class NaverPayScreen extends StatefulWidget {
  final double amount;
  final String itemName;

  const NaverPayScreen({
    super.key,
    required this.amount,
    required this.itemName,
  });

  @override
  State<NaverPayScreen> createState() => _NaverPayScreenState();
}

class _NaverPayScreenState extends State<NaverPayScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final merchantPayKey = DateTime.now().millisecondsSinceEpoch.toString();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith('${AppConfig.apiBaseUrl}/api/v1/payments/naver/callback')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
        '${AppConfig.rewardAppUrl}/payment?'
        'amount=${widget.amount.toInt()}&'
        'itemName=${Uri.encodeComponent(widget.itemName)}'
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네이버페이 결제'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
