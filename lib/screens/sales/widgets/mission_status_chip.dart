import 'package:flutter/material.dart';

class MissionStatusChip extends StatelessWidget {
  final String status;

  const MissionStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'ACTIVE':
        color = Colors.blue;
        label = '진행중';
        break;
      case 'PENDING':
        color = Colors.orange;
        label = '대기중';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = '완료';
        break;
      case 'FAILED':
        color = Colors.red;
        label = '실패';
        break;
      default:
        color = Colors.grey;
        label = '알 수 없음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
