import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notify/http/groups.http.dart';
import 'package:notify/store/store.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../generated/l10n.dart';

void showJoinModal(BuildContext context){
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 160,
        padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
        child: _Join()
      ),
    )
  );
}

class _Join extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StateJoin();
}

class _StateJoin extends State<_Join>{
  bool isLoading = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _S = S.of(context);
    final borderTheme = OutlineInputBorder(
        borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2
        ),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10)
        ),
        gapPadding: 0
    );

    if(isLoading){
      return Align(
        child: CircularProgressIndicator(color: theme.primaryColor)
      );
    }
    return Column(
      children: [
        Text(_S.join_to_group, style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    enabledBorder: borderTheme,
                    focusedBorder: borderTheme,
                  ),
                  style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600
                  ),
                  controller: _controller
              )
            ),
            IconButton(
              onPressed: () async {
                final clipboardData = (await Clipboard.getData("text/plain"));
                if(clipboardData?.text!=null){
                  _controller.text = clipboardData?.text??"";
                }
              },
              icon: Icon(Icons.create, size: 30, color: theme.primaryColor)
            )
          ]
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            setState(() => isLoading = true);
            final isJoined = await GroupsHttp.join(store.get('id'), _controller.text);
            if(isJoined) {
              store.get<Socket>('socket')!.emit('connect-to-chat', {'group_id':int.parse(_controller.text.split('-')[0])});
              store.update('groups');
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor
          ),
          child: Text(_S.join, style: theme.textTheme.bodyLarge)
        )
      ]
    );
  }
}