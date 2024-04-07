import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store_flutter_lib.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:notify/widgets/ui/Skeleton.ui.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../generated/l10n.dart';

class BottomMessageBar extends StatefulWidget{
  const BottomMessageBar({
    super.key,
    required this.height,
    required this.openHeight,
    required this.replyHeight,
    this.onReply,
    this.onOpen,
    this.onClose
  });
  final double height;
  final double openHeight;
  final double replyHeight;
  final void Function()? onOpen;
  final void Function()? onClose;
  final void Function()? onReply;

  @override
  State<StatefulWidget> createState() => _StateBottomMessageBar();
}

class _StateBottomMessageBar extends State<BottomMessageBar>{
  bool isOpen = false;
  bool isReplyOpen = false;
  double yStart = 0;
  late double startPos = widget.openHeight;
  late double yPos = widget.openHeight;
  bool isOnDrag = false;
  final openDuration = const Duration(milliseconds: 150);
  FocusNode? _focusNode;
  void Function()? replyWatcher;

  @override
  void initState() {
    super.initState();
    replyWatcher = rxPickedReplyMessage.watch((value){
      setState(() =>isReplyOpen = value != null);
      if(widget.onReply!=null) widget.onReply!();
    });
  }

  @override
  void dispose() {
    super.dispose();
    replyWatcher!();
  }

  void _textFieldListener(){
    if(_focusNode!.hasFocus&&yPos>widget.openHeight){
      yPos = widget.openHeight;
    }
    if(_focusNode!.hasFocus&&yPos==widget.openHeight&&widget.onClose!=null)
      widget.onClose!();
    else if(!_focusNode!.hasFocus&&yPos==widget.openHeight&&isOpen&&widget.onOpen!=null)
      widget.onOpen!();
    else if(!_focusNode!.hasFocus&&!isOpen&&widget.onClose!=null)
      widget.onClose!();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final _S = S.of(context);

    return PopScope(
        onPopInvoked: (pop){
          setState((){
            if(isOpen){
              isOpen = false;
              if(widget.onClose!=null) widget.onClose!();
            }
          });
        },
        canPop: !isOpen,
        child: GestureDetector(
          onVerticalDragStart: (details){
            if(!isOpen) return;
            yStart = details.globalPosition.dy;
            isOnDrag = true;
            startPos = yPos;
            setState(() {});
          },
          onVerticalDragUpdate: (details){
            if(!isOpen) return;
            yPos = startPos-(details.globalPosition.dy-yStart);
            if(yPos<=widget.height) yPos = widget.height;
            if(yPos>=widget.openHeight*1.75) yPos = widget.openHeight*1.75;
            setState(() {});
          },
          onVerticalDragEnd: (details){
            if(!isOpen) return;
            isOnDrag = false;
            if(yPos>=widget.openHeight*1.25){
              yPos=widget.openHeight*1.75;
              _focusNode!.unfocus();
              if(widget.onClose!=null) widget.onClose!();
            }else if(yPos<=widget.openHeight*1.25&&yPos>=widget.openHeight*0.5){
              yPos = widget.openHeight;
              if(widget.onOpen!=null&&isOpen&&!_focusNode!.hasFocus) widget.onOpen!();
            }else{
              yPos = widget.openHeight;
              isOpen = false;
              if(widget.onClose!=null) widget.onClose!();
            }
            setState(() {});
          },
          child: Column(
              children: [
                const TaskMessagePicker(),
                Center(
                    child: AnimatedContainer(
                        duration: isOnDrag ? Duration.zero : openDuration,
                        height: (isOpen ? yPos : widget.height) + (isReplyOpen ? widget.replyHeight : 0),
                        width: MediaQuery.of(context).size.width,
                        // padding:const EdgeInsets.only(top: 7.5),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor
                        ),
                        child: Column(
                            children: [
                              SizedBox(
                                height: widget.height+(isReplyOpen?widget.replyHeight:0),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                        duration: isOnDrag ? Duration.zero : const Duration(milliseconds: 250),
                                        width: !isOpen ? 0 : isOnDrag ? 100 : 75,
                                        height: isOpen ? 5 : 0,
                                        margin: const EdgeInsets.only(bottom: 5, top: 5),
                                        decoration: BoxDecoration(
                                            color: theme.textTheme.bodyMedium!.color,
                                            borderRadius: BorderRadius.circular(15)
                                        )
                                    ),
                                    if(isReplyOpen)
                                      ReplyBlock(height: widget.replyHeight),
                                    Row(
                                        children: [
                                          IconButton(
                                              onPressed: () => setState((){
                                                isOpen = !isOpen;
                                                yPos = widget.openHeight;
                                                if(widget.onClose!=null&&!isOpen) widget.onClose!();
                                                if(widget.onOpen!=null&&isOpen) widget.onOpen!();
                                                if(isOpen&&(_focusNode!.hasFocus&&yPos==widget.openHeight&&widget.onClose!=null))
                                                  widget.onClose!();
                                              }),
                                              icon: Icon(isOpen?Icons.close:Icons.attach_file)
                                          ),
                                          Expanded(
                                              child: FormTextField(
                                                  hintText: _S.write_message,
                                                  onInput: (text){

                                                  },
                                                  getFocusNode: (node) {
                                                    _focusNode = node;
                                                    _focusNode!.addListener(_textFieldListener);
                                                  })
                                          ),
                                          IconButton(
                                              onPressed: (){},
                                              icon: Icon(
                                                  Icons.send,
                                                  color: theme.primaryColor
                                              )
                                          )
                                        ]
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                  duration: isOnDrag ? Duration.zero : openDuration,
                                  height: isOpen ? (yPos - widget.height): 0,
                                  child: const PhotoPicker()
                              )
                            ]
                        )
                    )
                )
              ]
          )
        )
    );
  }
}

class TaskMessagePicker extends StatelessWidget{
  const TaskMessagePicker({super.key});
  final double taskPickerSize = 75;

  @override
  Widget build(BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final theme = Theme.of(context);
        return rxPickedTasksList.toBuilder((context){
          final taskList = rxPickedTasksList.value;

          return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaY: 2,
                            sigmaX: 2
                          ),
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: taskList.isNotEmpty?taskPickerSize:0,
                              width: screenSize.width-20,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: taskList.length,
                                  itemBuilder: (context, index){
                                    return Stack(
                                        children: [
                                          Container(
                                              width: screenSize.width*.6,
                                              margin: const EdgeInsets.symmetric(vertical: 5 ,horizontal: 4),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: theme.primaryColor
                                              ),
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      "${S.of(context).task} №${taskList[index].id}"
                                                  )
                                              )
                                          ),
                                          Positioned(
                                              right: 0,
                                              top: 0,
                                              child: IconButton(
                                                onPressed: (){
                                                  taskList.remove(taskList[index]);
                                                  rxPickedTasksList.value = taskList;
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                                ),
                                                icon: Icon(
                                                  Icons.close,
                                                  size: 30,
                                                  color: theme.primaryColor,
                                                )
                                              ))
                                        ]
                                    );
                                  }
                              )
                          )
                      )
                  )
                )
              ]
          );
        });
  }
}

final rxImageFiles = Reactive(<AssetEntity>[]);

class PhotoPicker extends StatefulWidget{
  const PhotoPicker({super.key});

  @override
  State<StatefulWidget> createState() => _StatePhotoPicker();
}

class _StatePhotoPicker extends State<PhotoPicker>{
  var isLoading = true;
  var images = <AssetEntity>[];
  var pickedImagesId = <String>[];

  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    PhotoManager.setIgnorePermissionCheck(false);
    final req = await PhotoManager.requestPermissionExtend();
    if(req.isAuth){
      if(rxImageFiles.value.isNotEmpty){
        images = rxImageFiles.value;
        isLoading = false;
        setState(() {});
        return;
      }
      final albums = await PhotoManager.getAssetPathList(hasAll: true);
      for(var album in albums){
        final asset = await album.getAssetListRange(start: 0, end: await album.assetCountAsync);
        images.addAll(asset);
      }
      isLoading = false;
      rxImageFiles.value = images;
      setState(() {});
    }else if(req.hasAccess){
      print('has');
    }
    else{
      print('else');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if(isLoading){
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(15, (index){
          return Skeleton(
            height: 150,
            verticalOuterPadding: 2.5,
            horizontalOuterPadding: 2.5,
            borderRadius: 10,
            colorFrom: theme.textTheme.bodyMedium!.color!.withOpacity(.1),
            colorTo: theme.textTheme.bodyMedium!.color!.withOpacity(.3),
          );
        })
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      children: images.map((image){
        return InkWell(
          splashColor: Colors.transparent,
          onLongPress: (){
            pickedImagesId.add(image.id);
            setState(() {});
          },
          onTap: (){
            if(pickedImagesId.isEmpty) return;
            if(pickedImagesId.contains(image.id)){
              pickedImagesId = pickedImagesId.where((id) => id != image.id).toList();
            } else if(pickedImagesId.length<3) {
              pickedImagesId.add(image.id);
            }else{
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                      '${S.of(context).max} 3',
                      style:theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                      )
                    ),
                    backgroundColor: Colors.red,
                  )
              );
            }
            setState((){});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: pickedImagesId.contains(image.id)?Border.all(
                color: theme.primaryColor,
                width: 5
              ):null
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: AssetEntityImageProvider(image),
                fit: BoxFit.fill,
              )
            )
          )
        );
      }).toList()
    );
  }
}

class ReplyBlock extends StatelessWidget{
  const ReplyBlock({
    super.key,
    this.height
  });
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return rxPickedReplyMessage.toBuilder((context) {
      return InkWell(
        onTap: (){
          rxPickedReplyMessage.value = null;
        },
        child: Container(
            margin: rxPickedReplyMessage.value == null ? EdgeInsets.zero : height!=null?const EdgeInsets.only(bottom: 10):null,
            height: rxPickedReplyMessage.value == null ? 0 : height!=null ? height! - 10 : null,
            decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(.3),
                border: Border(
                    left: BorderSide(
                        color: theme.primaryColor,
                        width: 3
                    )
                )
            ),
            child: Row(
                children: [
                  Expanded(child: Text(rxPickedReplyMessage.value?.text??''))
                ]
            )
        ),
      );
    });
  }
}