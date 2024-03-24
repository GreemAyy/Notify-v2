import 'dart:convert';
import 'package:notify/custom_classes/group.dart';
import 'package:http/http.dart' as http;
import '../app_settings/const.dart';

abstract class GroupsHttp{
  static Future<int> createGroup(Group group) async{
    var url = Uri.parse('$URL_MAIN/api/groups/create');
    var req = await http.post(url, body: jsonEncode(group.toJson()), headers: {"Content-Type":'application/json'});
    var body = Map<String, dynamic>.from(jsonDecode(req.body));
    return ((body["created"] as bool?)??false)==true?body['id']:0;
  }

  static Future<List<Group>> getUsersGroups(int id) async {
    var url = Uri.parse('$URL_MAIN/api/groups/users/$id');
    var req = await http.get(url);
    var body = List<dynamic>.from(jsonDecode(req.body));
    if(req.statusCode<200||req.statusCode>=400){
      return await getUsersGroups(id);
    }
    return body.map((group) => Group.fromJson(group)).toList();
  }

  static Future<bool> updateGroup(({int id, String name,int imageId}) data) async{
    final url = Uri.parse('$URL_MAIN/api/groups/update');
    final objToSend = {
      "id":data.id,
      "name":data.name,
      "image_id":data.imageId
    };
    var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":'application/json'});
    var body = Map<String, dynamic>.from(jsonDecode(req.body));
    return (body['updated'] as bool?) ?? false;
  }
}