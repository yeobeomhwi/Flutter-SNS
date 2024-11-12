import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
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
        GestureDetector(
          onTap: () {},
          child: Image.network(
            'https://picsum.photos/250/250',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
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
