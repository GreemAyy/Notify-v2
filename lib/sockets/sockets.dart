import 'dart:async';
import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/group.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/sockets/notification.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../custom_classes/message.dart';
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
  socket.connect();
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
  var socket = store.get<IO.Socket>('socket')!;
  socket.emit(command, task.toJson());
}

void startSocketUpdateWatcher() {
  var notification = SocketNotification()..initNotification();

  store.watch<IO.Socket>('socket', (socket) {
    socket.on('update', (data) async {
      var canUpdate = _update(data, SocketCommand.update);
      if(canUpdate){
        notification.show(
            title: "New task!",
            body: "New task created"
        );
      }
    });
    socket.on('change', (data) async {
      var canUpdate = _update(data, SocketCommand.change);
      if(canUpdate){
        notification.show(
            title: "Status changed!",
            body: "Task status changed"
        );
      }
    });
    socket.on('delete', (data) async {
      var canUpdate = _update(data, SocketCommand.delete);
      if(canUpdate){
        notification.show(
            title: "Task deleted!",
            body: "Task was deleted"
        );
      }
    });
  });
}

bool _update(Map<String, dynamic> data, String command){
  final task = Task.fromJson(data);
  if(task.creatorId == store.get<int>('id')!) return false;
  final groupId = task.groupId;
  final group = store.get<int>('group')!;
  List<int> groupsIds = (store.get<List<Group>>('groups')!).map((e) => e.id).toList();
  if(groupsIds.contains(groupId)){
    if(group==0) return true;
    DateTime from = DateTime(task.yearFrom, task.monthFrom, task.dayFrom);
    DateTime to = DateTime(task.yearTo, task.monthTo, task.dayTo);
    DateTime now = store.get<DateTime>('date')!;
    if(command != SocketCommand.delete){
      if((from.isBefore(now)||from.isAtSameMomentAs(now))&&
          (to.isAfter(now)||to.isAtSameMomentAs(now))&&group==groupId){
        store.updateWithData('update_tasks_list', Task.fromJson(data));
        return true;
      }
    }else{
      store.updateWithData('delete_task', task);
      return true;
    }
  }
  return false;
}