// naver_pay_stub.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';
import 'naver_pay_interface.dart';

NaverPayInterface NaverPayImplementation() => NaverPayMobile();

class NaverPayMobile implements NaverPayInterface {
  @override
  void processPayment(BuildContext context, double amount, String itemName) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    
    // Next.js 결제 페이지 URL 생성
    final paymentUrl = Uri(
      scheme: AppConfig.rewardLandingScheme,
      host: AppConfig.rewardLandingHost,
      port: AppConfig.rewardLandingPort,
      path: '/$currentLocale/payment',
      queryParameters: {
        'amount': amount.toInt().toString(),
        'itemName': itemName,
      },
    ).toString();

    // WebView로 결제 페이지 열기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('네이버페이 결제'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (request) {
                    if (request.url.contains('/api/v1/payments/naver/callback')) {
                      Navigator.pop(context, true);
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              )
              ..loadRequest(Uri.parse(paymentUrl)),
          ),
        ),
      ),
    );
  }
}
