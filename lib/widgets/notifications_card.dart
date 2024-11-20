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
    Key? key,
    required this.type,
    required this.body,
    required this.date,
    required this.time,
    required this.user,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(12), // 카드 내 여백을 추가
        decoration: BoxDecoration(
          color: Colors.white, // 배경색을 흰색으로 설정
          borderRadius: BorderRadius.circular(8), // 둥근 모서리
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // 그림자 효과
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2), // 그림자 위치
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
            SizedBox(width: 16), // 아이콘과 텍스트 간 간격 조정
            Expanded(
              // 텍스트 영역을 확장하여 여백이 생기지 않게 함
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$user', // 사용자 이름 부분
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold, // 굵게 설정
                            color: Colors.black, // 텍스트 색상 설정
                          ),
                        ),
                        TextSpan(
                          text: body, // 알림 메시지 본문
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal, // 기본 설정
                            color: Colors.black, // 텍스트 색상 설정
                          ),
                        ),
                        if (type == 'comment' &&
                            comment != null) // comment가 있을 경우 추가
                          TextSpan(
                            text: ' : $comment', // 댓글 내용 추가
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal, // 일반 텍스트
                              color: Colors.black, // 댓글 색상
                            ),
                          ),
                      ],
                    ),
                    maxLines: 2, // 두 줄까지 출력
                    overflow: TextOverflow.ellipsis, // 넘칠 경우 말줄임표
                  ),
                  Text(
                    '$date $time', // 날짜와 시간
                    style: TextStyle(
                      fontSize: 12, // 폰트 크기 설정
                      color: Colors.grey[600], // 시간과 날짜 색상 조정
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
