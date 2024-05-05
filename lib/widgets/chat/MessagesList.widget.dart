import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:notify/store/collector.dart';
import 'package:notify/widgets/chat/MessageItem.widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../custom_classes/message.dart';
import '../../http/messages.http.dart';

class MessagesList extends StatefulWidget{
  const MessagesList({super.key});

  @override
  State<StatefulWidget> createState() => _StateMessagesList();
}

final messageUpdater = Updater();

class _StateMessagesList extends State<MessagesList>{
  final id = store.get<int>('id')!;
  final socket = store.get<Socket>('socket')!;
  var messagesList = <Message>[];
  var isLoading = false;
  var haveMore = true;
  var showToStartArrow = false;
  final _itemScrollController = ItemScrollController();
  final _itemPositionListener = ItemPositionsListener.create();

  @override
  initState() {
    final groupId = store.get<int>('group')!;
    if(rxGroupMessages.value[groupId]!=null) {
      setState(() => messagesList = rxGroupMessages.value[groupId]!);
    }
    super.initState();
    messageUpdater.watch<List<Message>>('new', (messages) {
      if(store.get<bool>('on_chat')!&&messages.first.groupId==groupId) {
        setState(() => messagesList = messages);
      }
    });
    messageUpdater.watch<Map<String, int>>('delete', (data) {
      final groupId = store.get<int>('group')!;
      final id = data['message_id'];
      final groupIdData = data['group_id'];
      if(store.get<bool>('on_chat')!&&groupId == groupIdData){
        setState(() => messagesList.removeWhere((e) => e.id == id));
      }
      messageUpdater.updateWithData('update-reply-delete', id);
    });
    messageUpdater.watch<Map<String, dynamic>>('update', (data) {
      final message = data['message'] as Message;
      final index = data['index'] as int;
      setState(() => messagesList[index] = message);
      messageUpdater.updateWithData('update-reply', message);
    });
    if(messagesList.isEmpty) getMessagesAfter();
    _itemPositionListener.itemPositions.addListener(_itemPositionListenerListener);
    _scrollToListener();
  }

  void _itemPositionListenerListener () {
    if(
      _itemPositionListener.itemPositions.value.last.index == messagesList.length-1&&
      !isLoading && haveMore
    ){
      getMessagesBefore();
    }
    if(_itemPositionListener.itemPositions.value.first.index == 0&&showToStartArrow){
      setState(() => showToStartArrow = false);
    }
    if(_itemPositionListener.itemPositions.value.first.index != 0&&!showToStartArrow){
      setState(() => showToStartArrow = true);
    }
  }

  Future<void> getMessagesBefore() async {
    setState(() => isLoading = true);
    var groupId = store.get<int>('group')!;
    final messageReq = await MessagesHttp
        .getMessagesBeforeId(groupId, messagesList.last.id);
    setState(() {
      haveMore = messageReq.haveMore;
      messagesList.addAll(messageReq.messages);
      final groupMessages = rxGroupMessages.value;
      groupMessages[groupId] = messagesList;
      rxGroupMessages.value = groupMessages;
      isLoading = false;
    });
  }

  Future<void> getMessagesUntil(int id) async {
    setState(() => isLoading = true);
    var groupId = store.get<int>('group')!;
    final messages = await MessagesHttp
        .getMessagesUntil(groupId, messagesList.last.id, id);
    setState(() {
      messagesList.addAll(messages);
      final groupMessages = rxGroupMessages.value;
      if(groupMessages[groupId]==null) groupMessages[groupId] = messagesList;
      rxGroupMessages.value = groupMessages;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageUpdater.multiUnSee(['new', 'delete', 'update', 'update-reply', 'scroll_to_message']);
    _itemPositionListener.itemPositions.removeListener(_itemPositionListenerListener);
  }

  Future<void> getMessagesAfter() async {
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

  void _scrollToListener(){
    messageUpdater.watch<int>('scroll_to_message', (id) async {
      var index = -1;
      for (var i = 0; i < messagesList.length; i++) {
       if(messagesList[i].id==id) {
         index = i;
       }
      }
      if(index<0) return;
      try{
        _itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 300)
        );
      }catch(_){}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollablePositionedList.builder(
            itemCount: messagesList.length,
            reverse: true,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionListener,
            itemBuilder: (context, index){
              final message = messagesList[index];
              return MessageItem(
                  key: Key(message.id.toString()),
                  message: message,
                  self: message.creatorId==id
              );
            }
        ),
        AnimatedPositioned(
          top: isLoading ? 25 : -100,
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
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor
                      )
                    )
                  )
                )
              ]
            )
          )
        ),
        Positioned(
            bottom: 10,
            right: 10,
            child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: showToStartArrow ? 1 : 0,
                child: IconButton(
                  onPressed: () =>
                    _itemScrollController.scrollTo(
                        index: 0,
                        duration: const Duration(milliseconds: 300)
                    ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(.75)
                  ),
                  icon: const Icon(
                    Icons.arrow_downward_sharp,
                    size: 35
                  )
                )
            )
        )
      ]
    );
  }
}