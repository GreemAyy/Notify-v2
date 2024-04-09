import 'dart:async';
import 'package:notify/widgets/task/SecondTasksList.widget.dart';
import 'package:flutter/material.dart';
import '../../store/store.dart';
import 'LoadingPlaceholder.widget.dart';

class SecondTaskSlider extends StatefulWidget{
  SecondTaskSlider({
    super.key,
    required this.height,
    required this.onNext,
    required this.onPrevious
  });
  double height;
  void Function() onNext;
  void Function() onPrevious;

  @override
  State<StatefulWidget> createState() => _StateSecondTaskSlider();
}

class _StateSecondTaskSlider extends State<SecondTaskSlider>{
  double start = 0;
  double currentPosition = 0;
  bool disableAnimation = false;
  bool isLoading = store.get<bool>('task_is_loading')!;
  late final screenSize = MediaQuery.of(context).size;
  late Map<String, double> leftItemPos = {'x':-screenSize.width, 'y':0};
  late Map<String, double> rightItemPos = {'x':screenSize.width, 'y':0};
  Duration slideDuration = const Duration(milliseconds: 250);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    store.watch<bool>('task_is_loading', (loading) {
      setState(() => isLoading = loading);
    });
  }
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    store.unSee('task_is_loading');
    store.mapMultiSet({
      'task_is_loading': false,
      'date': DateTime.now()
    });
  }

  void toDefault(){
    setState(() => isLoading = true);
    var timeToChange = Duration(milliseconds: slideDuration.inMilliseconds*2);
    timer = Timer(timeToChange, () {
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
        child:SizedBox(
              height: widget.height,
              width: screenSize.width,
              child: Stack(
                  children: [
                    TimeList(
                      height: widget.height,
                      xPos: 0,
                      yPos: 0,
                      disableAnimation: disableAnimation,
                      duration: slideDuration,
                      child: SecondTasksList(display: !isLoading)
                    ),
                    TimeList(
                      height: widget.height,
                      xPos: leftItemPos['x']!,
                      yPos: leftItemPos['y']!,
                      disableAnimation: disableAnimation,
                      duration: slideDuration,
                      child: LoadingPlaceholder()
                    ),
                    TimeList(
                      height: widget.height,
                      xPos: rightItemPos['x']!,
                      yPos: rightItemPos['y']!,
                      disableAnimation: disableAnimation,
                      duration: slideDuration,
                      child: LoadingPlaceholder()
                    )
                  ]
              ),
            )
          );
  }
}

class TimeList extends StatefulWidget{
  TimeList({
    super.key,
    required this.xPos,
    required this.yPos,
    required this.height,
    required this.disableAnimation,
    required this.child,
    this.duration = const Duration(milliseconds: 50),
  });
  double xPos;
  double yPos;
  double height;
  bool disableAnimation;
  Duration duration;
  Widget child;

  @override
  State<StatefulWidget> createState() => _StateTimeList();
}

class _StateTimeList extends State<TimeList>{
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        duration: widget.disableAnimation?//->
                  Duration.zero://->
                  widget.duration,
        top: widget.yPos,
        left: widget.xPos,
        child: widget.child
    );
  }
}
