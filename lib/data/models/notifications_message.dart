import 'dart:convert';

class Notification {
  final String body;
  final String date;
  final String user;
  final String comment;
  final String postId;
  final String time;
  final String title;
  final String type;

  Notification(
      {required this.body,
      required this.date,
      required this.postId,
      required this.time,
      required this.title,
      required this.type,
      required this.user,
      this.comment = ""});

  Notification copyWith({
    String? body,
    String? date,
    String? postId,
    String? time,
    String? title,
    String? type,
    String? user,
    String? comment,
  }) {
    return Notification(
        body: body ?? this.body,
        date: date ?? this.date,
        postId: postId ?? this.postId,
        time: time ?? this.time,
        title: title ?? this.title,
        type: type ?? this.type,
        user: user ?? this.user,
        comment: comment ?? this.comment);
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'body': body});
    result.addAll({'date': date});
    result.addAll({'postId': postId});
    result.addAll({'time': time});
    result.addAll({'title': title});
    result.addAll({'type': type});
    result.addAll({'user': user});
    result.addAll({'comment': comment});

    return result;
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      body: map['body'] ?? '',
      date: map['date'] ?? '',
      postId: map['postId'] ?? '',
      time: map['time'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      user: map['user'] ?? '',
      comment:  map['comment'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NotificationMessage(body: $body, date: $date, postId: $postId, time: $time, title: $title, type: $type, user: $user, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Notification &&
        other.body == body &&
        other.date == date &&
        other.postId == postId &&
        other.time == time &&
        other.title == title &&
        other.type == type;
  }

  @override
  int get hashCode {
    return body.hashCode ^
        date.hashCode ^
        postId.hashCode ^
        time.hashCode ^
        title.hashCode ^
        type.hashCode;
  }
}
