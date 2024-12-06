import 'package:flutter/material.dart';

class DomainHeader extends StatelessWidget {
  const DomainHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '도메인',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF344054),
          ),
        ),
        SizedBox(height: 6),
        Text(
          '플랫폼의 기본 도메인. 예: shopping.naver.com',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF667085),
          ),
        ),
      ],
    );
  }
} 