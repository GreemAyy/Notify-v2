import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/chat/MessageItem.widget.dart';
import 'package:socket_io_client/socket_io_client.dart';
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
  final socket = store.get<Socket>('socket')!;
  late final messagesList = widget.messagesList;
  // var messagesList = <Message>[];

  @override
  initState() {
    super.initState();
    socket.on('message', (data) {
      final message = Message.fromJson(data);
      setState(() {
        messagesList.insert(0, message);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    socket.off('message');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: messagesList.length,
        reverse: true,
        itemBuilder: (context, index){
          final message = messagesList[index];
          return MessageItem(
              key: Key(message.id.toString()),
              message: message,
              self: message.creatorId==id
          );
        },
    );
  }
}