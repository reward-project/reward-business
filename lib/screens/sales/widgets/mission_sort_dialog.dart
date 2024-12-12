import 'package:flutter/material.dart';

enum MissionSortField {
  rewardAmount('리워드 금액'),
  startDate('시작일'),
  endDate('종료일'),
  createdAt('등록일');

  final String label;
  const MissionSortField(this.label);
}

class MissionSortDialog extends StatefulWidget {
  final MissionSortField? currentSortField;
  final bool isAscending;
  final Function(MissionSortField, bool) onApply;

  const MissionSortDialog({
    super.key,
    this.currentSortField,
    this.isAscending = true,
    required this.onApply,
  });

  @override
  State<MissionSortDialog> createState() => _MissionSortDialogState();
}

class _MissionSortDialogState extends State<MissionSortDialog> {
  late MissionSortField? _sortField;
  late bool _isAscending;

  @override
  void initState() {
    super.initState();
    _sortField = widget.currentSortField;
    _isAscending = widget.isAscending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정렬'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...MissionSortField.values.map((field) => RadioListTile<MissionSortField>(
            title: Text(field.label),
            value: field,
            groupValue: _sortField,
            onChanged: (value) => setState(() => _sortField = value),
          )),
          const Divider(),
          Row(
            children: [
              const Text('정렬 방향'),
              const Spacer(),
              ToggleButtons(
                isSelected: [_isAscending, !_isAscending],
                onPressed: (index) => setState(() => _isAscending = index == 0),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('오름차순'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('내림차순'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (_sortField != null) {
              widget.onApply(_sortField!, _isAscending);
            }
            Navigator.pop(context);
          },
          child: const Text('적용'),
        ),
      ],
    );
  }
} 