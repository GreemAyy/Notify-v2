import 'package:flutter/material.dart';
import 'package:notify/custom_classes/user.dart';
import 'package:notify/http/users.http.dart';
import 'package:notify/screens/Group.screen.dart';
import 'package:notify/store/store.dart';

import '../../generated/l10n.dart';

typedef OnPickUsers = void Function(List<User> pickedUsers);

void showGroupUsersAlertDialog(BuildContext context, int groupId, OnPickUsers onPick, [List<User> alreadyPicked = const []]) {
  List<User> pickedUsers = [];

  showDialog<void>(
      context: context,
      builder: (context) {
        final _S = S.of(context);

        return AlertDialog(
            title: Text(_S.pick_users),
            content: _UsersList(
                onPick: (p) => pickedUsers = p,
                groupId: groupId,
                alreadyPicked: alreadyPicked),
            actions: [
              TextButton(
                  onPressed: () {
                    onPick(pickedUsers);
                    Navigator.pop(context);
                  },
                  child: Text(_S.pick)),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_S.close))
            ]);
      });
}

class _UsersList extends StatefulWidget {
  const _UsersList(
      {required this.groupId,
      required this.onPick,
      this.alreadyPicked = const []});

  final int groupId;
  final OnPickUsers onPick;
  final List<User> alreadyPicked;

  @override
  State<StatefulWidget> createState() => _StateUsersList();
}

class _StateUsersList extends State<_UsersList> {
  bool isLoading = true;
  List<User> usersList = [];
  List<User> pickedUsers = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final users = await UsersHttp.getByGroup(widget.groupId);
    final userId = store.get<int>('id');
    pickedUsers = widget.alreadyPicked;
    usersList = users.where((u) => u.id != userId).toList();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerHeight = screenSize.height * .2;
    final theme = Theme.of(context);

    if (isLoading) {
      return SizedBox(
          height: containerHeight,
          child: Align(
              child: CircularProgressIndicator(color: theme.primaryColor)));
    }
    return SizedBox(
        height: containerHeight,
        child: ListView.builder(
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              return MemberItem(
                  onPress: () {
                    final pick = usersList[index];
                    final includes = pickedUsers.where((u) => u.id != pick.id).length != pickedUsers.length;
                    if (includes) {
                      pickedUsers =
                          pickedUsers.where((u) => u.id != pick.id).toList();
                    } else {
                      pickedUsers.add(usersList[index]);
                    }
                    setState(() {});
                    widget.onPick(pickedUsers);
                  },
                  member: usersList[index],
                  isPicked: pickedUsers
                          .where((u) => u.id != usersList[index].id)
                          .length !=
                      pickedUsers.length);
            }));
  }
}
