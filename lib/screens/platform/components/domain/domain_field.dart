import 'package:flutter/material.dart';

class DomainField extends StatelessWidget {
  final TextEditingController controller;
  final int index;
  final bool isLastField;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const DomainField({
    super.key,
    required this.controller,
    required this.index,
    required this.isLastField,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '도메인을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '도메인을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            _buildButton(context),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLastField ? onAdd : onRemove,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLastField ? Theme.of(context).primaryColor : Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        isLastField ? '추가' : '삭제',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 