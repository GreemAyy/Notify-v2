import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/http/tasks.http.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import '../../generated/l10n.dart';
import '../../methods/chat.dart';

class MessageItem extends StatefulWidget{
  MessageItem({
    super.key,
    required this.message,
    this.onMessageOpen,
    this.self = true
  });
  Message message;
  bool self;
  void Function(Message message)? onMessageOpen;

  @override
  State<StatefulWidget> createState() => _StateMessageItem();
}

class _StateMessageItem extends State<MessageItem>{
  late final message = widget.message;
  bool isThisMessageOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
        alignment: widget.self ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 5),
          child: InkWell(
            onLongPress: (){

            },
            borderRadius: BorderRadius.only(
                topLeft:const Radius.circular(15),
                topRight:const Radius.circular(15),
                bottomRight:!widget.self?Radius.zero:const Radius.circular(15),
                bottomLeft: widget.self?Radius.zero:const Radius.circular(15)
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: MediaQuery.of(context).size.width*(isThisMessageOpen?1:.8),
                    padding: const EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 50),
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
                ),
                Positioned(
                  bottom: 0,
                  right: widget.self ? 0 : null,
                  left: widget.self ? null : 0,
                  child: IconButton(
                    onPressed: () => rxPickedReplyMessage.value = message,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.primaryColor
                    ),
                    icon: Icon(Icons.reply),
                  ),
                )
              ]
            )
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
  int heroCounter = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageMaxWidth = screenSize.width*.75;

    return Container(
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
              final heroTag = "hero_chat_image_${item.id}_$heroCounter";

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
                    imageWidth: imageMaxWidth/wherePhoto.length,
                    fit: wherePhoto.length<3?BoxFit.fitWidth:BoxFit.fill
                  )
                ),
              );
            }).toList()
          ),
        ],
      )
    );
  }
}

class TaskGridItem extends StatefulWidget{
  TaskGridItem({
    super.key,
    required this.id,

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
    TasksHttp.getSingleTask(widget.id)
    .then((value){
      task = value;
      isLoading = false;
        setState((){});
    });
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
                          fontWeight: FontWeight.w600
                      )
                  )
                )
            )
        ),
      ),
    );
  }
}