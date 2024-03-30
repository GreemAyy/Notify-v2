import 'dart:io';
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
    required this.openHeight
  });
  final double height;
  final double openHeight;


  @override
  State<StatefulWidget> createState() => _StateBottomMessageBar();
}

class _StateBottomMessageBar extends State<BottomMessageBar>{
  bool isOpen = false;
  final openDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _S = S.of(context);

    return PopScope(
        onPopInvoked: (pop){
          if(isOpen) setState(() => isOpen = false);
        },
        canPop: !isOpen,
        child: AnimatedContainer(
            duration: openDuration,
            height:isOpen ? widget.openHeight : widget.height,
            width: MediaQuery.of(context).size.width,
            padding:const EdgeInsets.only(top: 12.5, left: 5, right: 5),
            decoration: BoxDecoration(
              color: theme.textTheme.bodyMedium!.color!.withOpacity(.05),
              borderRadius: isOpen? const BorderRadius.only(
                  topRight: Radius.circular(35),
                  topLeft: Radius.circular(35)
              ):null
            ),
            child: Column(
                children: [
                  Row(
                      children: [
                        IconButton(
                            onPressed: () => setState(() => isOpen = !isOpen),
                            icon: Icon(isOpen?Icons.close:Icons.attach_file)
                        ),
                        Expanded(
                            child: FormTextField(
                                hintText: _S.write_message,
                                onInput: (text){

                                }
                            )
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
                  SizedBox(height: 10),
                  AnimatedContainer(
                      duration: openDuration,
                      height: isOpen? widget.openHeight-widget.height:0,
                      child: PhotoPicker()
                  )
                ]
            )
        )
    );
  }
}

final rxImageFiles = Reactive(<AssetEntity>[]);

class PhotoPicker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StatePhotoPicker();
}

class _StatePhotoPicker extends State<PhotoPicker>{
  var images = <AssetEntity>[];
  var isLoading = true;
  var pickedImagesId = <String>[];

  @override
  void initState() {
    super.initState();
    init();
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
        children: List.generate(9, (index){
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
            if(pickedImagesId.contains(image.id))
              pickedImagesId = pickedImagesId.where((id) => id != image.id).toList();
            else
              pickedImagesId.add(image.id);
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