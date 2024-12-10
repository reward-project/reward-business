// naver_pay_web.dart
import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'naver_pay_interface.dart';

@JS('Naver.Pay.create')
external dynamic createNaverPay(dynamic options);

NaverPayInterface NaverPayImplementation() => NaverPayWeb();

class NaverPayWeb implements NaverPayInterface {
  @override
  void processPayment(BuildContext context, double amount, String itemName) {
    final naverPay = createNaverPay(jsify({
      'mode': 'development',
      'clientId': 'HN3GGCMDdTgGUfl0kFCo',
      'chainId': 'ZXJOUW9RWXRMSng'
    }));

    callMethod(naverPay, 'open', [
      jsify({
        'merchantUserKey': 'user123',
        'merchantPayKey': DateTime.now().millisecondsSinceEpoch.toString(),
        'productName': itemName,
        'totalPayAmount': amount.toInt(),
        'taxScopeAmount': amount.toInt(),
        'taxExScopeAmount': 0,
        'returnUrl': 'http://localhost:8080/api/v1/payments/naver/callback'
      })
    ]);
  }
}
