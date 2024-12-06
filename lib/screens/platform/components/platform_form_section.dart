import 'package:flutter/material.dart';
import '../../../models/platform/platform.dart';
import '../../sales/components/reward_input_field.dart';
import 'platform_domain_fields.dart';

class PlatformFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController platformNameController;
  final TextEditingController displayNameController;
  final List<TextEditingController> domainControllers;
  final Platform? selectedPlatform;
  final List<Map<String, dynamic>>? existingDomains;
  final bool isLoading;
  final VoidCallback onAddDomain;
  final Function(int) onRemoveDomain;
  final VoidCallback onSubmit;

  const PlatformFormSection({
    Key? key,
    required this.formKey,
    required this.platformNameController,
    required this.displayNameController,
    required this.domainControllers,
    required this.selectedPlatform,
    required this.existingDomains,
    required this.isLoading,
    required this.onAddDomain,
    required this.onRemoveDomain,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPlatformNameField(),
            const SizedBox(height: 24),
            _buildDisplayNameField(),
            const SizedBox(height: 24),
            PlatformDomainFields(
              domainControllers: domainControllers,
              selectedPlatform: selectedPlatform,
              existingDomains: existingDomains,
              onAddDomain: onAddDomain,
              onRemoveDomain: onRemoveDomain,
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      selectedPlatform != null ? '플랫폼 수정' : '플랫폼 등록',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF344054),
      ),
    );
  }

  Widget _buildPlatformNameField() {
    return RewardInputField(
      label: '플랫폼 이름 (시스템용)',
      controller: platformNameController,
      placeholder: '영문, 숫자, 언더스코어(_)만 사용. 예: naver_shopping',
      enabled: selectedPlatform == null,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return '플랫폼 이름을 입력해주세요';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!)) {
          return '영문, 숫자, 언더스코어(_)만 사용 가능합니다';
        }
        return null;
      },
    );
  }

  Widget _buildDisplayNameField() {
    return RewardInputField(
      label: '플랫폼 이름 (표시용)',
      controller: displayNameController,
      placeholder: '화면에 표시될 이름을 입력하세요. 예: 네이버 쇼핑',
      enabled: selectedPlatform == null,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return '표시 이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              selectedPlatform != null ? '플랫폼 수정하기' : '플랫폼 등록하기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
} 