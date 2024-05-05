import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:http/http.dart' as http;
import '../custom_classes/user.dart';

class UsersHttp{
 static Future<User?> getSingle(int id) async {
   final url = Uri.parse('$URL_MAIN/api/users/$id');
   final req = await http.get(url);
   final decoded = jsonDecode(req.body);
   try{
     final body = decoded != null ? User.fromJson(Map<String, dynamic>.from(decoded)) : null;
     return body;
   }catch(_){
     return null;
   }
 }
 static Future<List<User>> getByGroup(int groupId) async {
   final url = Uri.parse('$URL_MAIN/api/users/by-group/$groupId');
   final req = await http.get(url);
   final decoded = jsonDecode(req.body) as List<dynamic>;
   final body = decoded.map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList();
   return body;
 }
 static Future<bool> updateUser(int id, String name) async {
   var url = Uri.parse('$URL_MAIN/api/users/update');
   var objToSend = {'id':id, "name":name};
   var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":'application/json'});
   var body = Map<String, dynamic>.from(jsonDecode(req.body));
   return body['updated'] ?? false;
 }
 static Future<bool> authUser(String email, String password) async {
   var url = Uri.parse('$URL_MAIN/api/users/auth');
   var objToSend = {'email':email, 'password':password};
   var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":'application/json'});
   var body = Map<String, dynamic>.from(jsonDecode(req.body));
   return body['auth'] ?? false;
 }

 static Future<Map<String, dynamic>> logUser(String email, String password, String code) async {
   var url = Uri.parse('$URL_MAIN/api/users/log');
   var objToSend = {'email':email, 'password':password, 'code':code};
   var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":'application/json'});
   var body = Map<String, dynamic>.from(jsonDecode(req.body));
   return body;
 }

 static Future<bool> checkUserAccess(int id, String hash) async {
   var url = Uri.parse('$URL_MAIN/api/users/check');
   var objToSend = {"id":id,"hash":hash};
   var req = await http.post(url, body: jsonEncode(objToSend), headers: {"Content-Type":'application/json'});
   var body = Map<String, dynamic>.from(jsonDecode(req.body));
   if(req.statusCode<200||req.statusCode>=400){
     return await checkUserAccess(id, hash);
   }
   return body['access'] as bool? ?? false;
 }


}