import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/http/tasks.http.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import '../../generated/l10n.dart';
import '../../http/messages.http.dart';
import '../../methods/chat.dart';

class MessageItem extends StatefulWidget{
  MessageItem({
    super.key,
    required this.message,
    this.onMessageOpen,
    this.self = true,
    this.fullscreen = false
  });
  Message message;
  bool self;
  bool fullscreen;
  void Function(Message message)? onMessageOpen;

  @override
  State<StatefulWidget> createState() => _StateMessageItem();
}

class _StateMessageItem extends State<MessageItem>{
  late final message = widget.message;
  bool isThisMessageOpen = false;
  bool isOnDrag = false;
  double xStart = 0;
  double xPos = 0;
  final int duration = 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onHorizontalDragStart: widget.fullscreen ? null : (details){
        setState(() {
          isOnDrag = true;
          xStart = details.globalPosition.dx;
        });
      },
      onHorizontalDragUpdate: widget.fullscreen ? null : (details){
        setState(() {
          final calc = (details.globalPosition.dx-xStart);
          if(calc>0) isOnDrag = false;
          if(calc<0&&calc.abs()<25) xPos = calc.abs();
        });
      },
      onHorizontalDragEnd: widget.fullscreen ? null : (details){
        setState(() {
          if(isOnDrag) rxPickedReplyMessage.value = message;
          isOnDrag = false;
        });
      },
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: isOnDrag ? Duration.zero : const Duration(milliseconds: 100),
            child: InkWell(
                onLongPress: widget.fullscreen ? null : (){
                  FocusScope.of(context).unfocus();
                  rxPickedMessage.value = message;
                },
                child: AnimatedAlign(
                    alignment: widget.self ? Alignment.centerLeft : (isOnDrag ? Alignment.centerLeft : Alignment.centerRight),
                    duration: const Duration(milliseconds: 100),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5, top: 10, right: 10, bottom: 5),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: MediaQuery.of(context).size.width*(isThisMessageOpen?1:.8),
                            padding: const EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 5),
                            decoration: BoxDecoration(
                                color: theme.textTheme.bodyMedium!.color!.withOpacity(.05),
                                borderRadius: BorderRadius.only(
                                    topLeft:const Radius.circular(15),
                                    topRight:const Radius.circular(15),
                                    bottomRight:!widget.self?Radius.zero:const Radius.circular(15),
                                    bottomLeft: widget.self?Radius.zero:const Radius.circular(15)
                                ),
                                border: isThisMessageOpen?Border.all(color: theme.primaryColor, width: 2):null
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(message.replyTo!=0)
                                    ...[
                                      ReplyMessageItem(id: message.replyTo),
                                      const SizedBox(height: 5),
                                    ],
                                  if(message.media.isNotEmpty)
                                    GridMessageMedia(media:message.media),
                                  Text(
                                      message.text,
                                      style: theme.textTheme.bodyMedium!.copyWith(
                                          fontSize: theme.textTheme.bodyMedium!.fontSize!-5
                                      )
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          convertDateToMessageFormat(convertDateFromFormatString(message.createAt)),
                                          style: theme.textTheme.bodyMedium!.copyWith(
                                              fontSize: theme.textTheme.bodyMedium!.fontSize!-7,
                                              fontWeight: FontWeight.w300
                                          )
                                      )
                                  )
                                ]
                            )
                        )


                    )
                )
            )
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            right: !isOnDrag ? -50 : xPos,
            child: Icon(
              Icons.reply,
              color: theme.primaryColor,
              size: 30
            )
          )
        ]
      )
    );
  }
}

class GridMessageMedia extends StatelessWidget{
  GridMessageMedia({
    super.key,
    required this.media,
    this.second = false
  });
  List<MessageMedia> media;
  bool second;
  int heroCounter = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageMaxWidth = screenSize.width*.75;

    return SizedBox(
      width: screenSize.width*.8,
      child: Column(
        children: [
          Column(
            children: media.where((e) => e.type.value == MessageMediaDataType.task.value).map((item){
              return TaskGridItem(id: item.id);
            }).toList()
          ),
          Row(
            mainAxisAlignment: media.length>1?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
            children: media.where((e) => e.type.value == MessageMediaDataType.photo.value).map((item){
              final wherePhoto = media.where((e) => e.type.value == MessageMediaDataType.photo.value).toList();
              heroCounter++;
              final heroTag = "hero_chat_image_${item.id}_${heroCounter}_${second?1:0}";

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: (){
                  Navigator.pushNamed(context, '/image' ,arguments: {
                    'hero': heroTag,
                    'image':ImagePlaceholder(
                        imageId: item.id,
                        imageHeight: screenSize.height,
                        imageWidth: screenSize.width,
                        fit: BoxFit.contain,
                      )
                  });
                },
                child: Hero(
                  tag: heroTag,
                  child: ImagePlaceholder(
                    imageId: item.id,
                    imageHeight: 150,
                    imageWidth: imageMaxWidth / wherePhoto.length,
                    fit: wherePhoto.length<3 ? BoxFit.fitWidth : BoxFit.fill
                  )
                )
              );
            }).toList()
          )
        ]
      )
    );
  }
}

final Map<int, Task> _loadedTasks = {};

class TaskGridItem extends StatefulWidget{
  TaskGridItem({
    super.key,
    required this.id
  });
  int id;

  @override
  State<StatefulWidget> createState() => _StateTaskGridItem();
}

class _StateTaskGridItem extends State<TaskGridItem>{
  bool isLoading = true;
  Task? task;

  @override
  void initState() {
    super.initState();
    if(_loadedTasks[widget.id]==null){
      TasksHttp.getSingleTask(widget.id)
          .then((value){
        task = value;
        _loadedTasks[widget.id] = value;
        isLoading = false;
        setState((){});
      });
    }else{
      setState((){
        task = _loadedTasks[widget.id];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageMaxWidth = screenSize.width*.75;
    final theme = Theme.of(context);
    final _S = S.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/task', arguments: {"task":task!}),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: imageMaxWidth,
            height: isLoading ? 50 : 35,
            padding: isLoading ? const EdgeInsets.symmetric(vertical: 5) : null,
            decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Align(
                alignment: Alignment.center,
                child: (
                  isLoading?
                  const CircularProgressIndicator(color: Colors.white):
                  Text(
                      '${_S.task} №${widget.id}',
                      style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                      )
                  )
                )
            )
        )
      )
    );
  }
}

final Map<int, Message?> _loadedReplyMessages = {};

class ReplyMessageItem extends StatefulWidget{
  ReplyMessageItem({
    super.key,
    required this.id
  });
  int id;

  @override
  State<StatefulWidget> createState() => _StateReplyMessageItem();
}

class _StateReplyMessageItem extends State<ReplyMessageItem>{
  bool isLoading = true;
  Message? message;

  initState(){
    if(widget.id == -1){
      setState(() => isLoading = false);
    }
    else if(_loadedReplyMessages[widget.id]==null){
      MessagesHttp.getSingle(widget.id)
      .then((value){
        setState(() {
          message = value;
          isLoading = false;
        });
        _loadedReplyMessages[widget.id] = value;
      });
    }else{
      setState(() {
        message = _loadedReplyMessages[widget.id];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        store.updateWithData('scroll_to_message', widget.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 3
            )
          ),
          color: Theme.of(context).primaryColor.withOpacity(.3)
        ),
        child: Text(
          isLoading ? S.of(context).loading: message==null ? S.of(context).message_deleted : message!.text,
          overflow: TextOverflow.ellipsis
        )
      ),
    );
  }
}