import 'package:notify/custom_classes/message.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/sockets/sockets.dart';
import 'package:notify/widgets/task/LoadingPlaceholder.widget.dart';
import 'package:notify/widgets/task/TaskItem.widget.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../http/tasks.http.dart';
import '../../store/store.dart';

class TasksList extends StatefulWidget{
  const TasksList({
    super.key,
    required this.display,
    this.tasks = const <Task>[],
    this.initLoad = true,
    this.isSliver = false
  });
  final bool display;
  final List<Task> tasks;
  final bool initLoad;
  final bool isSliver;

  @override
  State<StatefulWidget> createState() => _StateTasksList();
}

class _StateTasksList extends State<TasksList>{
  late final _S = S.of(context);
  late var tasksList = widget.tasks;
  late bool isLoading = widget.initLoad;
  final Map<String, int> watchersIndexes = {};

  @override
  void initState() {
    super.initState();
    if(widget.initLoad){
      loadTasks(store.get('date'));
      watchersIndexes['date'] = store.watch<DateTime>('date', (date){
        loadTasks(date);
      });
    }else{
      store.watch<List<Task>>('search_tasks', (tasks) {
        setState(() => tasksList = tasks);
      });
    }
    watchersIndexes['update_tasks_list'] = store.watch<Task?>('update_tasks_list', (task) {
      if(task is Task){
        if(tasksList.where((e) => e.id==task.id).isNotEmpty){
          tasksList = tasksList.map((i) => i.id==task.id ? task : i).toList();
        }else{
          tasksList.add(task);
        }
        setState(() {});
      }else{
        loadTasks(store.get<DateTime>('date')!);
      }
    });
    watchersIndexes['delete_task'] = store.watch<Task>('delete_task', (task) async {
      final isDeleted = await TasksHttp.deleteTask(task.id);
      if(isDeleted){
        setState(() {
          tasksList = tasksList.where((e) => e.id != task.id).toList();
        });
        updateSocket(task, SocketCommand.delete);
        final groupMessages = rxGroupMessages.value;
        groupMessages[task.groupId] = (groupMessages[task.groupId]??[]).map((e){
          e.media = e.media.where((media) => media.type == MessageMediaDataType.task&&media.id==task.id).toList();
          return e;
        }).toList();
        rxGroupMessages.value = groupMessages;
      }
    });
    watchersIndexes['change_task_status'] = store.watch<({int status, Task task})>('change_task_status', (data) async {
      final task = data.task;
      final isChanged = await TasksHttp.changeTaskStatus(data.task.id, data.status);
      if(isChanged){
        setState(() {
          tasksList = tasksList.map((i){
            if(i.id==task.id){
              i.status = data.status;
            }
            return i;
          }).toList();
        });
        updateSocket(task, SocketCommand.update);
      }else{
        setState(() => isLoading = false);
      }
    });
  }

  void loadTasks(DateTime date) async {
    final group = store.get<int>('group')!;
    setState(() => isLoading = true);
    if(group==0){
      final tasks = await TasksHttp.getLocalUsersTasks(store.get('id'), date);
      setState(() {
        tasksList = tasks;
        isLoading = false;
      });
    }else{
      final tasks = await TasksHttp.getGroupTasks(group, date);
      setState(() {
        tasksList = tasks;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(!widget.initLoad) store.unSee('search_tasks');
    watchersIndexes.forEach((key, index) => store.unSeeAt(key, index));
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading||!widget.display) {
      if(widget.isSliver){
        return SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: LoadingPlaceholder()
          )
        );
      }
      return LoadingPlaceholder();
    }
    if(tasksList.isEmpty){
      var emptyChild = Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(
              _S.empty,
              style: Theme.of(context).textTheme.bodyLarge
          )
      );
      if(widget.isSliver){
        return SliverToBoxAdapter(
          child: emptyChild
        );
      }
      return emptyChild;
    }
    if(widget.isSliver){
      return SliverList(
          delegate: SliverChildBuilderDelegate(
              childCount: tasksList.length,
              (context, index) {
                var task = tasksList[index];
                return TaskItem(
                  key: Key(task.id.toString()),
                  task: task
                );
              }
          )
      );
    }else{
      return RefreshIndicator(
        onRefresh: () async {
          loadTasks(DateTime.now());
        },
        child: ListView.builder(
            itemCount: tasksList.length,
            itemBuilder: (context, index) {
              var task = tasksList[index];
              return TaskItem(
                key: Key(task.id.toString()),
                task: task
              );
            }
        )
      );
    }
  }
}