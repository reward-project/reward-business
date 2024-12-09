import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:reward_business/services/payment_service.dart';

class KakaoPayScreen extends StatefulWidget {
  final double amount;
  final String itemName;

  const KakaoPayScreen({
    Key? key, 
    required this.amount,
    required this.itemName,
  }) : super(key: key);

  @override
  State<KakaoPayScreen> createState() => _KakaoPayScreenState();
}

class _KakaoPayScreenState extends State<KakaoPayScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카카오페이 결제'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: '',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _controller = controller;
              _requestPayment();
            },
            onPageFinished: (url) {
              setState(() => _isLoading = false);
              _handlePaymentCallback(url);
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _requestPayment() async {
    try {
      final response = await PaymentService().requestKakaoPayment(
        amount: widget.amount,
        itemName: widget.itemName,
      );
      
      if (response.successUrl != null) {
        _controller.loadUrl(response.successUrl!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 요청 실패: ${e.toString()}')),
      );
      Navigator.pop(context, false);
    }
  }

  void _handlePaymentCallback(String url) {
    if (url.contains('/success')) {
      // 결제 성공
      Navigator.pop(context, true);
    } else if (url.contains('/fail') || url.contains('/cancel')) {
      // 결제 실패 또는 취소
      Navigator.pop(context, false);
    }
  }
} 