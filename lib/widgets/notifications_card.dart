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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(12), // 카드 내 여백을 추가
        decoration: BoxDecoration(
          color: Colors.white, // 배경색을 흰색으로 설정
          borderRadius: BorderRadius.circular(8), // 둥근 모서리
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // 그림자 효과
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2), // 그림자 위치
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 아이콘과 텍스트가 일치하도록 설정
          children: [
            Align(
              alignment: Alignment.center, // 아이콘을 수직 중앙 정렬
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
                        if (type == 'comment' && comment != null)
                          TextSpan(
                            text: ' : $comment',
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
      ),
    );
  }
}
