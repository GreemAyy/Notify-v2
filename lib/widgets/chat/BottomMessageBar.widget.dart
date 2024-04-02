import 'package:flutter/material.dart';
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
    this.onOpen,
    this.onClose
  });
  final double height;
  final double openHeight;
  final void Function()? onOpen;
  final void Function()? onClose;

  @override
  State<StatefulWidget> createState() => _StateBottomMessageBar();
}

class _StateBottomMessageBar extends State<BottomMessageBar>{
  bool isOpen = false;
  double yStart = 0;
  late double startPos = widget.openHeight;
  late double yPos = widget.openHeight;
  bool isOnDrag = false;
  final openDuration = const Duration(milliseconds: 150);
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
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
          child: AnimatedContainer(
              duration: isOnDrag?Duration.zero:openDuration,
              height:isOpen ? yPos : widget.height,
              width: MediaQuery.of(context).size.width,
              padding:const EdgeInsets.only(top: 12.5, left: 5, right: 5),
              decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: isOpen? const BorderRadius.only(
                      topRight: Radius.circular(35),
                      topLeft: Radius.circular(35)
                  ) : null
              ),
              child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: !isOpen ? 0 : isOnDrag ? 100 : 75,
                      height: isOpen ? 5 : 0,
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: theme.textTheme.bodyMedium!.color,
                        borderRadius: BorderRadius.circular(15)
                      )
                    ),
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
                    const SizedBox(height: 10),
                    AnimatedContainer(
                        duration: isOnDrag ? Duration.zero : openDuration,
                        height: isOpen ? yPos - widget.height : 0,
                        child: const PhotoPicker()
                    )
                  ]
              )
          ),
        )
    );
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
            } else {
              pickedImagesId.add(image.id);
            }
            setState((){});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              border: pickedImagesId.contains(image.id)?Border.all(
                color: theme.primaryColor,
                width: 3
              ):null
            ),
            child: Image(
              image: AssetEntityImageProvider(image),
              fit: BoxFit.fill,
            )
          )
        );
      }).toList(),
    );
  }
}