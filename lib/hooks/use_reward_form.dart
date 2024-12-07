import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import '../models/platform.dart';
import '../services/store_mission_command_service.dart';
import '../services/tag_query_service.dart';
import '../providers/auth_provider.dart';

class RewardFormState {
  final GlobalKey<FormState> formKey;
  final TextEditingController rewardNameController;
  final TextEditingController storeNameController;
  final TextEditingController productLinkController;
  final TextEditingController keywordController;
  final TextEditingController productIdController;
  final TextEditingController optionIdController;
  final TextEditingController rewardAmountController;
  final TextEditingController maxRewardsPerDayController;
  final DateTime? startDate;
  final DateTime? endDate;
  final Platform? selectedPlatform;
  final Set<String> selectedTags;
  final List<String> tagSuggestions;
  final Function(DateTime) setStartDate;
  final Function(DateTime) setEndDate;
  final Function(Platform) setSelectedPlatform;
  final Function(String) searchTags;
  final Function() submitForm;

  RewardFormState({
    required this.formKey,
    required this.rewardNameController,
    required this.storeNameController,
    required this.productLinkController,
    required this.keywordController,
    required this.productIdController,
    required this.optionIdController,
    required this.rewardAmountController,
    required this.maxRewardsPerDayController,
    required this.startDate,
    required this.endDate,
    required this.selectedPlatform,
    required this.selectedTags,
    required this.tagSuggestions,
    required this.setStartDate,
    required this.setEndDate,
    required this.setSelectedPlatform,
    required this.searchTags,
    required this.submitForm,
  });
}

RewardFormState useRewardForm(BuildContext context) {
  final formKey = useMemoized(() => GlobalKey<FormState>());
  final rewardNameController = useTextEditingController();
  final storeNameController = useTextEditingController();
  final productLinkController = useTextEditingController();
  final keywordController = useTextEditingController();
  final productIdController = useTextEditingController();
  final optionIdController = useTextEditingController();
  final rewardAmountController = useTextEditingController();
  final maxRewardsPerDayController = useTextEditingController();

  final startDate = useState<DateTime?>(null);
  final endDate = useState<DateTime?>(null);
  final selectedPlatform = useState<Platform?>(null);
  final selectedTags = useState<Set<String>>({});
  final tagSuggestions = useState<List<String>>([]);

  useEffect(() {
    return () {
      rewardNameController.dispose();
      storeNameController.dispose();
      productLinkController.dispose();
      keywordController.dispose();
      productIdController.dispose();
      optionIdController.dispose();
      rewardAmountController.dispose();
      maxRewardsPerDayController.dispose();
    };
  }, []);

  Future<void> searchTags(String query) async {
    if (query.isEmpty) {
      tagSuggestions.value = [];
      return;
    }

    try {
      final tags = await TagQueryService.searchTags(
        context: context,
        query: query,
      );
      tagSuggestions.value = tags;
    } catch (e) {
      debugPrint('Error searching tags: $e');
    }
  }

  Future<void> submitForm() async {
    if (formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 필요합니다.')),
          );
          return;
        }

        await StoreMissionCommandService.createStoreMission(
          context: context,
          rewardName: rewardNameController.text,
          platformId: selectedPlatform.value?.id ?? 0,
          storeName: storeNameController.text,
          productLink: productLinkController.text,
          keyword: keywordController.text,
          productId: productIdController.text,
          optionId: optionIdController.text,
          startDate: startDate.value!,
          endDate: endDate.value!,
          registrantId: user.userId,
          rewardAmount: double.parse(rewardAmountController.text),
          maxRewardsPerDay: int.parse(maxRewardsPerDayController.text),
          tags: selectedTags.value.toList(),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('리워드가 성공적으로 등록되었습니다.')),
          );
          final currentLocale = Localizations.localeOf(context).languageCode;
          context.go('/$currentLocale/sales/store-mission');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('리워드 등록 실패: $e')),
          );
        }
      }
    }
  }

  return RewardFormState(
    formKey: formKey,
    rewardNameController: rewardNameController,
    storeNameController: storeNameController,
    productLinkController: productLinkController,
    keywordController: keywordController,
    productIdController: productIdController,
    optionIdController: optionIdController,
    rewardAmountController: rewardAmountController,
    maxRewardsPerDayController: maxRewardsPerDayController,
    startDate: startDate.value,
    endDate: endDate.value,
    selectedPlatform: selectedPlatform.value,
    selectedTags: selectedTags.value,
    tagSuggestions: tagSuggestions.value,
    setStartDate: (date) => startDate.value = date,
    setEndDate: (date) => endDate.value = date,
    setSelectedPlatform: (platform) => selectedPlatform.value = platform,
    searchTags: searchTags,
    submitForm: submitForm,
  );
} 