import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_team2/data/local/DatabaseHelper.dart';
import 'package:app_team2/data/models/usermodel.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Firebase 사용자 인증 및 데이터베이스에 저장
  Future<void> _getUserData() async {
    User? user = _auth.currentUser; // 현재 로그인된 사용자 정보 가져오기
    if (user != null) {
      // Firebase에서 사용자 데이터 가져오기
      UserModel userModel = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        followers: [],
        following: [],
      );

      // 데이터베이스에 저장
      await DatabaseHelper.instance.insertUser(userModel);
      setState(() {}); // 화면 업데이트
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사용자 목록')),
      body: FutureBuilder<List<UserModel>>(
        future: DatabaseHelper.instance.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('저장된 사용자가 없습니다.'));
          } else {
            final user = snapshot.data!.first; // 하나의 사용자만 저장됨
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 150,
                    backgroundImage: NetworkImage(user.photoURL),
                  ),
                  Text('이름: ${user.displayName}',
                      style: TextStyle(fontSize: 20)),
                  Text('이메일: ${user.email}', style: TextStyle(fontSize: 16)),
                  Text('UId: ${user.uid}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
