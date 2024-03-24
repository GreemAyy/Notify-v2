import 'package:notify/widgets/ui/DatePicker.ui.dart';
import 'package:flutter/material.dart';

void showDatePickerModal(BuildContext context, DateTime date, void Function(DateTime date) onDateChange){
  showModalBottomSheet(
      showDragHandle: true,
      enableDrag: false,
      context: context,
      builder: (context){
        return Container(
          height: MediaQuery.of(context).size.height*.4,
          padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
          child: Column(
            children: [
              DatePicker(
                  date: date,
                  onDateChange: (args){
                    onDateChange(args.value as DateTime);
                    Navigator.pop(context);
                  }
              )
            ]
          )
        );
      }
  );
}