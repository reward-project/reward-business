import 'package:flutter/material.dart';
import 'naver_pay_interface.dart';

class NaverPayWeb implements NaverPayInterface {
  const NaverPayWeb();
  
  @override
  void processPayment(BuildContext context, double amount, String itemName) {
    throw UnsupportedError('Web payment is not supported on this platform');
  }
} 