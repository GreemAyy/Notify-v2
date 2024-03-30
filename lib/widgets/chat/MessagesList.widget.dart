import 'package:flutter/material.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/chat/MessageItem.widget.dart';
import '../../custom_classes/message.dart';

class MessagesList extends StatefulWidget{
  MessagesList({
    super.key,
    required this.messagesList
  });
  List<Message> messagesList;

  @override
  State<StatefulWidget> createState() => _StateMessagesList();
}

class _StateMessagesList extends State<MessagesList>{
  final id = store.get<int>('id')!;
  late final messagesList = widget.messagesList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: messagesList.length,
        reverse: true,
        itemBuilder: (context, index){
          final message = messagesList[index];
          return MessageItem(
              message: message,
              self: message.creatorId==id
          );
        },
    );
  }
}