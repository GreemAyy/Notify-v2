import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:http/http.dart' as http;
import '../store/store.dart';

abstract class TasksHttp{
  static Future<Map<String, dynamic>> createTask(Task task) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/create');
    var objToSend = {
      'task':task.toJson(),
      'user_id':task.creatorId,
      'hash':store.get('hash')!
    };
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    var body = Map<String, dynamic>.from(jsonDecode(req.body));
    return body;
  }
  
  static Future<List<Task>> getLocalUsersTasks(int userId, DateTime date) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/get-users-local-tasks');
    var objToSend = {
      'user_id':userId,
      'date':[date.day, date.month, date.year]
    };
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    var body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    if(req.statusCode<200||req.statusCode>=400){
      return await getLocalUsersTasks(userId, date);
    }
    return body;
  }

  static Future<Task?> getSingleTask(int id) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/single/$id');
    var req = await http.get(url);
    if(jsonDecode(req.body)['task']==null) return null;
    var body = Task.fromJson(jsonDecode(req.body)['task']);
    return body;
  }
  
  static Future<List<Task>> getGroupTasks(int groupId, DateTime date) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/get-group-tasks');
    var objToSend = {
      'group_id':groupId,
      'date':[date.day, date.month, date.year]
    };
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    var body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    if(req.statusCode<200||req.statusCode>=400){
      return await getGroupTasks(groupId, date);
    }
    return body;
  }
  
  static Future<List<Task>> getGroupsAllTasks(int id) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/get-group-all/$id');
    var req = await http.get(url);
    var body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    if(req.statusCode<200||req.statusCode>=400){
      return await getGroupsAllTasks(id);
    }
    return body;
  }
  
  static Future<bool> changeTaskStatus(int taskId, int status) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/change-status');
    var objToSend = {
      "id":taskId,
      "status":status
    };
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {'Content-Type':'application/json'});
    if(req.statusCode<200||req.statusCode>=400){
      return false;
    }
    var body = jsonDecode(req.body) as Map<String, dynamic>;
    return (body['changed'] as bool?)??false;
  }
  
  static Future<bool> deleteTask(int id) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/delete');
    var req = await http.post(url, body: jsonEncode({"id":id}), headers: {'Content-Type':'application/json'});
    if(req.statusCode<200||req.statusCode>=400){
      return false;
    }
    var body = jsonDecode(req.body) as Map<String, dynamic>;
    return (body['deleted'] as bool?)??false;
  }

  static Future<bool> updateTask(Task task) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/update');
    var req = await http.post(url, body: jsonEncode(task.toJson()), headers: {'Content-Type':'application/json'});
    if(req.statusCode<200||req.statusCode>=400){
      return false;
    }
    var body = jsonDecode(req.body) as Map<String, dynamic>;
    return (body['updated'] as bool?)??false;
  }
  
  static Future<List<Task>> searchTasks(String text, int id, int groupId) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/search');
    var objToSend = {
      'text':text,
      'id':id,
      'groupId':groupId
    };
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    var body = List<dynamic>
        .from(jsonDecode(req.body)).map((e) => Task.fromJson(e))
        .toList();
    return body;
  }

  static Future<bool> deleteImages(int id, List<int> images) async {
    var url = Uri.parse('$URL_MAIN/api/tasks/delete-images');
    var objToSend = {"id":id, "images":images};
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":"application/json"});
    if(req.statusCode<200||req.statusCode>=400) return false;
    return jsonDecode(req.body)['deleted'] as bool;
  }
}
