import 'package:flutter/material.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:notify/widgets/chat/BottomMessageBar.widget.dart';
import 'package:notify/widgets/chat/MessagesList.widget.dart';

import '../custom_classes/group.dart';
import '../widgets/group/MyGroupsList.widget.dart';

class ChatScreen extends StatelessWidget{
  ChatScreen({
    super.key,
    required this.group
  });
  Group group;
  bool isLoading = false;
  final double bottomBarHeight = 75.0;
  final double topBarHeight = 75.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: Stack(
            children: [
              Positioned(
                  height: topBarHeight,
                  width: screenSize.width,
                  child: GroupListItem(
                      onTap: (){
                        Navigator.of(context)
                            .pushNamed('/group',arguments: {"group":group});
                      },
                      group: group,
                      padding: (horizontal: 15, vertical: 5),
                      heroTag: 'hero_group_image_${group.id}'
                  )
              ),
              if(isLoading)
                Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                        color: theme.primaryColor
                    )
                )
              else
                Positioned(
                  height: screenSize.height-topBarHeight-bottomBarHeight,
                  width: screenSize.width,
                  bottom: bottomBarHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MessagesList(messagesList: mockMessages)
                  )
                ),
              Positioned(
                bottom: 0,
                child: BottomMessageBar(
                    height: bottomBarHeight,
                    openHeight: 350
                )
              )
            ]
          ),
        )
      )
    );
  }
}
