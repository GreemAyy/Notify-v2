import 'package:intl/intl.dart';

DateTime convertDateFromFormatString(String dateFormat){
  final [timeStr, dateStr] = dateFormat.split('-');
  final time = timeStr.split(':').map((e) => int.parse(e)).toList();
  final date = dateStr.split('/').map((e) => int.parse(e)).toList();
  return DateTime(date[2], date[1], date[0], time[1], time[0]);
}

String convertDateToMessageFormat(DateTime dateToFormat){
  return DateFormat('mm:HH dd/MM/yyyy').format(dateToFormat);
}