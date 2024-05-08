import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget{
  const FormTextField({
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
    this.getFocusNode,
    this.getController
  });
  final String hintText;
  final double borderWidth;
  final double borderRadius;
  final Color? borderColor;
  final bool enabled;
  final Widget? icon;
  final bool autoOpen;
  final String? initValue;
  final String? errorText;
  final Color? backgroundColor;
  final int maxLines;
  final TextStyle? textStyle;
  final void Function(String text) onInput;
  final void Function(FocusNode node)? getFocusNode;
  final void Function(TextEditingController controller)? getController;

  @override
  State<StatefulWidget> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField>{
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller = TextEditingController(text: widget.initValue??'');
  @override
  void initState() {
    super.initState();
    if(widget.getFocusNode!=null){
      widget.getFocusNode!(_focusNode);
    }
    if(widget.getController!=null){
      widget.getController!(_controller);
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
      controller: _controller,
      enabled: widget.enabled,
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