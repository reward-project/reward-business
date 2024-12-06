import 'package:flutter/material.dart';
import '../../../../models/platform/platform.dart';
import '../reward_platform_field.dart';
import '../reward_product_link_field.dart';
import '../reward_input_field.dart';
import 'package:go_router/go_router.dart';

class RewardPlatformInfo extends StatelessWidget {
  final List<Platform> platforms;
  final String? selectedPlatform;
  final bool isLoadingPlatforms;
  final Function(String?) onPlatformChanged;
  final TextEditingController productLinkController;
  final String? selectedDomain;
  final List<Map<String, dynamic>> domains;
  final bool isLoadingDomains;
  final Function(String?) onDomainChanged;
  final TextEditingController keywordController;
  final TextEditingController productIdController;
  final TextEditingController optionIdController;

  const RewardPlatformInfo({
    Key? key,
    required this.platforms,
    required this.selectedPlatform,
    required this.isLoadingPlatforms,
    required this.onPlatformChanged,
    required this.productLinkController,
    required this.selectedDomain,
    required this.domains,
    required this.isLoadingDomains,
    required this.onDomainChanged,
    required this.keywordController,
    required this.productIdController,
    required this.optionIdController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RewardPlatformField(
                platforms: platforms,
                selectedPlatform: selectedPlatform,
                isLoading: isLoadingPlatforms,
                onChanged: onPlatformChanged,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                final locale = Localizations.localeOf(context).languageCode;
                context.push('/$locale/platform/register').then((_) {
                  onPlatformChanged(null);
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('플랫폼 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        RewardProductLinkField(
          productLinkController: productLinkController,
          selectedDomain: selectedDomain,
          domains: domains,
          isLoadingDomains: isLoadingDomains,
          selectedPlatform: selectedPlatform,
          onDomainChanged: onDomainChanged,
        ),
        const SizedBox(height: 24),
        RewardInputField(
          label: '키워드',
          controller: keywordController,
          placeholder: '키워드를 입력하세요',
          validator: (value) {
            if (value?.isEmpty ?? true) return '키워드를 입력해주세요';
            return null;
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: RewardInputField(
                label: '상품 ID',
                controller: productIdController,
                placeholder: '상품 ID를 입력하세요',
                validator: (value) {
                  if (value?.isEmpty ?? true) return '상품 ID를 입력해주세요';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RewardInputField(
                label: '옵션 ID',
                controller: optionIdController,
                placeholder: '옵션 ID를 입력하세요',
                validator: (value) {
                  if (value?.isEmpty ?? true) return '옵션 ID를 입력해주세요';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
} 