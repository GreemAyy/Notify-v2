import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/chat/MessageItem.widget.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../custom_classes/message.dart';
import '../../generated/l10n.dart';
import '../../http/messages.http.dart';

class MessageFullscreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateMessageFullscreen();
}

class _StateMessageFullscreen extends State<MessageFullscreen> {
  dynamic deleter;
  var canPop = true;
  var show = false;

  @override
  initState() {
    super.initState();
    deleter = rxPickedMessage.watch((message) {
      setState(() => canPop = message == null);
    });
  }

  @override
  dispose(){
    super.dispose();
    deleter();
  }

  @override
  Widget build(BuildContext context) {
    return rxPickedMessage.toBuilder((context) {
      final screenSize = MediaQuery.of(context).size;

      if(rxPickedMessage.value != null) {
        Timer(const Duration(milliseconds: 100), (){
          setState(() => show = rxPickedMessage.value != null);
        });
      }

      return PopScope(
        canPop: canPop,
        onPopInvoked: (_){
          setState(() {
            rxPickedMessage.value = null;
            canPop = true;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              width: screenSize.width,
              height: rxPickedMessage.value != null ? screenSize.height : 0,
              duration: const Duration(milliseconds: 100),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () => rxPickedMessage.value = null,
                    child: Stack(
                      children: [
                        ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: screenSize.width,
                                height: screenSize.height,
                                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.2),
                              )
                            )
                          )
                      ]
                    )
                  ),
                  if(show&&rxPickedMessage.value != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: MessageFullscreenItem(
                          message: rxPickedMessage.value!,
                          self: rxPickedMessage.value!.creatorId == store.get<int>('id')!,
                        )
                    )
                ]
              )
            )
          ]
        )
      );
    });
  }
}

class MessageFullscreenItem extends StatefulWidget {
  const MessageFullscreenItem({
    super.key,
    required this.message,
    this.self = true
  });
  final Message message;
  final bool self;

  @override
  State<StatefulWidget> createState() => _StateMessageFullscreenItem();
}

class _StateMessageFullscreenItem extends State<MessageFullscreenItem> {
  late final message = widget.message;
  bool show = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 100), (){
      setState(() => show = rxPickedMessage.value != null);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _S = S.of(context);

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
         SizedBox(
           height: MediaQuery.of(context).padding.top
         ),
         Container(
           padding: const EdgeInsets.all(10),
           margin: const EdgeInsets.all(10),
           decoration: BoxDecoration(
             color: theme.scaffoldBackgroundColor,
             borderRadius: BorderRadius.circular(15)
           ),
           child: Column(
             children: [
               GridMessageMedia(media: message.media, second: true),
               Text(
                 message.text,
                 style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: theme.textTheme.bodyMedium!.fontSize!-5
                 )
               )
             ]
           )
         ),
           AnimatedOpacity(
             opacity: show ? 1 : 0,
             duration: const Duration(milliseconds: 200),
             child: Container(
               padding: const EdgeInsets.all(5),
               width: MediaQuery.of(context).size.width*.75,
               decoration: BoxDecoration(
                 color: theme.scaffoldBackgroundColor,
                 borderRadius: BorderRadius.circular(15)
               ),
               child: Column(
                 children: [
                  InkWell(
                       onTap: (){
                        rxPickedReplyMessage.value = message;
                        rxPickedMessage.value = null;
                       },
                       child: Container(
                           padding: const EdgeInsets.symmetric(vertical: 5),
                           child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.reply, color: theme.primaryColor),
                                 Text(
                                   _S.reply,
                                   style: theme.textTheme.bodyMedium!.copyWith(
                                     fontWeight: FontWeight.w600,
                                     color: theme.primaryColor
                                   )
                                 )
                               ]
                           )
                       )
                  ),
                  if(widget.self)
                  ...[
                      InkWell(
                          onTap: () async {
                            final isDeleted = await MessagesHttp.deleteMessage(message.groupId, message.id);
                            if(isDeleted){
                              store.get<Socket>('socket')!.emit('delete-message',{
                                'group_id': message.groupId,
                                'message_id': message.id
                              });
                            }
                            rxPickedMessage.value = null;
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete, color: Colors.red),
                                    Text(
                                        _S.btn_delete,
                                        style: theme.textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red
                                        )
                                    )
                                  ]
                              )
                          )
                      )
                    ]
                 ]
               )
             )
           )
        ]
      )
    );
  }
}