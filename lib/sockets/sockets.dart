import 'dart:async';
import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/group.dart';
import 'package:notify/sockets/notification.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../custom_classes/task.dart';
import '../http/groups.http.dart';
import '../store/store.dart';

void connectSocket(){
  IO.Socket socket = IO.io(
      URL_MAIN,
      IO.OptionBuilder()
      .setTransports(['websocket'])
      .setPath('/socket.io')
      .enableReconnection()
      .build()
  );

  socket.connect().connect().connect();

  store.set('socket', socket);

  socket.onDisconnect((data){
    Timer? timer;
    timer = Timer(const Duration(seconds: 10), (){
      socket.connect();
      timer!.cancel();
    });
  });
  socket.onConnect((data) async {
    List<Group> groups;
    if(store.get('groups') == null) {
      groups = await GroupsHttp.getUsersGroups(store.get<int>('id')!);
    } else {
      groups = store.get<List<Group>>('groups')!;
    }
    for(var group in groups) {
      socket.emit('connect-to-chat', {'group_id':group.id});
    }
  });
}

abstract class SocketCommand{
  static const update = 'update';
  static const delete = 'delete';
  static const change = 'change';
}

void updateSocket(Task task, String command){
  DateTime dateFrom = DateTime(task.yearFrom,task.monthFrom, task.dayFrom);
  DateTime dateTo = DateTime(task.yearTo,task.monthTo, task.dayTo);
  var socket = store.get<IO.Socket>('socket')!;
  socket.emit(command, jsonEncode({
    "creator_id": store.get<int>('id')!,
    "task_id": task.id,
    "group_id":task.groupId,
    "date_from":DateFormat('dd-MM-yyyy').format(dateFrom),
    "date_to":DateFormat('dd-MM-yyyy').format(dateTo)
  }));
}

void startSocketUpdateWatcher() {
  var notification = SocketNotification()..initNotification();

  store.watch<IO.Socket>('socket', (socket) {
    socket.on('update', (strData) async {
      var canUpdate = _update(strData);
      if(canUpdate){
        notification.show(
            title: "New task!",
            body: "New task created"
        );
      }
    });
    socket.on('change', (strData) async {
      var canUpdate = _update(strData);
      if(canUpdate){
        notification.show(
            title: "Status changed!",
            body: "Task status changed"
        );
      }
    });
    socket.on('delete', (strData) async {
      var canUpdate = _update(strData);
      if(canUpdate){
        notification.show(
            title: "Task deleted!",
            body: "Task was deleted"
        );
      }
    });
  });
}

bool _update(String strData){
  var data = jsonDecode(strData);
  if(data['creator_id'] == store.get<int>('id')!) return false;
  int groupId = data['group_id'];
  int group = store.get<int>('group')!;
  List<int> groupsIds = (store.get<List<Group>>('groups')!).map((e) => e.id).toList();
  if(groupsIds.contains(groupId)){
    if(group==0) return true;
    List<int> splitFrom = (data['date_from'] as String).split('-').map((e) => int.parse(e)).toList();
    List<int> splitTo = (data['date_to'] as String).split('-').map((e) => int.parse(e)).toList();
    DateTime from = DateTime(splitFrom[2],splitFrom[1],splitFrom[0]);
    DateTime to = DateTime(splitTo[2],splitTo[1],splitTo[0]);
    DateTime now = store.get<DateTime>('date')!;
    if((from.isBefore(now)||from.isAtSameMomentAs(now))&&
        (to.isAfter(now)||to.isAtSameMomentAs(now))&&group==groupId){
      store.update('update_tasks_list');
      return true;
    }
  }
  return false;
}