import 'package:notify/http/groups.http.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/chat/MessagesList.widget.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../custom_classes/message.dart';
import '../screens/Chat.screen.dart';

void startChatSockets() {
  store.watch<Socket>('socket', (socket) async {
    socket.on('message', (data) {
      final message = Message.fromJson(data);
      final groupMessages = rxGroupMessages.value;
      groupMessages[message.groupId] = [message,...(groupMessages[message.groupId]!)];
      rxGroupMessages.value = groupMessages;
      messageUpdater.updateWithData('new', groupMessages[message.groupId]);
    });
    socket.on('delete-message', (data){
      int id = (data)['message_id'];
      int groupId = (data)['group_id'];
      final groupMessages = rxGroupMessages.value;
      groupMessages[groupId]?.removeWhere((e) => e.id == id);
      groupMessages[groupId]?.map((e){
        if(e.replyTo == id){
          e.replyTo = -1;
        }
        return e;
      });
      rxGroupMessages.value = groupMessages;
      messageUpdater.updateWithData('delete', {
        'message_id': id,
        'group_id': groupId
      });
    });
  });
}