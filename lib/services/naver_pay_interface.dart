import 'package:flutter/material.dart';

abstract class NaverPayInterface {
  void processPayment(BuildContext context, double amount, String itemName);
} 