import 'package:flutter/material.dart';
import 'domain_status_tile.dart';

class DomainStatusList extends StatelessWidget {
  final List<Map<String, dynamic>>? domains;

  const DomainStatusList({
    Key? key,
    required this.domains,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (domains == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (domains!.isEmpty) {
      return const Center(child: Text('등록된 도메인이 없습니다.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '등록된 도메인 목록:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...domains!.map((domain) => DomainStatusTile(domain: domain)).toList(),
      ],
    );
  }
} 