import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notifications_message.dart';
import '../../services/firebase_service.dart';
import 'notifications_state.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final FirebaseFirestore _firestore;

  NotificationsNotifier(this._firestore)
      : super(NotificationsState(notifications: [], isLoading: true)) {
    _subscribeToNotificationCollection();
  }

  StreamSubscription<DocumentSnapshot>? _subscription;

  void _subscribeToNotificationCollection() async {
    state = state.copyWith(isLoading: true);

    final currentUserUid = FirebaseService().getCurrentUserUid();
    if (currentUserUid == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Current user UID is null',
      );
      return;
    }

    _subscription = _firestore
        .collection('notifications')
        .doc(currentUserUid)
        .snapshots()
        .listen(
      (snapshot) {
        final data = snapshot.data();
        final List<dynamic> messages = data?['messages'] ?? [];
        print('messages: $messages');

        final newNotifications = messages.map((message) {
          final postId = message['postid']?.toString() ?? '';

          return Notification(
            body: message['body']?.toString() ?? '',
            date: message['date']?.toString() ?? '',
            postId: postId,
            time: message['time']?.toString() ?? '',
            title: message['title']?.toString() ?? '',
            type: message['type']?.toString() ?? '',
            user: message['user']?.toString() ?? '',
            comment: message['comment']?.toString() ?? '',
            messageId: message['messageId']?.toString() ??
                DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(), // 고유한 messageId 생성
          );
        }).toList();

        state = state.copyWith(
          notifications: newNotifications,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void fetchNotifications() {
    try {
      final notificationsRef = _firestore.collection('notifications');

      notificationsRef.snapshots().listen((snapshot) {
        final notifications = snapshot.docs.map((doc) {
          final data = doc.data();

          return Notification.fromMap({
            ...data,
            'id': doc.id,
            'messageId':
                data['messageId'] ?? doc.id, // messageId가 없는 경우 document ID 사용
          });
        }).toList();

        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
        );
      });
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
