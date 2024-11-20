import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notifications_message.dart';
import '../../services/firebase_service.dart';
import 'notifications_state.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final FirebaseFirestore _firestore;

  NotificationsNotifier(this._firestore) : super(NotificationsState(notifications: [], isLoading: true)) {
    _subscribeToNotificationCollection();  // 실시간 데이터 리스너 시작
  }

  StreamSubscription<DocumentSnapshot>? _subscription;

  // Firebase에서 실시간으로 알림 데이터 가져오기
  void _subscribeToNotificationCollection() async {
    print('=============데이터 불러오기 시작');
    state = state.copyWith(isLoading: true); // 초기 로딩 상태 설정

    final currentUserUid = FirebaseService().getCurrentUserUid(); // 현재 사용자 UID 가져오기
    if (currentUserUid == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Current user UID is null',
      );
      print("Current user UID is null");
      return;
    }

    _subscription = _firestore
        .collection('notifications')
        .doc(currentUserUid)
        .snapshots()
        .listen(
          (snapshot) {
        print('=============데이터 스냅샷 수신 for UID: $currentUserUid');

        final data = snapshot.data();
        final List<dynamic> messages = data?['messages'] ?? [];

        final newNotifications = messages.map((message) {
          print('=============데이터 수신: $message'); // 데이터 디버깅
          return Notification(
            body: message['body'] ?? '',
            date: message['date'] ?? '',
            postId: message['postId'] ?? '',
            time: message['time'] ?? '',
            title: message['title'] ?? '',
            type: message['type'] ?? '',
            user: message['user'] ?? '',
            comment: message['comment'] ?? ''
          );
        }).toList();

        // 데이터가 추가되었음을 알리는 print문
        print("============New notifications added: ${newNotifications.length}");

        state = state.copyWith(
          notifications: newNotifications, // 전체 상태를 새로 받은 알림으로 갱신
          isLoading: false, // 로딩 종료
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(), // 에러 발생 시 상태 업데이트
          isLoading: false, // 로딩 종료
        );

        // 에러가 발생했음을 알리는 print문
        print("Error fetching notifications: $error");
      },
    );
  }

  // 상태 변경 리스너 취소
  @override
  void dispose() {
    _subscription?.cancel(); // 리스너 종료
    super.dispose();
  }
}
