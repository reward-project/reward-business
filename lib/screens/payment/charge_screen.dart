import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/naver_pay_service.dart';

class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final _naverPayService = NaverPayService();

  Future<void> _handleCharge(BuildContext context, double amount) async {
    try {
      await _naverPayService.startPayment(
        context,
        amount: amount,
        itemName: '리워드 예산 충전',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 처리 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
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