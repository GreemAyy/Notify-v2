import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/chat/MessageItem.widget.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../custom_classes/message.dart';
import '../../http/messages.http.dart';

class MessagesList extends StatefulWidget{
  const MessagesList({super.key});

  @override
  State<StatefulWidget> createState() => _StateMessagesList();
}

class _StateMessagesList extends State<MessagesList>{
  final id = store.get<int>('id')!;
  final socket = store.get<Socket>('socket')!;
  final _controller = ScrollController();
  var messagesList = <Message>[];
  var isLoading = true;
  var haveMore = true;

  @override
  initState() {
    var groupId = store.get<int>('group')!;
    if(rxGroupMessages.value[groupId]!=null) {
      messagesList = rxGroupMessages.value[groupId]!;
      setState(() {});
    }
    super.initState();
    socket.on('message', (data) {
      final message = Message.fromJson(data);
      setState(() => messagesList.insert(0, message));
      final groupMessages = rxGroupMessages.value;
      groupMessages[groupId] = [message,...messagesList];
      rxGroupMessages.value = groupMessages;
    });
    getMessagesAfter();
    _controller.addListener(controllerListener);
  }

  void controllerListener() {
    if(_controller.position.pixels==_controller.position.maxScrollExtent){
      if(!isLoading&&haveMore){
        getMessagesBefore();
      }
    }
  }

  void getMessagesBefore() async {
    setState(() => isLoading = true);
    var groupId = store.get<int>('group')!;
    final messageReq = await MessagesHttp
        .getMessagesBeforeId(groupId, messagesList.isNotEmpty?messagesList.last.id:0);
    setState(() {
      haveMore = messageReq.haveMore;
      messagesList = [...messagesList, ...messageReq.messages];
      final groupMessages = rxGroupMessages.value;
      if(groupMessages[groupId]==null) groupMessages[groupId] = messagesList;
      rxGroupMessages.value = groupMessages;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    socket.off('message');
    _controller.removeListener(controllerListener);
    _controller.dispose();
  }

  void getMessagesAfter() async {
    setState(() => isLoading = true);
    var groupId = store.get<int>('group')!;
    final messages = await MessagesHttp
                    .getMessagesAfterId(groupId, messagesList.isNotEmpty?messagesList.first.id:0);
    setState(() {
      messagesList = [...messages, ...messagesList];
      final groupMessages = rxGroupMessages.value;
      if(groupMessages[groupId]==null) groupMessages[groupId] = messagesList;
      rxGroupMessages.value = groupMessages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
            controller: _controller,
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
        ),
        AnimatedPositioned(
          top: isLoading ? 25: -100,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          duration: const Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 2,
                      sigmaY: 2
                    ),
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.1)
                      ),
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor
                      )
                    )
                  )
                )
              ]
            )
          )
        )
      ],
    );
  }
}