import 'package:notify/http/tasks.http.dart';
import 'package:notify/http/users.http.dart';
import 'package:notify/widgets/group/show_group_settings.dart';
import 'package:notify/widgets/group/show_invite_modal.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import 'package:notify/widgets/ui/Skeleton.ui.dart';
import 'package:flutter/material.dart';
import '../custom_classes/group.dart';
import '../custom_classes/task.dart';
import '../custom_classes/user.dart';
import '../generated/l10n.dart';
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

class _StateGroupScreen extends State<GroupScreen> with TickerProviderStateMixin{
  late final TabController tabController = TabController(length: 2, vsync: this);
  late Group group = widget.group;
  bool showBarPicture = true;

  @override
  void dispose() {
    super.dispose();
    _alreadyLoaded.clear();
    _loadedMembers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final _S = S.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              group.name,
              style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600
              )
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(150),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
              ),
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor.withOpacity(.75),
                child: TabBar.secondary(
                  controller: tabController,
                  tabs: [
                    Tab(text: _S.home_task_header),
                    Tab(text: _S.members)
                  ]
                )
              ),
            )
          ),
          flexibleSpace: FlexibleSpaceBar(
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
      body: SafeArea(
          child: DefaultTabController(
            initialIndex: 0,
            length: 2,
            child: TabBarView(
              controller: tabController,
              children: [
                TasksGrid(groupId: widget.group.id),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: MembersList(groupId: widget.group.id)
                )
              ]
            )
          )
      )
    );
  }
}

typedef ImagesIds = ({int id, Task task});
var _alreadyLoaded = <ImagesIds>[];
var _tasksScreenScrollPosition = 0.0;

class TasksGrid extends StatefulWidget{
  const TasksGrid({
    super.key,
    required this.groupId
  });
  final int groupId;

  @override
  State<StatefulWidget> createState() => _StateTasksGrid();
}

class _StateTasksGrid extends State<TasksGrid>{
  var imagesIds = _alreadyLoaded;
  var isLoading = true;
  final scrollController = ScrollController(initialScrollOffset: _tasksScreenScrollPosition);

  @override
  void initState(){
    super.initState();
    ()async{
      if(_alreadyLoaded.isEmpty){
        await init();
      }else{
        setState((){
          imagesIds = _alreadyLoaded;
          isLoading = false;
        });
      }
      if(scrollController.hasClients){
        scrollController.addListener(_scrollListener);
      }
    }();
  }

  void _scrollListener(){
    _tasksScreenScrollPosition = scrollController.position.pixels;
  }

 @override
 void dispose(){
    super.dispose();
    scrollController.removeListener(_scrollListener);
 }

 Future<void> init() async {
    var id = widget.groupId;
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
    _alreadyLoaded = imagesIds;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: screenSize.width/3
        ),
      controller: scrollController,
      itemCount: isLoading?12:imagesIds.length,
      itemBuilder: (BuildContext context, int index) {
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
      },
    );
  }
}

var _loadedMembers = <User>[];

class MembersList extends StatefulWidget{
  const MembersList({super.key, required this.groupId});
  final int groupId;

  @override
  State<StatefulWidget> createState() => _StateMembersList();
}

class _StateMembersList extends State<MembersList>{
  var membersList = _loadedMembers;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    List<User> members = [];
    members = _loadedMembers.isEmpty ? await UsersHttp.getByGroup(widget.groupId) : _loadedMembers;
    if(_loadedMembers.isEmpty) _loadedMembers = members;
    setState(() {
      membersList = members;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: isLoading ? 9 : membersList.length,
        itemBuilder: (context, index){
          if(isLoading){
            return Skeleton(
              verticalOuterPadding: 5,
              horizontalOuterPadding: 10,
              height: 50,
              borderRadius: 15,
              colorFrom: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.1),
              colorTo: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.3),
            );
          }
          return MemberItem(
              onPress: (){

              },
              member: membersList[index]
          );
        }
    );
  }
}

class MemberItem extends StatelessWidget{
  const MemberItem({
    super.key,
    required this.member,
    required this.onPress,
  });
  final User member;
  final void Function() onPress;
  static const imageSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: InkWell(
          onTap: onPress,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: theme.textTheme.bodyMedium!.color!.withOpacity(.1)
            ),
            child: Row(
              children: [
                if(member.images.isEmpty)
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: theme.textTheme.bodyMedium!.color!.withOpacity(.3),
                      borderRadius: BorderRadius.circular(imageSize)
                    ),
                  )
                else ImagePlaceholder(
                  imageId: member.images.first,
                  imageHeight: imageSize,
                  imageWidth: imageSize
                ),
                const SizedBox(width: 10),
                Text(member.name)
              ]
            )
          )
        )
    );
  }
}