import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePicker extends StatefulWidget{
  const DatePicker({
    super.key,
    required this.date,
    required this.onDateChange,
    this.selectionMode = DateRangePickerSelectionMode.single,
    this.toDate
  });
  final DateTime date;
  final DateTime? toDate;
  final void Function(dynamic date) onDateChange;
  final DateRangePickerSelectionMode selectionMode;

  @override
  State<StatefulWidget> createState() =>_StateDatePicker();
}

class _StateDatePicker extends State<DatePicker>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SfDateRangePicker(
        initialSelectedDate: widget.date,
        initialDisplayDate: widget.date,
        selectionColor: theme.primaryColor,
        todayHighlightColor:theme.primaryColor,
        selectionMode: widget.selectionMode,
        initialSelectedRange: (
          widget.selectionMode!=DateRangePickerSelectionMode.single?
          PickerDateRange(widget.date, widget.toDate):null),
        selectionTextStyle: TextStyle(
            color: Colors.white,
            fontSize: theme.textTheme.bodyMedium!.fontSize!
        ),
        onSelectionChanged: (args){
          widget.onDateChange(args);
        }
    );
  }
}