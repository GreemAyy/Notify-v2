import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget{
  FormTextField({
    super.key,
    required this.onInput,
    this.enabled = true,
    this.hintText = 'Text',
    this.borderWidth = 1,
    this.borderColor,
    this.borderRadius = 35,
    this.backgroundColor,
    this.autoOpen = false,
    this.initValue,
    this.errorText,
    this.maxLines = 1,
    this.textStyle = const TextStyle(fontSize: 22.5),
    this.icon,
    this.getFocusNode
  });
  String hintText;
  double borderWidth;
  double borderRadius;
  Color? borderColor;
  bool enabled;
  Widget? icon;
  bool autoOpen;
  String? initValue;
  String? errorText;
  Color? backgroundColor;
  int maxLines;
  TextStyle? textStyle;
  void Function(String text) onInput;
  void Function(FocusNode node)? getFocusNode;

  @override
  State<StatefulWidget> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField>{
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    if(widget.getFocusNode!=null){
      widget.getFocusNode!(_focusNode);
    }
    if(widget.autoOpen){
      _requestFocus();
    }
  }
  void _requestFocus() {
    Future.microtask((){
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderTheme = OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.borderColor ?? theme.primaryColor,
            width: widget.borderWidth
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gapPadding: 0
    );

    return  TextFormField(
      style: widget.textStyle,
      enabled: widget.enabled,
      initialValue: widget.initValue,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
          filled: true,
          fillColor: widget.backgroundColor,
          hintText: widget.hintText,
          contentPadding:const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
          prefixIcon: widget.icon,
          errorText: widget.errorText,
          enabledBorder: borderTheme,
          focusedBorder: borderTheme
      ),
      onChanged: widget.onInput,
    );
  }
}