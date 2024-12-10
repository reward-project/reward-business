import 'package:flutter/material.dart' show BuildContext;
import 'naver_pay_interface.dart';

// 웹 환경에서 dart:js 라이브러리가 존재할 때만 naver_pay_web.dart를 불러옴
// 그렇지 않은 경우 naver_pay_stub.dart를 불러옴
import 'naver_pay_stub.dart' if (dart.library.html) 'naver_pay_web.dart';

class NaverPayService {
  final NaverPayInterface _implementation = NaverPayImplementation();
  // NaverPayImplementation()은 naver_pay_stub.dart 또는 naver_pay_web.dart 중 하나에서 구현.

  Future<void> startPayment(
    BuildContext context, {
    required double amount,
    required String itemName,
  }) async {
    _implementation.processPayment(context, amount, itemName);
  }
}
