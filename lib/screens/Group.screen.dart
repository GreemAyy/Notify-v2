import 'package:notify/http/tasks.http.dart';
import 'package:notify/widgets/group/show_group_settings.dart';
import 'package:notify/widgets/group/show_invite_modal.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import 'package:notify/widgets/ui/Skeleton.ui.dart';
import 'package:flutter/material.dart';
import '../custom_classes/group.dart';
import '../custom_classes/task.dart';
import '../store/store.dart';

class GroupScreen extends StatefulWidget{
  const GroupScreen({
    super.key,
    required this.group
  });
  final Group group;

  @override
  State<StatefulWidget> createState() => _StateGroupScreen();
}

class _StateGroupScreen extends State<GroupScreen>{
  late Group group = widget.group;
  var imagesIds = <({int id, Task task})>[];
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var id = store.get<int>('group')!;
    var getTasks = await TasksHttp.getGroupsAllTasks(id);
    var holder = <({int id, Task task})>[];
    for (var task in getTasks) {
      if(task.imagesId[0]!=0){
        holder.addAll(
          task.imagesId.map((e){
            return (id: e, task: task);
          })
        );
      }
    }
    setState(() {
      imagesIds = holder;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 275,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  group.name,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600
                  )
                ),
                background: Hero(
                    tag: 'hero_group_image_${group.id}',
                    child: Opacity(
                      opacity: .75,
                      child: (
                        group.imageId!=0?
                        ImagePlaceholder(
                            imageId: group.imageId,
                            imageWidth: screenSize.width,
                            imageHeight: 250,
                            fit: BoxFit.fitWidth,
                            radius: 0
                        ):
                        Container(
                          width: screenSize.width,
                          height: 250,
                          color: theme.scaffoldBackgroundColor
                        )
                      )
                    )
                )
              ),
              actions: [
                if(group.creatorId==store.get('id')!)
                  IconButton(
                      onPressed: () => showGroupSettings(context, group),
                      icon: Icon(
                        Icons.settings,
                        color: theme.textTheme.bodyMedium!.color,
                      )
                  ),
                IconButton(
                    onPressed: () => showInviteModal(context),
                    icon: Icon(
                      Icons.share,
                      color: theme.textTheme.bodyMedium!.color
                    )
                )
              ]
            ),
            SliverGrid(
                delegate: SliverChildBuilderDelegate(
                    childCount: isLoading?12:imagesIds.length,
                        (context, index){
                      if(isLoading){
                        return Skeleton(
                            height: screenSize.width/3-5,
                            width: screenSize.width/3-5,
                            verticalOuterPadding: 2.5,
                            horizontalOuterPadding: 2.5,
                            colorFrom: theme.textTheme.bodyMedium!.color!.withOpacity(.1),
                            colorTo: theme.textTheme.bodyMedium!.color!.withOpacity(.3),
                            borderRadius: 10
                        );
                      }
                      var imageId = imagesIds[index];
                      return InkWell(
                        onTap: (){
                          Navigator.pushNamed(context, '/image-with-task', arguments: {
                                "hero":'hero_image_screen_$imageId',
                                "image": ImagePlaceholder(
                                  imageId: imageId.id,
                                  imageHeight: screenSize.height,
                                  imageWidth: screenSize.width,
                                  fit: BoxFit.contain,
                                  radius: 0,
                                ),
                                "task":imageId.task
                              });
                        },
                        child: Hero(
                            tag: 'hero_image_screen_$imageId',
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ImagePlaceholder(
                                imageId: imageId.id,
                                imageHeight: screenSize.width/3-10,
                                imageWidth: screenSize.width/3-10,
                                radius: 5,
                              )
                            )
                        )
                      );
                    }
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenSize.width/3
                )
            )
          ]
        )
      )
    );
  }
}