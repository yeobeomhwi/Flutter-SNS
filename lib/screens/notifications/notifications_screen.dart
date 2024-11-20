import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notifications/notifications_provider.dart';
import '../../widgets/notifications_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);

    // 로딩 중일 때 화면
    if (notificationsState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 에러가 있을 때 화면
    if (notificationsState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Center(
            child: Text(notificationsState.error!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
      );
    }

    // 알림이 없을 때 화면
    if (notificationsState.notifications!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: const Center(
            child: Text('No notifications available',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: notificationsState.notifications?.length,
        itemBuilder: (context, index) {
          final notification = notificationsState.notifications?[index];

          return NotificationCard(
            type: notification!.type,
            body: notification.body,
            date: notification.date,
            time: notification.time,
            user: notification.user,
            comment: notification.comment,
          );
        },
      ),
    );
  }
}
