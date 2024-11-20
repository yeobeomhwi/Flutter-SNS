import 'package:app_team2/screens/home/post_details_screen.dart';
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30))),
      );
    }

    // 알림이 없을 때 화면
    if (notificationsState.notifications!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('알림', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: const Center(
            child: Text('알림이 없습니다.', style: TextStyle(fontSize: 20))),
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

          // 디버깅을 위한 로그 추가
          print('=== Notification Debug ===');
          print('Notification object: $notification');
          print('PostId: ${notification?.postId}');
          print('Type: ${notification?.type}');
          print('========================');

          if (notification == null) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onTap: () {
              if (notification.postId.isNotEmpty) {
                print(
                    'Tapped notification with postId: ${notification.postId}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostDetailsScreen(postId: notification.postId),
                  ),
                );
                _logPostId(notification.postId);
              } else {
                print('PostId is empty!');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('유효하지 않은 게시물입니다.')),
                );
              }
            },
            child: NotificationCard(
              type: notification.type,
              body: notification.body,
              date: notification.date,
              time: notification.time,
              user: notification.user,
              comment: notification.comment,
            ),
          );
        },
      ),
    );
  }

  void _logPostId(String postId) {
    print('선택된 포스트 ID: $postId');
  }
}
