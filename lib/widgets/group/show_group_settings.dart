import 'dart:io';
import 'package:notify/http/groups.http.dart';
import 'package:notify/http/images.http.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/FilePicker.widget.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:notify/widgets/ui/Optional.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import 'package:flutter/material.dart';
import '../../custom_classes/group.dart';
import '../../generated/l10n.dart';

void showGroupSettings(BuildContext context, Group group){
  showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GroupSettings(group:group),
      )
  );
}

class GroupSettings extends StatefulWidget{
  const GroupSettings({
    super.key,
    required this.group
  });
  final Group group;

  @override
  State<StatefulWidget> createState() => _StateGroupSettings();
}

class _StateGroupSettings extends State<GroupSettings>{
  late final _S = S.of(context);
  late final group = widget.group;
  late String name = widget.group.name;
  bool isLoading = false;
  File? file;

  void updateGroup() async {
    setState(() => isLoading = true);
    var imageId = -1;
    if(file!=null){
      var createFile = await ImagesHttp.sendSingleFile(file!);
      if(createFile['added'] as bool) imageId = createFile['id'];
    }
    await GroupsHttp.updateGroup((id: group.id, name:name, imageId:imageId!=-1?imageId:group.imageId));
    setState(() => isLoading = false);
    store.update('groups');
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Optional(
        conditional: isLoading,
        complited: SizedBox(
          height: screenSize.height/2,
          child: Center(
              child: CircularProgressIndicator(
                  color: theme.primaryColor
              )
          )
        ),
        uncomplited: SingleChildScrollView(
            child: Stack(
                children: [
                  SizedBox(
                      width: screenSize.width,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                    child: Text(
                                        _S.edit,
                                        style: theme.textTheme.bodyLarge
                                    )
                                ),
                                Text(_S.task_title),
                                FormTextField(
                                    onInput: (text) => name = text,
                                    borderRadius: 10,
                                    borderWidth: 2,
                                    initValue: group.name
                                ),
                                Text(_S.photo),
                                FilePicker(
                                    onPick: (paths, _){
                                      file = File(paths[0]);
                                      setState((){});
                                    },
                                    icon: const Icon(
                                        Icons.photo,
                                        size: 40
                                    )
                                ),
                                Align(
                                    child: ClipOval(
                                        child: (
                                            file!=null?
                                            Image.file(
                                                file!,
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.fill
                                            ):
                                            Optional(
                                                conditional: group.imageId!=0,
                                                complited: ImagePlaceholder(
                                                    imageId: group.imageId,
                                                    imageHeight: 150,
                                                    imageWidth: 150,
                                                    fit: BoxFit.fill
                                                ),
                                                uncomplited: const SizedBox(
                                                    height: 150,
                                                    width: 150
                                                )
                                            )
                                        )
                                    )
                                ),
                                const SizedBox(height: 75)
                              ]
                          )
                      )
                  ),
                  Positioned(
                      bottom: 10,
                      width: screenSize.width*.6,
                      left: screenSize.width*.2,
                      child: ElevatedButton(
                          onPressed: updateGroup,
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(theme.primaryColor),
                              padding: const MaterialStatePropertyAll(EdgeInsets.zero)
                          ),
                          child: Text(
                              _S.save,
                              style: theme.textTheme.bodyLarge!.copyWith(
                                  color: Colors.white
                              )
                          )
                      )
                  )
                ]
            )
        )
    );
  }
}