import 'package:flutter/material.dart';

class Optional extends StatelessWidget{
  Optional({
    super.key,
    required this.conditional,
    required this.complited,
    required this.uncomplited
  });
  bool conditional;
  Widget complited;
  Widget uncomplited;

  @override
  Widget build(BuildContext context) {
    return conditional ? complited : uncomplited;
  }
}