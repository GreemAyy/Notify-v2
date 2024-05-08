import 'package:flutter/material.dart';

void showGroupLinkModal(BuildContext context, int groupId){
  showModalBottomSheet(
      context: context,
      builder: (context) => _GroupLink(groupId: groupId)
  );
}

class _GroupLink extends StatefulWidget{
  _GroupLink({
    required this.groupId
  });
  int groupId;

  @override
  State<StatefulWidget> createState() => _StateGroupLink();
}

class _StateGroupLink extends State<_GroupLink>{
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [

        ]
    );
  }
}