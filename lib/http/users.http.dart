import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:http/http.dart' as http;

class UsersHttp{
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