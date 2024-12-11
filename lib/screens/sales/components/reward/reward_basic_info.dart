import 'package:flutter/material.dart';
import '../reward_input_field.dart';

class RewardBasicInfo extends StatelessWidget {
  final TextEditingController rewardNameController;

  const RewardBasicInfo({
    super.key,
    required this.rewardNameController,
  });

  @override
  Widget build(BuildContext context) {
    return RewardInputField(
      label: '리워드명',
      controller: rewardNameController,
      placeholder: '리워드명을 입력하세요',
      validator: (value) {
        if (value?.isEmpty ?? true) return '리워드명을 입력해주세요';
        return null;
      },
    );
  }
}