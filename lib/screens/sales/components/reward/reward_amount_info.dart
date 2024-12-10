import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../utils/formatters/thousands_separator_input_formatter.dart';
import '../reward_input_field.dart';

class RewardAmountInfo extends StatelessWidget {
  final TextEditingController rewardAmountController;
  final TextEditingController maxRewardsPerDayController;
  final double cpcAmount;
  final double totalMaxAmount;
  final VoidCallback onCpcInfoPressed;

  const RewardAmountInfo({
    super.key,
    required this.rewardAmountController,
    required this.maxRewardsPerDayController,
    required this.cpcAmount,
    required this.totalMaxAmount,
    required this.onCpcInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RewardInputField(
          label: '리워드 입찰가 (원)',
          controller: rewardAmountController,
          placeholder: '리워드 단가를 입력하세요',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) return '리워드 단가를 입력해주세요';
            return null;
          },
        ),
        if (cpcAmount > 0) ...[
          const SizedBox(height: 8),
          _buildCpcInfo(context),
        ],
        const SizedBox(height: 16),
        RewardInputField(
          label: '하루 최대 소진량',
          controller: maxRewardsPerDayController,
          placeholder: '하루 최대 소진량을 입력하세요',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value?.isEmpty ?? true) return '하루 최대 소진량을 입력해주세요';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCpcInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: onCpcInfoPressed,
              icon: const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              tooltip: 'CPC 단가 정보',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'CPC 단가: ${NumberFormat('#,###').format(cpcAmount)}원',
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 