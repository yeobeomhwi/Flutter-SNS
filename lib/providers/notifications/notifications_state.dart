import '../../data/models/notifications_message.dart';

class NotificationsState {
  final List<Notification>? notifications;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.notifications,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
}){
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
