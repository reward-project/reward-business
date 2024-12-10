import 'package:flutter/material.dart';
import '../reward_input_field.dart';

class RewardBasicInfo extends StatelessWidget {
  final TextEditingController rewardNameController;
  final TextEditingController storeNameController;

  const RewardBasicInfo({
    super.key,
    required this.rewardNameController,
    required this.storeNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RewardInputField(
          label: '리워드명',
          controller: rewardNameController,
          placeholder: '리워드명을 입력하세요',
          validator: (value) {
            if (value?.isEmpty ?? true) return '리워드명을 입력해주세요';
            return null;
          },
        ),
        const SizedBox(height: 24),
        RewardInputField(
          label: '스토어명',
          controller: storeNameController,
          placeholder: '스토어명을 입력하세요',
          validator: (value) {
            if (value?.isEmpty ?? true) return '스토어명을 입력해주세요';
            return null;
          },
        ),
      ],
    );
  }
} 