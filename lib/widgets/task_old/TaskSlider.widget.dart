import 'dart:async';
import 'package:flutter/material.dart';
import 'TasksList.widget.dart';
import '../../store/store.dart';

class TaskSlider extends StatefulWidget{
  TaskSlider({
    super.key,
    required this.tabHeight,
    required this.onNext,
    required this.onPrevious
  });
  double tabHeight;
  void Function() onNext;
  void Function() onPrevious;

  @override
  State<StatefulWidget> createState() => _StateTaskSlider();
}

class _StateTaskSlider extends State<TaskSlider>{
  double start = 0;
  double currentPosition = 0;
  bool disableAnimation = false;
  bool isLoading = store.get<bool>('task_is_loading')!;
  late final double tabHeight = widget.tabHeight;
  late final screenSize = MediaQuery.of(context).size;
  late Map<String, double> leftItemPos = {'x':-screenSize.width, 'y':0};
  late Map<String, double> rightItemPos = {'x':screenSize.width, 'y':0};
  Duration slideDuration = const Duration(milliseconds: 250);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    store.watch<bool>('task_is_loading', (loading) {
      print(loading);
      setState(() => isLoading = loading);;
    });
  }
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    store.unSee('task_is_loading');
  }

  void toDefault(){
    setState(() => isLoading = true);
    timer = Timer(slideDuration, () {
      setState(() {
        disableAnimation = true;
        leftItemPos['x'] = -screenSize.width;
        rightItemPos['x'] = screenSize.width;
        isLoading = false;
      });
      timer!.cancel();
    });
  }

  void next (){
    setState(() => rightItemPos['x'] = 0);
    toDefault();
    widget.onNext();
  }
  void previous(){
    setState(() => leftItemPos['x'] = 0);
    toDefault();
    widget.onPrevious();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return GestureDetector(
        onHorizontalDragStart: (details){
          setState(() {
            if(!isLoading){
              disableAnimation = true;
              start = details.globalPosition.dx;
            }
          });
        },
        onHorizontalDragUpdate: (details){
          var globalDX = details.globalPosition.dx;
          if(!isLoading){
            setState(() {
              currentPosition = start - globalDX;
              var dir = start>globalDX? 1 : -1; // left = -1 right = 1
              leftItemPos['x'] = dir==-1?
              -screenSize.width-(currentPosition-start)-start:
              -screenSize.width;
              rightItemPos['x'] = dir==1?
              screenSize.width-currentPosition.abs():
              screenSize.width;
            });
          }
        },
        onHorizontalDragEnd: (details){
          if(!isLoading){
            setState(() {
              disableAnimation = false;
              if(currentPosition>=screenSize.width/4){
                next();
              }else if(currentPosition<=-(screenSize.width/4)){
                previous();
              }else{
                leftItemPos['x'] = -screenSize.width;
                rightItemPos['x'] = screenSize.width;
              }
              currentPosition = 0;
            });
          }
        },
        child: SingleChildScrollView(
            child: SizedBox(
              height: tabHeight*24,
              width: screenSize.width,
              child: Stack(
                  children: [
                    TimeList(
                      tabHeight: tabHeight,
                      height: tabHeight*24,
                      xPos: 0,
                      yPos: 0,
                      disableAnimation: disableAnimation,
                      duration: slideDuration,
                    ),
                    Positioned(
                        top: 0,
                        left: 0,
                        width: screenSize.width,
                        height: tabHeight*24,
                        child: TasksList(
                            initDate: store.get<DateTime>('date')!,
                            tabHeight: tabHeight,
                            height: tabHeight
                        )
                    ),
                    TimeList(
                      tabHeight: tabHeight,
                      height: tabHeight*24,
                      xPos: leftItemPos['x']!,
                      yPos: leftItemPos['y']!,
                      disableAnimation: disableAnimation,
                      duration: slideDuration,
                    ),
                    TimeList(
                      tabHeight: tabHeight,
                      height: tabHeight*24,
                      xPos: rightItemPos['x']!,
                      yPos: rightItemPos['y']!,
                      disableAnimation: disableAnimation,
                      duration: slideDuration,
                    )
                  ]
              ),
            )
          ),
        );
  }
}

class TimeList extends StatefulWidget{
  TimeList({
    super.key,
    required this.tabHeight,
    required this.xPos,
    required this.yPos,
    required this.height,
    required this.disableAnimation,
    this.duration = const Duration(milliseconds: 50),
  });
  double tabHeight;
  double xPos;
  double yPos;
  double height;
  bool disableAnimation;
  Duration duration;

  @override
  State<StatefulWidget> createState() => _StateTimeList();
}

class _StateTimeList extends State<TimeList>{

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPositioned(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        duration: widget.disableAnimation?
        Duration.zero:
        widget.duration,
        top: widget.yPos,
        left: widget.xPos,
        child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: List.generate(24, (index){
                return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 10),
                    height: widget.tabHeight,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: theme.textTheme.bodyMedium!.color!.withOpacity(.5)
                        )
                    ),
                    child: Text(
                        '${index<10?'0':''}$index:00',
                        style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600
                        )
                    )
                );
              })
            )
        )
    );
  }
}