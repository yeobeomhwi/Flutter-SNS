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
    _subscribeToNotificationCollection(); // 실시간 데이터 리스너 시작
  }

  StreamSubscription<DocumentSnapshot>? _subscription;

  // Firebase에서 실시간으로 알림 데이터 가져오기
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
        // 전체 데이터 구조 확인
        final data = snapshot.data();

        final List<dynamic> messages = data?['messages'] ?? [];
        print('messages: $messages');

        final newNotifications = messages.map((message) {
          // null 체크 및 기본값 설정
          final postId = message['postid']?.toString() ?? '';
          if (postId.isEmpty) {}

          return Notification(
              body: message['body']?.toString() ?? '',
              date: message['date']?.toString() ?? '',
              postId: postId,
              time: message['time']?.toString() ?? '',
              title: message['title']?.toString() ?? '',
              type: message['type']?.toString() ?? '',
              user: message['user']?.toString() ?? '',
              comment: message['comment']?.toString() ?? '');
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

  // 상태 변경 리스너 취소
  @override
  void dispose() {
    _subscription?.cancel(); // 리스너 종료
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
