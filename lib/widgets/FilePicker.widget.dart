import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraFilePicker extends StatefulWidget{
  CameraFilePicker({
    super.key,
    required this.onPick,
    this.size = 20
  });
  double size;
  void Function(String? filePath) onPick;

  @override
  State<StatefulWidget> createState() => _StateCameraFilePicker();
}

class _StateCameraFilePicker extends State<CameraFilePicker>{
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          var picker = ImagePicker();
          var image = await picker.pickImage(source: ImageSource.camera);
          widget.onPick(image?.path);
        },
        color: Theme.of(context).primaryColor,
        icon: Icon(
            Icons.camera_alt,
            size: widget.size
        )
    );
  }
}

abstract class FileType{
  static const photo = 'photo';
  static const file = 'file';
}

class FilePicker extends StatefulWidget{
  FilePicker({
    super.key,
    required this.icon,
    required this.onPick,
    this.fileType = FileType.photo,
    this.multiple = false
  });
  Icon icon;
  void Function(List<String> filePath, String type) onPick;
  String fileType;
  bool multiple;

  @override
  State<StatefulWidget> createState() => _StateFilePicker();
}

class _StateFilePicker extends State<FilePicker>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () async {
        if(widget.fileType == FileType.photo){
          var picker = ImagePicker();
          if(widget.multiple){
            var images = (await picker.pickMultiImage()).map((e) => e.path).toList();
            widget.onPick(widget.multiple?images:[images[0]], widget.fileType);
          }else{
            var image = await picker.pickImage(source: ImageSource.gallery);
            widget.onPick([image!.path], widget.fileType);
          }
        }
      },
      color: theme.primaryColor,
      icon: widget.icon,
    );
  }
}