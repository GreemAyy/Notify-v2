import 'package:notify/custom_classes/task.dart';
import 'package:notify/sockets/sockets.dart';
import 'package:notify/widgets/task/LoadingPlaceholder.widget.dart';
import 'package:notify/widgets/task/TaskItem.widget.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../http/tasks.http.dart';
import '../../store/store.dart';

class SecondTasksList extends StatefulWidget{
  SecondTasksList({
    super.key,
    required this.display,
    this.tasks = const <Task>[],
    this.initLoad = true,
    this.isSliver = false
  });
  bool display;
  List<Task> tasks;
  bool initLoad;
  bool isSliver;

  @override
  State<StatefulWidget> createState() => _StateSecondTasksList();
}

class _StateSecondTasksList extends State<SecondTasksList>{
  late final _S = S.of(context);
  late var tasksList = widget.tasks;
  late bool isLoading = widget.initLoad;
  int dateWatchIndex = 0;
  int createTaskWatchIndex = 0;
  int deleteTaskWatchIndex = 0;
  int changeStatusWatchIndex = 0;
  int updateListWatchIndex = 0;

  @override
  void initState() {
    super.initState();
    if(widget.initLoad){
      loadTasks(store.get('date'));
      dateWatchIndex = store.watch<DateTime>('date', (date){
        loadTasks(date);
      });
    }else{
      store.watch<List<Task>>('search_tasks', (tasks) {
        setState(() => tasksList = tasks);
      });
    }
    updateListWatchIndex = store.watch('update_tasks_list', (_) {
      loadTasks(store.get<DateTime>('date')!);
    });
    deleteTaskWatchIndex = store.watch<Task>('delete_task', (task) async {
      var isDeleted = await TasksHttp.deleteTask(task.id);
      if(isDeleted){
        setState(() {
          tasksList = tasksList.where((e) => e.id != task.id).toList();
        });
        updateSocket(task, SocketCommand.delete);
      }
    });
    changeStatusWatchIndex = store.watch<({int status, Task task})>('change_task_status', (data) async {
      var task = data.task;
      var isChanged = await TasksHttp.changeTaskStatus(data.task.id, data.status);
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
    var group = store.get<int>('group')!;
    setState(() => isLoading = true);
    if(group==0){
      var tasks = await TasksHttp.getLocalUsersTasks(store.get('id'), date);
      setState(() {
        tasksList = tasks;
        isLoading = false;
      });
    }else{
      var tasks = await TasksHttp.getGroupTasks(group, date);
      setState(() {
        tasksList = tasks;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(widget.initLoad) store.unSeeAt('date', dateWatchIndex);
    else store.unSee('search_tasks');
    store.unSeeAt('delete_task', deleteTaskWatchIndex);
    store.unSeeAt('change_task_status', changeStatusWatchIndex);
    store.unSeeAt('update_tasks_list', updateListWatchIndex);
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
      return ListView.builder(
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            var task = tasksList[index];
            return TaskItem(
              key: Key(task.id.toString()),
              task: task
            );
          }
      );
    }
  }
}