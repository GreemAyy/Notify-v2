import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:http/http.dart' as http;

typedef GetMessagesBeforeIdOutput = ({List<Message> messages, bool haveMore});

class MessagesHttp {
   static Future<int> createMessage(Message message) async {
    final url = Uri.parse('$URL_MAIN/api/messages/create');
    final req = await http.post(url, body: jsonEncode(message.toJson()), headers: {"Content-Type": "application/json"});
    final body = Map<String, int>.from(jsonDecode(req.body));
    return body['id'] as int;
  }

  static Future<List<Message>> getMessagesAfterId(int groupId, int messageId) async {
    final url = Uri.parse('$URL_MAIN/api/messages/get-after-id');
    final req = await http.post(url, body: jsonEncode({
      "group_id": groupId,
      "message_id": messageId
    }), headers: {"Content-Type": "application/json"});
    final body = Map<String, dynamic>.from(jsonDecode(req.body));
    return (body['messages'] as List).map((e) => Message.fromJson(e)).toList();
  }

   static Future<GetMessagesBeforeIdOutput> getMessagesBeforeId(int groupId, int messageId) async {
     final url = Uri.parse('$URL_MAIN/api/messages/get-before-id');
     final req = await http.post(url, body: jsonEncode({
       "group_id": groupId,
       "message_id": messageId
     }), headers: {"Content-Type": "application/json"});
     final body = Map<String, dynamic>.from(jsonDecode(req.body));
     return (
      messages:(body['messages'] as List).map((e) => Message.fromJson(e)).toList(),
      haveMore: body['have_more'] as bool
     );
   }
}