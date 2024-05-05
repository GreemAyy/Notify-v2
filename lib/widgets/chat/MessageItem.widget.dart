import 'package:flutter/material.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/http/tasks.http.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/chat/MessagesList.widget.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import '../../custom_classes/user.dart';
import '../../generated/l10n.dart';
import '../../http/messages.http.dart';
import '../../methods/chat.dart';
import '../../store/collector.dart';

const _messageWidthMultiply = .7;

class MessageItem extends StatefulWidget{
  const MessageItem({
    super.key,
    required this.message,
    this.onMessageOpen,
    this.self = true,
    this.fullscreen = false
  });
  final Message message;
  final bool self;
  final bool fullscreen;
  final void Function(Message message)? onMessageOpen;

  @override
  State<StatefulWidget> createState() => _StateMessageItem();
}

class _StateMessageItem extends State<MessageItem>{
  late final message = widget.message;
  bool isOnDrag = false;
  double xStart = 0;
  double xPos = 0;
  final int duration = 100;

  @override
  void initState() {
    super.initState();
  }

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
                onLongPress: !widget.fullscreen ? () {
                  FocusScope.of(context).unfocus();
                  rxPickedMessage.value = message;
                } : null,
                child: (
                  widget.self ?
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 100),
                    alignment: isOnDrag ? Alignment.centerLeft : Alignment.centerRight,
                    child: MessageBody(message: message, self: widget.self)
                  ) :
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: widget.self&&!isOnDrag ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Container(
                            width: 25,
                            height: 25,
                            margin: const EdgeInsets.only(left: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: theme.textTheme.bodyMedium!.color
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                message.creatorId.toString(),
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontSize: theme.textTheme.bodyMedium!.fontSize!-5,
                                  color: theme.scaffoldBackgroundColor
                                )
                              )
                            )
                        ),
                        MessageBody(message: message, self: widget.self)
                      ]
                  )
                )
            )
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            right: !isOnDrag ? -50 : xPos,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(.5),
                borderRadius: BorderRadius.circular(50)
              ),
              child: Icon(
                Icons.reply,
                color: theme.primaryColor,
                size: 40
              )
            )
          )
        ]
      )
    );
  }
}

class MessageBody extends StatelessWidget{
  const MessageBody({
    super.key,
    required this.message,
    required this.self
  });
  final Message message;
  final bool self;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return
      Padding(
        padding: const EdgeInsets.only(left: 5, top: 10, right: 10, bottom: 5),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: MediaQuery.of(context).size.width*_messageWidthMultiply,
            padding: const EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 5),
            decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium!.color!.withOpacity(.05),
                borderRadius: BorderRadius.only(
                    topLeft:const Radius.circular(15),
                    topRight:const Radius.circular(15),
                    bottomRight:self ? Radius.zero : const Radius.circular(15),
                    bottomLeft: !self ? Radius.zero : const Radius.circular(15)
                )
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(!self)
                    UserMessageItem(
                      groupId: message.groupId,
                      userId: message.creatorId,
                    ),
                  if(message.replyTo!=0)
                    ...
                    [
                      ReplyMessageItem(id: message.replyTo),
                      const SizedBox(height: 5)
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
    );
  }
}


class GridMessageMedia extends StatelessWidget{
  GridMessageMedia({
    super.key,
    required this.media,
    this.second = false
  });
  final List<MessageMedia> media;
  final bool second;
  int heroCounter = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageMaxWidth = screenSize.width*(_messageWidthMultiply-.05);

    return SizedBox(
      width: screenSize.width*_messageWidthMultiply,
      child: Column(
        children: [
          Column(
            children: media.where((e) => e.type.value == MessageMediaDataType.task.value)
                .map((item) => TaskGridItem(id: item.id)).toList()
          ),
          Row(
            mainAxisAlignment: media.length > 1 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: media.where((e) => e.type.value == MessageMediaDataType.photo.value).map((item){
              heroCounter++;
              final wherePhoto = media.where((e) => e.type.value == MessageMediaDataType.photo.value).toList();
              final heroTag = "hero_chat_image_${item.id}_${heroCounter}_${second?1:0}";

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () =>
                  Navigator.pushNamed(context, '/image' ,arguments: {
                    'hero': heroTag,
                    'image':ImagePlaceholder(
                        imageId: item.id,
                        imageHeight: screenSize.height,
                        imageWidth: screenSize.width,
                        fit: BoxFit.contain
                      )
                  }),
                child: Hero(
                  tag: heroTag,
                  child: ImagePlaceholder(
                    imageId: item.id,
                    imageHeight: 150,
                    imageWidth: imageMaxWidth / wherePhoto.length,
                    fit: BoxFit.cover
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

final Map<int, ({bool isLoaded, Task? task})> _loadedTasks = {};

class TaskGridItem extends StatefulWidget{
  const TaskGridItem({
    super.key,
    required this.id
  });
  final int id;

  @override
  State<StatefulWidget> createState() => _StateTaskGridItem();
}

class _StateTaskGridItem extends State<TaskGridItem>{
  bool isLoading = true;
  final deleteCallbacks = <void Function()>[];
  Task? task;

  @override
  void initState() {
    super.initState();
    deleteCallbacks.addAll([
      store.watchWithDeleteCallback<Task>('delete_task', (deleteTask) {
        if(deleteTask.id==(task!=null?task!.id:0)){
          setState(() => task = null);
        }
      }),
      store.watchWithDeleteCallback<Task?>('update_tasks_list', (updatedTask) {
        setState(() => task = updatedTask);
        _loadedTasks[widget.id] = (isLoaded: true, task: updatedTask);
      })
    ]);

    if(_loadedTasks[widget.id]==null){
      TasksHttp.getSingleTask(widget.id).then((value){
        task = value;
        _loadedTasks[widget.id] = (isLoaded: true, task: value);
        isLoading = false;
        setState((){});
      });
    }else{
      setState((){
        task = _loadedTasks[widget.id]!.task;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    deleteCallbacks.forEach((cb) => cb());
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
        onTap: (){
          if(task != null) Navigator.pushNamed(context, '/task', arguments: {"task": task!});
        },
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
                      task==null?
                      _S.task_deleted:
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

final Map<int, (Message?,)> _loadedReplyMessages = {};

class ReplyMessageItem extends StatefulWidget{
  const ReplyMessageItem({
    super.key,
    required this.id
  });
  final int id;

  @override
  State<StatefulWidget> createState() => _StateReplyMessageItem();
}

class _StateReplyMessageItem extends State<ReplyMessageItem>{
  bool isLoading = true;
  Message? message;
  var deleters = <Deleter>[];

  @override
  initState(){
    super.initState();
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
        _loadedReplyMessages[widget.id] = (value,);
      });
    }else{
      setState(() {
        message = _loadedReplyMessages[widget.id]!.$1;
        isLoading = false;
      });
    }
    deleters = [
      messageUpdater.watchWithDeleteCallback<Message>('update-reply', (data) {
        if(data.id == widget.id) {
          try{
            setState(() => message = data);
          }catch(_){}
          _loadedReplyMessages[widget.id] = (data,);
        }
      }),
      messageUpdater.watchWithDeleteCallback<int>('update-reply-delete', (id) {
        setState((){
          if(widget.id == id) message = null;
        });
        _loadedReplyMessages[id] = (null,);
      })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    deleters.forEach((cb) => cb());
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(message!=null) messageUpdater.updateWithData('scroll_to_message', widget.id);
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
          isLoading ?
          S.of(context).loading:
          message==null ?
          S.of(context).message_deleted :
          message?.text.isEmpty ?? true ?
          S.of(context).empty_message :
          message!.text,
          overflow: TextOverflow.ellipsis
        )
      )
    );
  }
}

class UserMessageItem extends StatefulWidget{
  const UserMessageItem({
    super.key,
    required this.userId,
    required this.groupId
  });
  final int userId;
  final int groupId;

  @override
  State<StatefulWidget> createState() => _StateUserMessageItem();
}

class _StateUserMessageItem extends State<UserMessageItem>{
  User? user;

  @override
  void initState() {
    super.initState();
    var users = rxGroupUsers.value[widget.groupId];
    if(users==null){
      rxGroupUsers.watch((data) {
        users = rxGroupUsers.value[widget.groupId];
        setState(() => user = users?.where((e) => e.id == widget.userId).first);
      });
    }else{
      setState(() => user = users?.where((e) => e.id == widget.userId).first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0, bottom: 5),
      child: Text(
        user?.name??S.of(context).nobody,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize!-5
        )
      )
    );
  }
}

