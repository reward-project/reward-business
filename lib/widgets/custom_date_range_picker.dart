import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateRangePicker extends StatelessWidget {
  final DateTimeRange? dateRange;
  final Function(DateTimeRange?) onDateRangeChanged;

  const CustomDateRangePicker({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTimeRange? result = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2025),
          initialDateRange: dateRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (result != null) {
          onDateRangeChanged(result);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '기간 선택',
          prefixIcon: Icon(Icons.date_range),
        ),
        child: Text(
          dateRange != null
              ? '${DateFormat('yy/MM/dd').format(dateRange!.start)} - ${DateFormat('yy/MM/dd').format(dateRange!.end)}'
              : '기간을 선택하세요',
          style: TextStyle(
            color: dateRange != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
