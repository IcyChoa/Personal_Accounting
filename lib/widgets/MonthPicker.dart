import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onMonthSelected;
  final Color? headerIconColor;
  final TextStyle? yearTextStyle;
  final Color? selectedMonthColor;
  final Color? unselectedMonthColor;
  final TextStyle? monthTextStyle;
  final Color? dialogBackgroundColor;
  final TextStyle? cancelTextStyle;
  final TextStyle? okTextStyle;

  const MonthPicker({
    super.key,
    required this.initialMonth,
    this.onMonthSelected,
    this.headerIconColor,
    this.yearTextStyle,
    this.selectedMonthColor,
    this.unselectedMonthColor,
    this.monthTextStyle,
    this.dialogBackgroundColor,
    this.cancelTextStyle,
    this.okTextStyle,
  });

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  late int _year;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
  }

  void _incrementYear() => setState(() => _year++);
  void _decrementYear() => setState(() => _year--);

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (i) => i + 1);

    return Dialog(
      backgroundColor: widget.dialogBackgroundColor ?? Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: widget.headerIconColor ?? Theme.of(context).iconTheme.color,
                  onPressed: _decrementYear,
                ),
                Text(
                  '$_year',
                  style: widget.yearTextStyle ?? Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: widget.headerIconColor ?? Theme.of(context).iconTheme.color,
                  onPressed: _incrementYear,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: months.map((month) {
                final label = DateFormat.MMM().format(DateTime(_year, month));
                final isSelected = _selectedMonth == month;
                final defaultTextStyle = widget.monthTextStyle ?? Theme.of(context).textTheme.bodyMedium!;
                return ChoiceChip(
                  label: Text(
                    label,
                    style: defaultTextStyle.copyWith(
                      color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : defaultTextStyle.color,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: widget.selectedMonthColor ?? Theme.of(context).primaryColor,
                  backgroundColor: widget.unselectedMonthColor ?? Theme.of(context).chipTheme.backgroundColor,
                  side: BorderSide(color: isSelected
                      ? widget.selectedMonthColor ?? Theme.of(context).primaryColor
                      : widget.unselectedMonthColor ?? Theme.of(context).chipTheme.backgroundColor!),
                  onSelected: (_) => setState(() => _selectedMonth = month),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          OverflowBar(
            spacing: 8,
            overflowSpacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: widget.cancelTextStyle),
              ),
              TextButton(
                onPressed: () {
                  final selected = DateTime(_year, _selectedMonth);
                  widget.onMonthSelected?.call(selected);
                  Navigator.of(context).pop(selected);
                },
                child: Text('OK', style: widget.okTextStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}