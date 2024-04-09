import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:http/http.dart' as http;

class MessagesHttp {
   static Future<int> createMessage(Message message) async {
    final url = Uri.parse('$URL_MAIN/api/messages/create');
    final req = await http.post(url, body: jsonEncode(message.toJson()), headers: {"Content-Type": "application/json"});
    final body = Map<String, int>.from(jsonDecode(req.body));
    return body['id'] as int;
  }
}