import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_team2/data/local/data_base_helper.dart';
import 'package:app_team2/data/models/usermodel.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase 사용자 인증 및 데이터베이스에서 현재 사용자 정보 가져오기
  Future<UserModel?> _getUserData() async {
    User? user = _auth.currentUser; // 현재 로그인된 사용자 정보 가져오기
    if (user != null) {
      // Firebase에서 사용자 데이터 가져오기
      UserModel userModel = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        followers: [], // 추후에 팔로워 데이터 로드 필요
        following: [], // 추후에 팔로잉 데이터 로드 필요
      );

      // 데이터베이스에 저장
      await DatabaseHelper.instance.insertUser(userModel);

      // 데이터베이스에서 사용자 정보 가져오기
      return await DatabaseHelper.instance.getUser(user.uid);
    }
    return null; // 로그인된 사용자가 없을 경우 null 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사용자 목록')),
      body: FutureBuilder<UserModel?>(
        future: _getUserData(), // _getUserData 직접 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('로그인된 사용자가 없습니다.'));
          } else {
            final user = snapshot.data!; // UserModel 가져오기
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
