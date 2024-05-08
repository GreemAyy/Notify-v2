import 'dart:convert';
import 'package:notify/app_settings/const.dart';
import 'package:notify/custom_classes/message.dart';
import 'package:http/http.dart' as http;

typedef GetMessagesBeforeIdOutput = ({List<Message> messages, bool haveMore});

class MessagesHttp {
   static Future<int> createMessage(Message message) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/messages/create');
    final req = await http.post(url, body: jsonEncode(message.toJson()), headers: {"Content-Type": "application/json"});
    final body = Map<String, int>.from(jsonDecode(req.body));
    return body['id'] as int;
  }

   static Future<bool> updateMessage(Message message) async {
     final url = Uri.parse('${Constants.URL_MAIN}/api/messages/update');
     final req = await http.post(url, body: jsonEncode(message.toJson()), headers: {"Content-Type": "application/json"});
     final body = Map<String, bool>.from(jsonDecode(req.body));
     return body['updated'] as bool;
   }

  static Future<List<Message>> getMessagesAfterId(int groupId, int messageId) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/messages/get-after-id');
    final req = await http.post(url, body: jsonEncode({
      "group_id": groupId,
      "message_id": messageId
    }), headers: {"Content-Type": "application/json"});
    final body = Map<String, dynamic>.from(jsonDecode(req.body));
    return (body['messages'] as List).map((e) => Message.fromJson(e)).toList();
  }

   static Future<List<Message>> getMessagesUntil(int groupId, int from, int to) async {
     final url = Uri.parse('${Constants.URL_MAIN}/api/messages/get-until');
     final req = await http.post(url, body: jsonEncode({
       "group_id": groupId,
       "from_message_id": from,
       "until_message_id": to
     }), headers: {"Content-Type": "application/json"});
     final body = Map<String, dynamic>.from(jsonDecode(req.body));
     return (body['messages'] as List).map((e) => Message.fromJson(e)).toList();
   }

   static Future<GetMessagesBeforeIdOutput> getMessagesBeforeId(int groupId, int messageId) async {
     final url = Uri.parse('${Constants.URL_MAIN}/api/messages/get-before-id');
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

   static Future<bool> deleteMessage(int groupId, int messageId) async {
     final url = Uri.parse('${Constants.URL_MAIN}/api/messages/delete');
     final req = await http.post(url, body: jsonEncode({
       "group_id": groupId,
       "message_id": messageId
     }), headers: {"Content-Type": "application/json"});
     final body = Map<String, dynamic>.from(jsonDecode(req.body));
     return (body['deleted'] as bool?) ?? false;
   }

  static Future<Message?> getSingle(int id) async {
    final url = Uri.parse('${Constants.URL_MAIN}/api/messages/single/$id');
    final req = await http.get(url);
    final body = Map<String, dynamic>.from(jsonDecode(req.body));
    return body['message'] == null ? null : Message.fromJson(body['message']);
  }
}