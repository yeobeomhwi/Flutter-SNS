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
    print('=============데이터 불러오기 시작');
    state = state.copyWith(isLoading: true);

    final currentUserUid = FirebaseService().getCurrentUserUid();
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

        // 전체 데이터 구조 확인
        final data = snapshot.data();
        print('전체 Firestore 데이터: $data');

        final List<dynamic> messages = data?['messages'] ?? [];
        print('메시지 배열: $messages');

        final newNotifications = messages.map((message) {
          print('\n=== 개별 알림 메시지 처리 ===');
          print('메시지 전체 데이터: $message');
          print('메시지 타입: ${message.runtimeType}');

          // 각 필드 개별 출력
          print('postId: ${message['postId']}');
          print('type: ${message['type']}');
          print('body: ${message['body']}');
          print('user: ${message['user']}');
          print('========================\n');

          // null 체크 및 기본값 설정
          final postId = message['postId']?.toString() ?? '';
          if (postId.isEmpty) {
            print('경고: 알림에서 빈 postId 발견');
            print('해당 메시지 전체 내용: $message');
          }

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

        print("\n=== 처리된 알림 요약 ===");
        print('총 알림 수: ${newNotifications.length}');
        for (var notification in newNotifications) {
          print('알림 정보:');
          print('  postId: ${notification.postId}');
          print('  type: ${notification.type}');
          print('  user: ${notification.user}');
        }
        print("========================\n");

        state = state.copyWith(
          notifications: newNotifications,
          isLoading: false,
        );
      },
      onError: (error) {
        print("알림 데이터 가져오기 오류: $error");
        print("오류 세부사항: ${error.toString()}");
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
          // 디버깅 로그 추가
          print('=== Notification Data from Firestore ===');
          print('Document ID: ${doc.id}');
          print('Data: $data');
          print('PostId: ${data['postId']}');
          print('====================================');

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
