import 'dart:io';
import 'package:notify/custom_classes/group.dart';
import 'package:notify/http/groups.http.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/FilePicker.widget.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../http/images.http.dart';
import 'package:socket_io_client/socket_io_client.dart';

void showGroupCreateModal(BuildContext context, void Function(int groupId) onCreate) async {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context){
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              height: MediaQuery.of(context).size.height*0.6,
              child: _Form(onCreate: onCreate)
          ),
        );
      }
  );
}

class _Form extends StatefulWidget{
  const _Form({required this.onCreate});
  final void Function(int id) onCreate;
  @override
  State<StatefulWidget> createState() => _StateForm();
}

class _StateForm extends State<_Form>{
  bool isLoading = false;
  bool imagePicked = false;
  File? imageFile;
  String name = '';
  String? nameErrorText;
  late final _S = S.of(context);

  void create() async {
    if(name.isEmpty){
      setState(() => nameErrorText = _S.group_name_error);
      return;
    }
    setState(() => isLoading = true);
    var id = 0;
    if(imageFile!=null){
      var addImage = await ImagesHttp.sendSingleFile(imageFile!);
      if(addImage['added']) id = addImage['id'];
    }
    var userId = store.get('id');
    var createId = await GroupsHttp.createGroup(Group(id: 0, name: name, creatorId: userId, imageId: id));
    if(createId!=0){
      widget.onCreate(createId);
      store.get<Socket>('socket')!.emit('connect-to-chat', {'group_id':createId});
      Navigator.pop(context);
    }else{
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            _S.error,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color
            )
          ))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(isLoading) {
      return Align(
        heightFactor: 12,
        child: Center(
            child: CircularProgressIndicator(
                color: theme.primaryColor
            )
        )
      );
    }
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                      child: Text(
                          _S.create_group,
                          style: theme.textTheme.bodyLarge
                      )
                  )
              ),
              Text(
                _S.name,
                style: theme.textTheme.bodyLarge
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                  child: FormTextField(
                      errorText: nameErrorText,
                      borderRadius: 7.5,
                      borderWidth: 2,
                      hintText: _S.hint_name,
                      onInput: (text) => name = text
                  )
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                      _S.photo,
                      style: theme.textTheme.bodyLarge
                  )
              ),

              FilePicker(
                  onPick: (path, type) async {
                    File image = File(path[0]);
                    setState(() {
                      imageFile = image;
                      imagePicked = true;
                    });
                  },
                  icon: Icon(
                      Icons.photo,
                      color: theme.primaryColor,
                      size: 40,
                  )
              ),
              if(imagePicked)
                Align(
                  child: ClipOval(
                      child: Image.file(
                        imageFile!,
                        width:  150,
                        height: 150,
                        fit: BoxFit.fill
                      )
                  )
                )
            ]
          )
        ),
        Positioned(
            bottom: 10,
            child: TextButton(
                onPressed: create,
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        theme.primaryColor
                    )
                ),
                child: Text(
                    _S.create,
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    )
                )
            )
        )
      ],
    );
  }
}