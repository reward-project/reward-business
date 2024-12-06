import 'package:flutter/material.dart';
import '../../../models/platform/platform.dart';
import 'domain/domain_header.dart';
import 'domain/domain_field.dart';
import 'domain/domain_status_list.dart';

class PlatformDomainFields extends StatelessWidget {
  final List<TextEditingController> domainControllers;
  final Platform? selectedPlatform;
  final List<Map<String, dynamic>>? existingDomains;
  final VoidCallback onAddDomain;
  final Function(int) onRemoveDomain;

  const PlatformDomainFields({
    Key? key,
    required this.domainControllers,
    required this.selectedPlatform,
    required this.existingDomains,
    required this.onAddDomain,
    required this.onRemoveDomain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DomainHeader(),
        const SizedBox(height: 6),
        ...domainControllers.asMap().entries.map((entry) {
          return DomainField(
            controller: entry.value,
            index: entry.key,
            isLastField: entry.key == domainControllers.length - 1,
            onAdd: onAddDomain,
            onRemove: () => onRemoveDomain(entry.key),
          );
        }).toList(),
        if (selectedPlatform != null) ...[
          const SizedBox(height: 16),
          DomainStatusList(domains: existingDomains),
        ],
      ],
    );
  }
} 