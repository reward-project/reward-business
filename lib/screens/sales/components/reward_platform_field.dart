import 'package:flutter/material.dart';
import '../../../models/platform/platform.dart';

class RewardPlatformField extends StatelessWidget {
  final List<Platform> platforms;
  final int? selectedPlatform;
  final bool isLoading;
  final Function(int?) onChanged;

  const RewardPlatformField({
    super.key,
    required this.platforms,
    required this.selectedPlatform,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,  // 높이 고정
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,  // 드롭다운 정렬 개선
                child: DropdownButtonFormField<int>(
                  value: selectedPlatform,
                  hint: const Text(
                    '플랫폼을 선택하세요',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                  isExpanded: true,
                  items: platforms.map((platform) {
                    return DropdownMenuItem<int>(
                      value: platform.id,
                      child: Text(platform.displayName ?? platform.name),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
    );
  }
} 