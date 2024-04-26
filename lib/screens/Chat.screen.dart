import 'package:flutter/material.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/store/store_flutter_lib.dart';
import 'package:notify/widgets/chat/BottomMessageBar.widget.dart';
import 'package:notify/widgets/chat/MessageFullscreen.dart';
import 'package:notify/widgets/chat/MessagesList.widget.dart';
import '../custom_classes/group.dart';
import '../store/store.dart';
import '../widgets/group/MyGroupsList.widget.dart';

class ChatScreen extends StatefulWidget{
  ChatScreen({
    super.key,
    required this.group
  });
  Group group;

  @override
  State<StatefulWidget> createState() => _StateChatScreen();
}

final rxPickedTasksList = Reactive(<Task>[]);
final rxPickedReplyMessage = Reactive<Message?>(null).nullable;
final rxPickedMessage = Reactive<Message?>(null).nullable;
final rxGroupMessages = Reactive<Map<int, List<Message>>>({});

class _StateChatScreen extends State<ChatScreen>{
  late Group group = widget.group;
  bool isLoading = false;
  bool isOpen = false;
  bool isReplyOpen = false;
  bool isMessageSettingOpen = false;
  Message? pickedMessage;
  final double bottomBarHeight = 75;
  final double topBarHeight = 70;
  final double bottomBarOpenHeight = 350;
  final double bottomReplyHeight = 50;

  @override
  void initState() {
    super.initState();
    store.set('on_chat', true, false);
  }

  @override
  void dispose() {
    super.dispose();
    store.set('on_chat', false, false);
    rxPickedReplyMessage.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
            children: [
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  height: screenSize.height-
                      topBarHeight-
                      (!isOpen?bottomBarHeight:bottomBarOpenHeight)-
                      MediaQuery.of(context).padding.top-
                      (isReplyOpen?bottomReplyHeight:0),
                  width: screenSize.width,
                  bottom: (!isOpen?bottomBarHeight:bottomBarOpenHeight)+
                      (isReplyOpen?bottomReplyHeight:0),
                  child: const Align(
                      alignment: Alignment.bottomCenter,
                      child: MessagesList()
                  )
              ),
              Positioned(
                  width: screenSize.width,
                  height: topBarHeight,
                  child: Container(
                      color: theme.scaffoldBackgroundColor,
                      child: GroupListItem(
                          onTap: (){
                            Navigator.of(context)
                                .pushNamed('/group',arguments: {"group":group});
                          },
                          group: group,
                          createLeading: true,
                          padding: (horizontal: 5, vertical: 5),
                          heroTag: 'hero_group_image_${group.id}'
                      )
                  )
              ),
              Positioned(
                  bottom: 0,
                  child: BottomMessageBar(
                    height: bottomBarHeight,
                    openHeight: bottomBarOpenHeight,
                    replyHeight: bottomReplyHeight,
                    onReply: () => setState(() => isReplyOpen = rxPickedReplyMessage.value != null),
                    onOpen: () => setState(() => isOpen = true),
                    onClose: () => setState(() => isOpen = false),
                  )
              ),
              const MessageFullscreen()
            ]
        )
      )
    );
  }
}
