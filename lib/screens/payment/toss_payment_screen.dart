import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:reward/services/payment_service.dart';

class TossPaymentScreen extends StatefulWidget {
  final double amount;
  final String itemName;

  const TossPaymentScreen({
    super.key, 
    required this.amount,
    required this.itemName,
  });

  @override
  State<TossPaymentScreen> createState() => _TossPaymentScreenState();
}

class _TossPaymentScreenState extends State<TossPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _handlePaymentCallback(url);
          },
        ),
      );
    _requestPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('토스페이먼츠 결제'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _requestPayment() async {
    try {
      final response = await PaymentService().requestTossPayment(
        amount: widget.amount,
        itemName: widget.itemName,
      );
      
      if (response.successUrl != null) {
        await _controller.loadRequest(Uri.parse(response.successUrl!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 요청 실패: ${e.toString()}')),
        );
        Navigator.pop(context, false);
      }
    }
  }

  void _handlePaymentCallback(String url) {
    if (url.contains('/success')) {
      Navigator.pop(context, true);
    } else if (url.contains('/fail') || url.contains('/cancel')) {
      Navigator.pop(context, false);
    }
  }
} 