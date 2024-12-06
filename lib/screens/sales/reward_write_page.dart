import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_mission_service.dart';
import 'components/reward_form.dart';

class RewardWritePage extends StatefulWidget {
  const RewardWritePage({super.key});

  @override
  State<RewardWritePage> createState() => _RewardWritePageState();
}

class _RewardWritePageState extends State<RewardWritePage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await StoreMissionService.createStoreMission(
        context: context,
        rewardName: data['rewardName'],
        platform: data['platform'],
        storeName: data['storeName'],
        productLink: data['productLink'],
        keyword: data['keyword'],
        productId: data['productId'],
        optionId: data['optionId'],
        startDate: data['startDate'],
        endDate: data['endDate'],
        registrantId: user.userId,
        rewardAmount: data['rewardAmount'],
        maxRewardsPerDay: data['maxRewardsPerDay'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('리워드가 성공적으로 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        final locale = Localizations.localeOf(context).languageCode;
        context.go('/$locale/sales/store-mission');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          '리워드 등록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: RewardForm(
            formKey: _formKey,
            onSubmit: _handleSubmit,
          ),
        ),
      ),
    );
  }
}