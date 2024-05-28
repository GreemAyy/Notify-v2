import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:http/http.dart' as http;
import '../store/store.dart';

abstract class TasksHttp{
  static Future<Map<String, dynamic>> createTask(Task task) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/create');
    final objToSend = {
      'task':task.toJson(),
      'user_id':task.creatorId,
      'hash':store.get('hash')!
    };
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    final body = Map<String, dynamic>.from(jsonDecode(req.body));
    return body;
  }

  static Future<TaskAccess?> getTaskAccess(int taskId) async {
    final url = Uri.parse("${Constants.URL_MAIN}/api/tasks/get-task-access/$taskId");
    final req = await http.get(url);
    return TaskAccess.fromJson(jsonDecode(req.body)?['access']);
  }

  static Future<bool> createTaskAccess(TaskAccess taskAccess) async {
    final url = Uri.parse("${Constants.URL_MAIN}/api/tasks/create-task-access");
    final req = await http.post(url, body: jsonEncode(taskAccess.toJson()), headers: {"Content-Type":"application/json"});
    return jsonDecode(req.body)?['created'] ?? false;
  }
  
  static Future<List<Task>> getLocalUsersTasks(int userId, DateTime date) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/get-users-local-tasks');
    final objToSend = {
      'user_id': userId,
      'date': [date.day, date.month, date.year]
    };
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    final body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    if(req.statusCode<200||req.statusCode>=400){
      return await getLocalUsersTasks(userId, date);
    }
    return body;
  }

  static Future<Task?> getSingleTask(int id) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/single/$id');
    final req = await http.get(url);
    if(jsonDecode(req.body)['task']==null) return null;
    final body = Task.fromJson(jsonDecode(req.body)['task']);
    return body;
  }
  
  static Future<List<Task>> getGroupTasks(int groupId, DateTime date) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/get-group-tasks');
    final objToSend = {
      'group_id':groupId,
      'date':[date.day, date.month, date.year]
    };
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    final body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    if(req.statusCode<200||req.statusCode>=400){
      return await getGroupTasks(groupId, date);
    }
    return body;
  }
  
  static Future<List<Task>> getGroupsAllTasks(int id) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/get-group-all/$id');
    final req = await http.get(url);
    final body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    if(req.statusCode<200||req.statusCode>=400){
      return await getGroupsAllTasks(id);
    }
    return body;
  }
  
  static Future<bool> changeTaskStatus(int taskId, int status) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/change-status');
    final objToSend = {
      "id":taskId,
      "status":status
    };
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {'Content-Type':'application/json'});
    if(req.statusCode<200||req.statusCode>=400){
      return false;
    }
    final body = jsonDecode(req.body) as Map<String, dynamic>;
    return (body['changed'] as bool?)??false;
  }
  
  static Future<bool> deleteTask(int id) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/delete');
    final req = await http.post(url, body: jsonEncode({"id":id}), headers: {'Content-Type':'application/json'});
    if(req.statusCode<200||req.statusCode>=400){
      return false;
    }
    final body = jsonDecode(req.body) as Map<String, dynamic>;
    return (body['deleted'] as bool?)??false;
  }

  static Future<bool> updateTask(Task task) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/update');
    final req = await http.post(url, body: jsonEncode(task.toJson()), headers: {'Content-Type':'application/json'});
    if(req.statusCode<200||req.statusCode>=400){
      return false;
    }
    final body = jsonDecode(req.body) as Map<String, dynamic>;
    return (body['updated'] as bool?)??false;
  }
  
  static Future<List<Task>> searchTasks(String text, int id, int groupId) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/search');
    final objToSend = {
      'text':text,
      'id':id,
      'groupId':groupId
    };
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    final body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    return body;
  }

  static Future<bool> deleteImages(int id, List<int> images) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/tasks/delete-images');
    final objToSend = {"id":id, "images":images};
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    if(req.statusCode<200||req.statusCode>=400) return false;
    return jsonDecode(req.body)['deleted'] as bool;
  }
}
