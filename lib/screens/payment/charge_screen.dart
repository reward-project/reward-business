import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/naver_pay_stub.dart';

class ChargeScreen extends StatelessWidget {
  const ChargeScreen({super.key});

  void _handleCharge(BuildContext context, double amount) {
    NaverPayImplementation().processPayment(
      context,
      amount,
      '리워드 예산 충전',
    );
  }

  Widget _buildChargeButton(BuildContext context, double amount) {
    final formatter = NumberFormat('#,###');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleCharge(context, amount),
          child: Text('${formatter.format(amount)}원 충전'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('충전하기'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildChargeButton(context, 10000),
          _buildChargeButton(context, 30000),
          _buildChargeButton(context, 50000),
          _buildChargeButton(context, 100000),
        ],
      ),
    );
  }
} 