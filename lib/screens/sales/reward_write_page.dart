import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_mission_command_service.dart';
import 'components/reward_form.dart';

class RewardWritePage extends StatefulWidget {
  const RewardWritePage({super.key});

  @override
  State<RewardWritePage> createState() => _RewardWritePageState();
}

class _RewardWritePageState extends State<RewardWritePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  String? _selectedDomain;

  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    try {
      debugPrint('Submitting form with data: $data');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = await authProvider.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await StoreMissionCommandService.createStoreMission(
        context: context,
        rewardName: data['rewardName'],
        platformId: data['platformId'],
        storeName: data['storeName'],
        productLink: data['productLink'],
        keyword: data['keyword'],
        productId: data['productId'],
        optionId: data['optionId'],
        startDate: data['startDate'],
        endDate: data['endDate'],
        registrantId: user.userId,
        rewardAmount: data['rewardAmount'],
        totalBudget: data['totalBudget'],
        maxRewardsPerDay: data['maxRewardsPerDay'],
        tags: List<String>.from(data['tags'] ?? []),
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
      debugPrint('Error submitting form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initializeUserInfo();
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
            selectedDomain: _selectedDomain,
            onDomainChanged: (String? domain) {
              setState(() {
                _selectedDomain = domain;
              });
            },
          ),
        ),
      ),
    );
  }
}
