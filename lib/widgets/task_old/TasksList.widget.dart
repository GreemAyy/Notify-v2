import 'dart:async';
import 'package:flutter/material.dart';
import '../../custom_classes/task.dart';
import '../../store/store.dart';

class TasksList extends StatefulWidget{
  TasksList({
    super.key,
    required this.initDate,
    required this.tabHeight,
    required this.height
  });
  DateTime initDate;
  double tabHeight;
  double height;

  @override
  State<StatefulWidget> createState() => _StateTasksList();
}

class _StateTasksList extends State<TasksList>{
  bool isLoading = false;
  late var date = widget.initDate;

  @override
  void initState() {
    super.initState();
    store.watch<DateTime>('date', (newDate) async {
      store.set('task_is_loading', true);
      setState(() {
        isLoading = true;
        date = newDate;
      });
      Timer(Duration(seconds: 1),(){
        setState(() {
          isLoading = false;
        });
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    store.unSee('date');
    store.set('task_is_loading', false, false);
  }

  double convertToMinutes(int hour, int minutes){
    return ((hour*60)+minutes).toDouble();
  }

  Map<String, double> calcSize(Task task, DateTime date, double tabHeight){
    Map<String, double> sizes = {};
    var currentDate = DateTime(date.year, date.month, date.day);
    var from = DateTime(task.yearFrom,task.monthFrom,task.dayFrom);
    var to = DateTime(task.yearTo,task.monthTo,task.dayTo);
    var compareFrom = from.compareTo(currentDate);
    var compareTo = to.compareTo(currentDate);
    var minutesFrom = convertToMinutes(task.hourFrom, task.minuteFrom);
    var minutesTo = convertToMinutes(task.hourTo, task.minuteTo);
    var tabInMinutes = tabHeight/600;
    if(compareFrom==0&&compareTo==0){
      sizes['height'] = minutesTo-minutesFrom;
      sizes['top'] = minutesFrom*tabInMinutes;
    }else if(compareFrom==0&&compareTo>0){
      sizes['height'] = tabHeight*24-minutesFrom;
      sizes['top'] = minutesFrom*tabInMinutes;
    }else if(compareFrom<0&&compareTo>0){
      sizes['height'] = tabHeight*24;
      sizes['top'] = 0;
    }else if(compareFrom<0&&compareTo==0){
      sizes['height'] = tabHeight*24-minutesTo;
      sizes['top'] = 0;
    }else{
      sizes['top'] = 0;
      sizes['height'] = 0;
    }
    return sizes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Stack(
        children: [
            ...<Task>[].map((task){
              var sizes = calcSize(task, date, widget.tabHeight);
              return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  width: screenSize.width*.8,
                  height: sizes['height'],
                  right: isLoading? -screenSize.width*2 : 10,
                  top: sizes['top'],
                  child: Container(
                        decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(.5),
                            borderRadius: const BorderRadius.all(Radius.circular(15))
                        ),
                        child:  Column(
                              children: [
                                Flexible(
                                    child: Text(task.title)
                                )
                              ]
                          )
                    )

              );
            }).toList()
        ]
      );
  }
}