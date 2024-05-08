import 'package:flutter/material.dart';

class Optional extends StatelessWidget{
  const Optional({
    super.key,
    required this.conditional,
    required this.complited,
    required this.uncomplited
  });
  final bool conditional;
  final Widget complited;
  final Widget uncomplited;

  @override
  Widget build(BuildContext context) {
    return conditional ? complited : uncomplited;
  }
}