import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MissionFilterSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedStatus;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(String?) onStatusChanged;
  final Function() onFilterApplied;

  const MissionFilterSection({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedStatus,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onStatusChanged,
    required this.onFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDateField(
                  context,
                  label: '시작일',
                  value: startDate,
                  onChanged: onStartDateChanged,
                ),
                const SizedBox(width: 8),
                const Text('~'),
                const SizedBox(width: 8),
                _buildDateField(
                  context,
                  label: '종료일',
                  value: endDate,
                  onChanged: onEndDateChanged,
                ),
                const SizedBox(width: 16),
                _buildStatusDropdown(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onFilterApplied,
            icon: const Icon(Icons.filter_list),
            label: const Text('필터 적용'),
          ),
        ],
      ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null
                  ? DateFormat('yyyy-MM-dd').format(value)
                  : label,
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: selectedStatus,
        hint: const Text('상태'),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: null,
            child: Text('전체'),
          ),
          DropdownMenuItem(
            value: 'ACTIVE',
            child: Text('진행중'),
          ),
          DropdownMenuItem(
            value: 'SCHEDULED',
            child: Text('예정'),
          ),
          DropdownMenuItem(
            value: 'EXPIRED',
            child: Text('만료'),
          ),
        ],
        onChanged: onStatusChanged,
      ),
    );
  }
} 