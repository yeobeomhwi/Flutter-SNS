import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // 추가 라이브러리

class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // 이미지 목록
  final List<String> imageUrls = [
    'https://picsum.photos/250/250?1',
    'https://picsum.photos/250/250?2',
    'https://picsum.photos/250/250?3',
  ];

  // PageController 선언
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
              ),
              SizedBox(width: 8),
              Text('닉네임'),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
        // PageView로 여러 이미지를 좌우로 넘기기
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 300,
            child: PageView.builder(
              controller: _controller,  // controller 연결
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: SmoothPageIndicator(
              controller: _controller,  // controller 연결
              count: imageUrls.length,
              effect: WormEffect(
                dotWidth: 8.0,
                dotHeight: 8.0,
                spacing: 16.0,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
              IconButton(onPressed: () {}, icon: Icon(Icons.comment_outlined)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('12 likes', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4.0),
              Text('닉네임: This is the caption for the post.',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 4.0),
              Text('1 hour ago',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey)),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
