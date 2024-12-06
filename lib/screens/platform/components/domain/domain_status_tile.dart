import 'package:flutter/material.dart';

class DomainStatusTile extends StatelessWidget {
  final Map<String, dynamic> domain;

  const DomainStatusTile({
    Key? key,
    required this.domain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = domain['status'] as String;
    return ListTile(
      title: Text(domain['domain'] as String),
      subtitle: Text(_getDomainStatusText(status)),
      leading: Icon(
        _getDomainStatusIcon(status),
        color: _getDomainStatusColor(status),
      ),
    );
  }

  String _getDomainStatusText(String status) {
    return switch (status) {
      'ACTIVE' => '승인됨',
      'PENDING' => '대기중',
      'REJECTED' => '거절됨',
      _ => '알 수 없음'
    };
  }

  IconData _getDomainStatusIcon(String status) {
    return switch (status) {
      'ACTIVE' => Icons.check_circle,
      'PENDING' => Icons.hourglass_empty,
      'REJECTED' => Icons.cancel,
      _ => Icons.help
    };
  }

  Color _getDomainStatusColor(String status) {
    return switch (status) {
      'ACTIVE' => Colors.green,
      'PENDING' => Colors.orange,
      'REJECTED' => Colors.red,
      _ => Colors.grey
    };
  }
} 