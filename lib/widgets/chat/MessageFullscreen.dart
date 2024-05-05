import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:notify/store/collector.dart';
import 'package:notify/widgets/chat/MessageItem.widget.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../custom_classes/message.dart';
import '../../generated/l10n.dart';
import '../../http/messages.http.dart';

class MessageFullscreen extends StatefulWidget {
  const MessageFullscreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateMessageFullscreen();
}

class _StateMessageFullscreen extends State<MessageFullscreen> {
  late Deleter deleter;
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
    return rxPickedMessage.toBuilder((context, reactive) {
      final screenSize = MediaQuery.of(context).size;

      if(reactive.value != null) {
        Timer(const Duration(milliseconds: 100), (){
          setState(() => show = rxPickedMessage.value != null);
        });
      }

      return PopScope(
        canPop: canPop,
        onPopInvoked: (_){
          setState(() {
            reactive.value = null;
            canPop = true;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              width: screenSize.width,
              height: reactive.value != null ? screenSize.height : 0,
              duration: const Duration(milliseconds: 100),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () => reactive.value = null,
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
                  if(show&&reactive.value != null)
                    MessageFullscreenItem(
                      message: reactive.value!,
                      self: reactive.value!.creatorId == store.get<int>('id')!,
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
  bool showOnlySave = false;
  double bottomPadding = 100;
  String text = rxPickedMessage.value?.text ?? '';

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
         AnimatedContainer(
           duration: const Duration(milliseconds: 500),
           height: bottomPadding
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
               if(widget.self)
                 ...[
                   const SizedBox(height: 10),
                   FormTextField(
                       onInput: (text) => this.text = text,
                       getFocusNode: (node){
                         node.addListener(() {
                           setState(() {
                             bottomPadding = node.hasFocus ? MediaQuery.of(context).size.height/3 : 100;
                             showOnlySave = node.hasFocus;
                           });
                         });
                       },
                       borderRadius: 7.5,
                       initValue: message.text,
                       textStyle: theme.textTheme.bodyMedium!.copyWith(
                           fontSize: theme.textTheme.bodyMedium!.fontSize!-5
                       )
                   )
                 ]
               else
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
                  if(!showOnlySave)
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
                    InkWell(
                        onTap: () async {
                          final message = rxPickedMessage.value!;
                          message.text = text;
                          await MessagesHttp.updateMessage(message);
                          store.get<Socket>('socket')!.emit('update-message', message);
                          rxPickedMessage.value = null;
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save),
                                  Text(
                                      _S.save,
                                      style: theme.textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      )
                                  )
                                ]
                            )
                        )
                    ),
                  if(widget.self&&!showOnlySave)
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