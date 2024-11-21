import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String type; // 알림 타입 (like 또는 comment)
  final String body; // 알림 메시지
  final String user; // 액션한 사용자
  final String date; // 알림 날짜
  final String time; // 알림 시간
  final String? comment; // 댓글

  // 생성자
  const NotificationCard({
    super.key,
    required this.type,
    required this.body,
    required this.date,
    required this.time,
    required this.user,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              // type에 따라 아이콘 변경
              type == 'like' ? Icons.favorite : Icons.comment,
              color: type == 'like' ? Colors.red : Colors.blue,
              // like일 때는 빨간색, comment일 때는 파란색
              size: 30, // 아이콘 크기 설정
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: user,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: body,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (type == 'comment' && comment != null)
                  Text(
                    '"$comment"',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff555555),
                    ),
                  ),
                Text(
                  '$date $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
