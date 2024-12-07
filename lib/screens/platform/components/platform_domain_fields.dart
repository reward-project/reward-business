import 'package:flutter/material.dart';
import '../../../models/platform/platform.dart';
import 'domain/domain_header.dart';
import 'domain/domain_field.dart';
import 'domain/domain_status_list.dart';

class PlatformDomainFields extends StatelessWidget {
  final List<TextEditingController> domainControllers;
  final Platform? selectedPlatform;
  final List<Map<String, dynamic>>? existingDomains;
  final Function onAddDomain;
  final Function(int) onRemoveDomain;

  PlatformDomainFields({
    Key? key,
    required this.onAddDomain,
    required this.domainControllers,
    required this.selectedPlatform,
    required this.existingDomains,
    required this.onRemoveDomain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DomainHeader(),
        const SizedBox(height: 6),
        if (selectedPlatform == null) ...[
          ...domainControllers.asMap().entries.map((entry) {
            return DomainField(
              index: entry.key,
              controller: entry.value,
              onRemove: () => onRemoveDomain(entry.key),
              isLastField: entry.key == domainControllers.length - 1,
              onAdd: () {
                onAddDomain();
              },
            );
          }).toList(),
        ] else if (selectedPlatform != null && existingDomains != null) ...[
          DomainStatusList(domains: existingDomains!),
          const SizedBox(height: 16),
          Text(
            '새로운 도메인 추가',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...domainControllers.asMap().entries.map((entry) {
            return DomainField(
              index: entry.key,
              controller: entry.value,
              onRemove: () => onRemoveDomain(entry.key),
              isLastField: entry.key == domainControllers.length - 1,
              onAdd: () {
                onAddDomain();
              },
            );
          }).toList(),
        ],
      ],
    );
  }
}