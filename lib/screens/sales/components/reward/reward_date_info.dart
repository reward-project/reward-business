import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../reward_input_field.dart';
import '../calendar/calendar_date_range_picker.dart';

class RewardDateInfo extends StatelessWidget {
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String, bool) onDateInput;
  final VoidCallback onCalendarPressed;

  const RewardDateInfo({
    Key? key,
    required this.startDateController,
    required this.endDateController,
    required this.startDate,
    required this.endDate,
    required this.onDateInput,
    required this.onCalendarPressed,
  }) : super(key: key);

  String _formatDate(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.length > 8) {
      value = value.substring(0, 8);
    }
    if (value.length >= 4) {
      value = '${value.substring(0, 4)}-${value.substring(4)}';
    }
    if (value.length >= 7) {
      value = '${value.substring(0, 7)}-${value.substring(7)}';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // 작업 기간 일수 계산
    final int totalDays = startDate != null && endDate != null
        ? endDate!.difference(startDate!).inDays + 1
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '작업 기간',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RewardInputField(
                label: '시작일',
                controller: startDateController,
                placeholder: 'YYYY-MM-DD',
                readOnly: false,
                onChanged: (value) {
                  final formattedValue = _formatDate(value);
                  if (formattedValue != value) {
                    startDateController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(offset: formattedValue.length),
                    );
                  }
                  if (formattedValue.length == 10) {
                    onDateInput(formattedValue, true);
                  }
                },
                validator: (value) => value?.isEmpty ?? true ? '시작일을 입력해주세요' : null,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('~'),
            ),
            Expanded(
              child: RewardInputField(
                label: '종료일',
                controller: endDateController,
                placeholder: 'YYYY-MM-DD',
                readOnly: false,
                onChanged: (value) {
                  final formattedValue = _formatDate(value);
                  if (formattedValue != value) {
                    endDateController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(offset: formattedValue.length),
                    );
                  }
                  if (formattedValue.length == 10) {
                    onDateInput(formattedValue, false);
                  }
                },
                validator: (value) => value?.isEmpty ?? true ? '종료일을 입력해주세요' : null,
              ),
            ),
            Container(
              height: 48,
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.calendar_month, size: 28),
                onPressed: onCalendarPressed,
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ],
        ),
        if (totalDays > 0) ...[
          const SizedBox(height: 8),
          Text(
            '총 작업 기간: ${totalDays}일',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          '* 효과를 볼려면 2주에서 한달 정도 걸립니다.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }
} 