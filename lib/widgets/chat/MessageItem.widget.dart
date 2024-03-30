import 'package:flutter/material.dart';
import 'package:notify/custom_classes/message.dart';

class MessageItem extends StatefulWidget{
  MessageItem({
    super.key,
    required this.message,
    this.self = true
  });
  Message message;
  bool self;

  @override
  State<StatefulWidget> createState() => _StateMessageItem();
}

class _StateMessageItem extends State<MessageItem>{
  late final message = widget.message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: widget.self?Alignment.centerLeft:Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width*.8,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 5),
        decoration: BoxDecoration(
          color: theme.textTheme.bodyMedium!.color!.withOpacity(.05),
          borderRadius: BorderRadius.only(
            topLeft:const Radius.circular(7.5),
            topRight:const Radius.circular(7.5),
            bottomRight:!widget.self?Radius.zero:const Radius.circular(7.5),
            bottomLeft: widget.self?Radius.zero:const Radius.circular(7.5)
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                message.text,
                style: theme.textTheme.bodyMedium!.copyWith(
                    fontSize: theme.textTheme.bodyMedium!.fontSize!-5
                )
            )
          ]
        )
      )
    );
  }
}

class GridMessageMedia extends StatelessWidget{
  GridMessageMedia({
    super.key,
    required this.media
  });
  List<MessageMedia> media;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}