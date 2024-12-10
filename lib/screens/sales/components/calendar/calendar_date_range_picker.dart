import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class CalendarDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const CalendarDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateRangeSelected,
  });

  @override
  State<CalendarDateRangePicker> createState() => _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedMonth = DateTime.now();
  final _monthFormat = DateFormat('yyyy년 MM월');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  bool _isSelectedDate(DateTime date) {
    return (_startDate != null && isSameDay(date, _startDate)) ||
        (_endDate != null && isSameDay(date, _endDate));
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              );
            });
          },
        ),
        Text(
          _monthFormat.format(_focusedMonth),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        _buildWeekdayLabels(),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
        return SizedBox(
          width: 32,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: day == '일' ? Colors.red : day == '토' ? Colors.blue : const Color(0xFF666666),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: _getDaysInMonth(_focusedMonth),
      itemBuilder: (context, index) {
        final date = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          index + 1,
        );
        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected = _isSelectedDate(date);
    final isInRange = _isInRange(date);
    final isDisabled = date.isBefore(widget.firstDate) ||
        date.isAfter(widget.lastDate);
    final isWeekend = date.weekday == DateTime.saturday || 
        date.weekday == DateTime.sunday;
    final isToday = _isToday(date);

    return InkWell(
      onTap: isDisabled ? null : () => _handleDateTap(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : isInRange
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
          border: isToday
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isDisabled
                      ? Colors.grey.shade400
                      : isInRange
                          ? Theme.of(context).primaryColor
                          : isWeekend
                              ? date.weekday == DateTime.sunday
                                  ? Colors.red
                                  : Colors.blue
                              : null,
              fontWeight: isSelected || isToday
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('취소'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _startDate == null
              ? null
              : () {
                  widget.onDateRangeSelected(_startDate, _endDate);
                  context.pop();
                },
          child: const Text('선택'),
        ),
      ],
    );
  }

  void _handleDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || _endDate != null) {
        _startDate = date;
        _endDate = null;
      } else {
        if (date.isBefore(_startDate!)) {
          _startDate = date;
          _endDate = null;
        } else {
          _endDate = date;
        }
      }
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}