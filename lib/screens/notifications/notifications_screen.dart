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

          if (notification == null) {
            return const SizedBox.shrink();
          }

          return Dismissible(
            key: Key(notification.messageId),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '알림이 삭제됩니다.',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            onDismissed: (direction) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(notificationsProvider.notifier)
                    .deleteNotification(notification.messageId);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('알림이 삭제되었습니다')),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('알림 삭제 중 오류가 발생했습니다')),
                );
              }
            },
            child: GestureDetector(
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
