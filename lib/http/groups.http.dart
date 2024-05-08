import 'dart:convert';
import 'package:notify/custom_classes/group.dart';
import 'package:http/http.dart' as http;
import '../app_settings/const.dart';

abstract class GroupsHttp{
  static Future<int> createGroup(Group group) async{
    final url = Uri.parse('${Constants.URL_MAIN}/api/groups/create');
    final req = await http.post(url, body: jsonEncode(group.toJson()), headers: {"Content-Type":'application/json'});
    final body = Map<String, dynamic>.from(jsonDecode(req.body));
    return ((body["created"] as bool?)??false)==true?body['id']:0;
  }
  static Future<List<Group>> getUsersGroups(int id) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/groups/users/$id');
    final req = await http.get(url);
    final body = List<dynamic>.from(jsonDecode(req.body));
    if(req.statusCode<200||req.statusCode>=400){
      return await getUsersGroups(id);
    }
    return body.map((group) => Group.fromJson(group)).toList();
  }
  static Future<bool> updateGroup(({int id, String name,int imageId}) data) async{
    final url = Uri.parse('${Constants.URL_MAIN}/api/groups/update');
    final objToSend = {
      "id":data.id,
      "name":data.name,
      "image_id":data.imageId
    };
    final req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":'application/json'});
    final body = Map<String, dynamic>.from(jsonDecode(req.body));
    return (body['updated'] as bool?) ?? false;
  }
  static Future<String> invite(int userId, int groupId) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/groups/invite');
    final objectToSend = {
      "user_id":userId,
      "group_id":groupId
    };
    final req = await http.post(url, body:jsonEncode(objectToSend), headers: {"Content-Type":'application/json'});
    final body = Map<String, String>.from(jsonDecode(req.body));
    return body["code"]!;
  }
  static Future<bool> join(int userId, String code) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/groups/join');
    final objectToSend = {
      "user_id":userId,
      "code":code
    };
    final req = await http.post(url, body:jsonEncode(objectToSend), headers: {"Content-Type":'application/json'});
    final body = Map<String, bool>.from(jsonDecode(req.body));
    return body["join"]??false;
  }
}