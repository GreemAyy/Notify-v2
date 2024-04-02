import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app_settings/const.dart';
import '../../custom_classes/group.dart';
import '../../generated/l10n.dart';
import '../../http/groups.http.dart';
import '../../store/store.dart';
import '../ui/Skeleton.ui.dart';

class MyGroupsList extends StatefulWidget{
  const MyGroupsList({super.key});
  @override
  State<StatefulWidget> createState() => _StateMyGroupsList();
}

class _StateMyGroupsList extends State<MyGroupsList>{
  bool isLoading = true;
  int groupListWatchIndex = -1;
  List<Group> groupsList = store.get('groups');
  late final _S = S.of(context);

  @override
  void initState() {
    super.initState();
    init();
    groupListWatchIndex = store.watch('groups', (_) { // Home.screen
      setState(() => isLoading = true);
      init();
    });
  }

  void init() async {
    var groups = await GroupsHttp.getUsersGroups(store.get('id'));
    store.set('groups', groups, false);
    setState(() {
      groupsList = groups;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    store.unSeeAt('groups', groupListWatchIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if(!isLoading&&groupsList.isEmpty) {
      return SliverToBoxAdapter(
          child: Center(
            child: Text(
                _S.empty,
                style: theme.textTheme.bodyLarge
            )
          )
      );
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            childCount: isLoading?7:groupsList.length,
                (context, index){
              if(isLoading){
                return Skeleton(
                  height: 75,
                  verticalOuterPadding: 5,
                  horizontalOuterPadding: 10,
                  borderRadius: 15,
                  colorFrom: theme.textTheme.bodyMedium!.color!.withOpacity(.1),
                  colorTo: theme.textTheme.bodyMedium!.color!.withOpacity(.3),
                );
              }
              var group = groupsList[index];
              //Color.fromARGB(75, 150, 150, 150)
              return Container(
                  margin:const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: theme.textTheme.bodyMedium!.color!.withOpacity(.1),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: GroupListItem(
                    onTap: () {
                      store.set('group', group.id);
                      Navigator.of(context)
                          .pushNamed('/group-tasks', arguments: {"group":group});
                    },
                    group: group,
                    borderRadius: 15,
                    padding: (vertical: 5, horizontal: 10),
                    heroTag: 'hero_group_image_${group.id}',
                  )
              );
            }
        )
    );
  }
}

class GroupListItem extends StatelessWidget{
  const GroupListItem({
    super.key,
    required this.group,
    required this.onTap,
    this.borderRadius = 0,
    this.padding = (vertical: 0, horizontal: 0),
    this.heroTag,
    this.height,
    this.createLeading = false
  });
  final Group group;
  final void Function() onTap;
  final double borderRadius;
  final ({double vertical, double horizontal}) padding;
  final String? heroTag;
  final double? height;
  final bool createLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: padding.horizontal,vertical: padding.vertical),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius)
        ),
        child: Row(
          children: [
            if(createLeading)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                    onPressed: ()=>Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back)
                ),
              ),
            ClipOval(
              child: (
                group.imageId == 0?
                const Icon(
                  Icons.group,
                  size: 50
                ):
                CachedNetworkImage(
                  imageUrl: '$URL_MAIN/api/images/${group.imageId}',
                  imageBuilder: (context, image){
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: Image(
                          image: image,
                          fit: BoxFit.fill
                      )
                    );
                  },
                  placeholder: (context, _){
                    return Skeleton(
                        height: 50,
                        width: 50,
                        setWidthFromScreenParams: false
                    );
                  },
                  errorWidget: (context, _, err){
                      return const Icon(
                          Icons.group,
                          size: 50
                      );
                    }
                  )
                )
            ),
            const SizedBox(width: 15),
            Text(
              group.name,
              style: theme.textTheme.bodyMedium
            )
          ]
        )
      )
    );
  }
}
