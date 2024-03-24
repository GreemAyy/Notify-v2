import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class TimerPicker extends StatefulWidget{
  TimerPicker({
    super.key,
    required this.timeFrom,
    required this.timeTo,
    required this.onDateChange,
    this.disabled = false
  });
  TimeOfDay timeFrom;
  TimeOfDay timeTo;
  bool disabled;
  void Function(({TimeOfDay from, TimeOfDay to}) date) onDateChange;

  @override
  State<StatefulWidget> createState() => _StateTimerPicker();
}

class _StateTimerPicker extends State<TimerPicker>{
  late final _S = S.of(context);
  late TimeOfDay timeFrom = widget.timeFrom;
  late TimeOfDay timeTo   = widget.timeTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: widget.disabled?0.5:1,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
                onPressed: (){
                  if(widget.disabled) return;
                  showTimePicker(
                      context: context,
                      initialEntryMode: TimePickerEntryMode.inputOnly,
                      initialTime: timeFrom
                  ).then((newTime){
                    //&&moreThen(timeTo, newTime)
                    if(newTime!=null){
                      setState(() => timeFrom = newTime);
                    }
                    widget.onDateChange((from: timeFrom, to: timeTo));
                  });
                },
                style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    side: BorderSide(
                        color: theme.primaryColor
                    )
                ),
                child: Text(
                    "${_S.task_from} ${timeFrom.format(context)}",
                    style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600
                    )
                )
            ),
            OutlinedButton(
                onPressed: (){
                  if(widget.disabled) return;
                  showTimePicker(
                      context: context,
                      initialEntryMode: TimePickerEntryMode.inputOnly,
                      initialTime: timeTo
                  ).then((newTime){
                    //&&moreThen(newTime, timeFrom)
                    if(newTime!=null){
                      setState(() => timeTo = newTime);
                    }
                    widget.onDateChange((from: timeFrom, to: timeTo));
                  });
                },
                style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    side: BorderSide(
                        color: theme.primaryColor
                    )
                ),
                child: Text(
                    "${_S.task_to} ${timeTo.format(context)}",
                    style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600
                    )
                )
            )
          ]
      ),
    );
  }
}