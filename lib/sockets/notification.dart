import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SocketNotification{
  final FlutterLocalNotificationsPlugin _notifyPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    _notifyPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    var initAndroidSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {

      }
    );
    var initSettings = InitializationSettings(
      android: initAndroidSettings,
      iOS: initSettingsIOS
    );
    await _notifyPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) async {
        }
    );
  }

  notifyDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'notify_channel_1',
          'channel_name',
          importance: Importance.high,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher"
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  Future show({int id = 0, String? title, String? body, String? payload}) async {
    return _notifyPlugin.show(id, title, body, await notifyDetails());
  }
}