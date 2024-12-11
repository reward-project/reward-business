import 'package:flutter/material.dart';
import '../../../../models/platform/platform.dart';
import '../reward_platform_field.dart';
import '../reward_input_field.dart';
import '../reward_product_link_field.dart';
import 'package:go_router/go_router.dart';

class RewardPlatformInfo extends StatelessWidget {
  final List<Platform> platforms;
  final int? selectedPlatform;
  final Function(int?) onPlatformChanged;
  final List<Map<String, dynamic>> domains;
  final String? selectedDomain;
  final Function(String?) onDomainChanged;
  final bool isLoadingPlatforms;
  final bool isLoadingDomains;
  final TextEditingController storeNameController;
  final TextEditingController productLinkController;
  final TextEditingController keywordController;
  final TextEditingController productIdController;

  const RewardPlatformInfo({
    Key? key,
    required this.platforms,
    required this.selectedPlatform,
    required this.onPlatformChanged,
    required this.domains,
    required this.selectedDomain,
    required this.onDomainChanged,
    required this.isLoadingPlatforms,
    required this.isLoadingDomains,
    required this.storeNameController,
    required this.productLinkController,
    required this.keywordController,
    required this.productIdController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '플랫폼 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildPlatformDropdown(context),
        const SizedBox(height: 16),
        RewardInputField(
          label: '스토어명',
          controller: storeNameController,
          placeholder: '스토어명을 입력하세요',
          validator: (value) {
            if (value?.isEmpty ?? true) return '스토어명을 입력해주세요';
            return null;
          },
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
          label: '검색 키워드',
          controller: keywordController,
          placeholder: '검색 키워드를 입력하세요',
          validator: (value) {
            if (value?.isEmpty ?? true) return '검색 키워드를 입력해주세요';
            return null;
          },
        ),
        const SizedBox(height: 24),
        RewardInputField(
          label: '상품 ID',
          controller: productIdController,
          placeholder: '상품 ID를 입력하세요',
          validator: (value) {
            if (value?.isEmpty ?? true) return '상품 ID를 입력해주세요';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPlatformDropdown(BuildContext context) {
    if (isLoadingPlatforms) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: selectedPlatform,
            decoration: const InputDecoration(
              labelText: '플랫폼',
              border: OutlineInputBorder(),
            ),
            items: platforms.map((platform) {
              return DropdownMenuItem<int>(
                value: platform.id,
                child: Text(platform.name),
              );
            }).toList(),
            onChanged: onPlatformChanged,
            validator: (value) {
              if (value == null) return '플랫폼을 선택해주세요';
              return null;
            },
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
    );
  }
}