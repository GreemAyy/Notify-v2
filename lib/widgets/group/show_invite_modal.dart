import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notify/http/groups.http.dart';
import '../../generated/l10n.dart';
import '../../store/store.dart';

void showInviteModal(BuildContext context){
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
            height: 110,
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: _Invite()
        );
      }
  );
}

class _Invite extends StatefulWidget{


  @override
  State<StatefulWidget> createState() => _StateInvite();
}

class _StateInvite extends State<_Invite>{
  String code = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final inviteKey = await GroupsHttp.invite(store.get("id"), store.get("group"));
    if(inviteKey != "0"){
      setState(() {
        code = "${store.get("group")}-$inviteKey";
        isLoading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _S = S.of(context);
    final theme = Theme.of(context);
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
        child: CircularProgressIndicator(
            color: theme.primaryColor
        )
      );
    }
    return Column(
        children: [
          Text(
            _S.invite_code,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600
            )
          ),
          const SizedBox(height: 5),
          Row(
              children: [
                Expanded(
                    child: TextFormField(
                        readOnly: true,
                        initialValue: code,
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          enabledBorder: borderTheme,
                          focusedBorder: borderTheme,
                        ),
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600
                        )
                    )
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    await Fluttertoast.showToast(
                      msg: _S.saved_in_clipboard,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: theme.primaryColor.withOpacity(1),
                      timeInSecForIosWeb: 1
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.save, color: theme.primaryColor, size: 30)
                )
              ]
          )
        ]
    );
  }
}