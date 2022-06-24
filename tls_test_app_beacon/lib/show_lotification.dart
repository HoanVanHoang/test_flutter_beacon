
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class ShowNotificationUtils {
  NotificationDetails? notificationDetails;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (
          int? id,
          String? title,
          String? body,
          String? payload,
          ) async {
      },
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {

        }
// selectNotificationSubject.add(payload);
      },
    );

    const AndroidNotificationDetails androidNotificationChannel =
    AndroidNotificationDetails(
      'Tls',
      'Tls',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );
    const IOSNotificationDetails iosNotificationDetails =
    IOSNotificationDetails(
        presentBadge: true, presentSound: true, presentAlert: true);
     notificationDetails = NotificationDetails(
        android: androidNotificationChannel, iOS: iosNotificationDetails);
  }

  void showNotifiCationBeacon(Beacon beacon){
    flutterLocalNotificationsPlugin.show(1, "Found a beacon", beacon.toJson.toString(), notificationDetails);
  }
}
