import 'dart:async';
import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget{
  const Skeleton({
    super.key,
    this.width = 0,
    required this.height,
    this.setWidthFromScreenParams = true,
    this.colorFrom = Colors.white,
    this.colorTo = const Color.fromARGB(150, 150, 150, 150),
    this.borderRadius = 0,
    this.verticalOuterPadding = 0,
    this.horizontalOuterPadding = 0,
    this.colorUpdateDuration = const Duration(milliseconds: 500)
  });
  final double width;
  final double height;
  final bool setWidthFromScreenParams;
  final Color colorFrom;
  final Color colorTo;
  final double borderRadius;
  final double verticalOuterPadding;
  final double horizontalOuterPadding;
  final Duration colorUpdateDuration;

  @override
  State<StatefulWidget> createState() => _StateSkeleton();
}

class _StateSkeleton extends State<Skeleton>{
  int colorIndex = 0;
  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(widget.colorUpdateDuration, (_) {
      setState(() => colorIndex = colorIndex == 1 ? 0 : 1);
    });
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
        duration: widget.colorUpdateDuration,
        width: screenWidth==0&&widget.setWidthFromScreenParams ? screenWidth : widget.width,
        height: widget.height,
        margin: EdgeInsets.symmetric(vertical: widget.verticalOuterPadding, horizontal: widget.horizontalOuterPadding),
        decoration: BoxDecoration(
            color: colorIndex == 0 ? widget.colorFrom : widget.colorTo,
            borderRadius: BorderRadius.circular(widget.borderRadius)
        )
    );
  }
}
