import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MissionFilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedStatus;
  final Function(DateTime?, DateTime?, String?) onApply;

  const MissionFilterDialog({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedStatus,
    required this.onApply,
  });

  @override
  State<MissionFilterDialog> createState() => _MissionFilterDialogState();
}

class _MissionFilterDialogState extends State<MissionFilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedStatus = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('필터'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('기간', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDateField(
                context,
                label: '시작일',
                value: _startDate,
                onChanged: (date) => setState(() => _startDate = date),
              ),
              const SizedBox(width: 8),
              const Text('~'),
              const SizedBox(width: 8),
              _buildDateField(
                context,
                label: '종료일',
                value: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildStatusDropdown(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(_startDate, _endDate, _selectedStatus);
            Navigator.pop(context);
          },
          child: const Text('적용'),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        onChanged(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value != null ? DateFormat('yyyy-MM-dd').format(value) : label,
          style: TextStyle(
            color: value != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      value: _selectedStatus,
      isExpanded: true,
      hint: const Text('전체'),
      items: const [
        DropdownMenuItem(value: null, child: Text('전체')),
        DropdownMenuItem(value: 'ACTIVE', child: Text('진행중')),
        DropdownMenuItem(value: 'SCHEDULED', child: Text('예정')),
        DropdownMenuItem(value: 'EXPIRED', child: Text('만료')),
      ],
      onChanged: (value) => setState(() => _selectedStatus = value),
    );
  }
} 