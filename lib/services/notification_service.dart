import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  await Permission.notification.request();
}

Future<void> initializeLocalNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings darwinInitializationSettings =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: darwinInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'test_channel123',
    'Message Notifications',
    description: 'This channel is used for message notifications',
    importance: Importance.max,
  );

  final AndroidFlutterLocalNotificationsPlugin?
      androidFlutterLocalNotificationsPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidFlutterLocalNotificationsPlugin != null) {
    await androidFlutterLocalNotificationsPlugin
        .createNotificationChannel(channel);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    }
  });
}

// 특정 알림 메시지 삭제 함수
Future<void> deleteNotification(String messageId) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    final userDoc = FirebaseFirestore.instance
        .collection('notifications')
        .doc(currentUser.uid);

    // 현재 메시지 목록 가져오기
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      throw Exception('알림 데이터가 존재하지 않습니다.');
    }

    final data = docSnapshot.data();
    if (data == null) {
      throw Exception('알림 데이터가 비어있습니다.');
    }

    List<dynamic> messages = List.from(data['messages'] ?? []);

    // messageId와 일치하는 메시지 찾아서 삭제
    messages.removeWhere((message) => message['messageId'] == messageId);

    // 업데이트된 메시지 목록 저장
    await userDoc.update({'messages': messages});
  } catch (e) {
    print('알림 메시지 삭제 중 오류 발생: $e');
    rethrow;
  }
}
