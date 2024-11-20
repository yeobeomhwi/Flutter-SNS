import 'dart:async';
import 'dart:io';

import 'package:app_team2/data/models/post.dart';
import 'package:app_team2/providers/post/post_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PostNotifier extends StateNotifier<PostState> {
  final FirebaseFirestore _firestore;

  PostNotifier(this._firestore) : super(PostState(posts: [])) {
    _enableOfflineMode(); // 오프라인 모드 활성화
    _monitorConnectionStatus(); // Firestore 동기화 상태 모니터링
  }

  StreamSubscription<QuerySnapshot>? _subscription;

  // Firestore 오프라인 모드 설정
  void _enableOfflineMode() {
    _firestore.settings = const Settings(
      persistenceEnabled: true, // 오프라인에서도 데이터 저장 가능
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // 캐시 크기 무제한
    );
  }

  // Firestore 서버와의 동기화 상태 모니터링
  void _monitorConnectionStatus() {
    _firestore.snapshotsInSync().listen((_) {
      state = state.copyWith(isSyncedWithServer: true); // 동기화 성공
      print("Firestore가 서버와 동기화되어 있습니다.");
    }, onError: (error) {
      state = state.copyWith(isSyncedWithServer: false); // 동기화 실패
      print("Firestore 동기화 에러: $error");
    });
  }

  Future<void> fetchCachedPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.cache)); // 캐시 데이터 사용

      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          postId: doc.id,
          userId: data['userId'] as String,
          userName: data['userName'] as String,
          profileImage: data['profileImage'] as String,
          imageUrls: List<String>.from(data['imageUrls'] as List),
          caption: data['caption'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          likes: List<String>.from(data['likes'] as List),
          comments: List<Map<String, dynamic>>.from(data['comments'] as List),
          isSynced: false,
        );
      }).toList();

      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      print('=========에러 : $e');
      state = state.copyWith(
          error: "캐시 데이터 로드 실패: ${e.toString()}", isLoading: false);
    }
  }

  // Firestore 'posts' 컬렉션을 실시간으로 구독
  void subscribeToPostsCollection() {
    state = state.copyWith(isLoading: true); // 로딩 상태로 변경

    _subscription = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true) // 작성 시간 기준 내림차순 정렬
        .snapshots()
        .listen(
      (snapshot) {
        // Firestore 문서를 Post 모델로 변환하여 상태 업데이트
        final posts = snapshot.docs.map((doc) {
          final data = doc.data();
          return Post(
            postId: doc.id,
            userId: data['userId'] as String,
            userName: data['userName'] as String,
            profileImage: data['profileImage'] as String,
            imageUrls: List<String>.from(data['imageUrls'] as List),
            caption: data['caption'] as String,
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            likes: List<String>.from(data['likes'] as List),
            comments: List<Map<String, dynamic>>.from(data['comments'] as List),
            isSynced: true,
          );
        }).toList();

        state = state.copyWith(posts: posts, isLoading: false); // 상태 업데이트
      },
      onError: (error) {
        state =
            state.copyWith(error: error.toString(), isLoading: false); // 오류 처리
      },
    );
  }

  // 새로운 게시물 추가 (오프라인 상태에서 처리)
  Future<void> addPost({
    required String postId,
    required String userId,
    required String userName,
    required String profileImage,
    required List<String> imageUrls,
    required String caption,
    required bool isSynced,
    required FieldValue createdAt,
    required List<String> likes,
    required List<String> comments,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final postId = '$userId$timestamp';
    try {
      final newPost = {
        'postId': postId, // 게시물 ID
        'userId': userId, // 작성자 ID
        'userName': userName, // 작성자 이름
        'profileImage': profileImage, // 작성자 프로필 이미지
        'imageUrls': imageUrls, // 게시물 이미지
        'caption': caption, // 게시물 내용
        'isSynced': isSynced, // 동기화 여부a
        'createdAt': FieldValue.serverTimestamp() ?? Timestamp.now(),
        'likes': likes, // 좋아요 리스트
        'comments': comments, // 댓글 리스트
      };

      // Firestore에 새로운 게시물 추가
      await _firestore.collection('posts').doc(postId).set(newPost);

      // 오프라인에서 추가한 데이터를 로컬 캐시에 저장
      state = state.copyWith(
          posts: [...state.posts, Post.fromMap(newPost)], isLoading: false);

      // 네트워크가 복구되면 동기화하는 로직 추가 가능
    } catch (e) {
      state = state.copyWith(error: e.toString()); // 오류 처리
    }
  }

  // 임시 저장 경로에 이미지 저장
  Future<String> saveImageLocally(File imageFile, String postId, int index) async {
    try {
      // 로컬 경로 얻기
      final directory = await getTemporaryDirectory();
      final localPath = '${directory.path}/${postId}_$index.jpg';

      // 로컬 파일로 저장
      await imageFile.copy(localPath);

      return localPath;
    } catch (e) {
      print("로컬 저장 중 오류 발생: $e");
      rethrow;
    }
  }

  // 게시물 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .delete(); // Firestore에서 게시물 삭제
    } catch (e) {
      state = state.copyWith(error: e.toString()); // 오류 처리
    }
  }

  // 게시물 좋아요 추가/제거
  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) return; // 게시물이 존재하지 않으면 종료

      final likes = List<String>.from(postDoc.data()?['likes'] as List);

      if (likes.contains(userId)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId]) // 좋아요 제거
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId]) // 좋아요 추가
        });
      }
    } catch (e) {
      state = state.copyWith(error: e.toString()); // 오류 처리
    }
  }

  // 댓글 추가
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    try {
      final now = DateTime.now();
      final commentData = {
        'commentId': now.millisecondsSinceEpoch.toString(), // 고유 댓글 ID
        'userId': userId, // 댓글 작성자 ID
        'userName': userName, // 댓글 작성자 이름
        'comment': comment, // 댓글 내용
        'createdAt': Timestamp.fromDate(now), // 작성 시간
      };

      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([commentData]) // 댓글 추가
      });
    } catch (e) {
      state = state.copyWith(error: e.toString()); // 오류 처리
    }
  }

  // 댓글 삭제
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final docSnapshot =
          await _firestore.collection('posts').doc(postId).get(); // 게시물 가져오기
      final comments = List<Map<String, dynamic>>.from(
          docSnapshot.data()?['comments'] ?? []); // 현재 댓글 목록 가져오기

      comments
          .removeWhere((comment) => comment['commentId'] == commentId); // 댓글 제거

      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'comments': comments}); // 업데이트된 댓글 저장
    } catch (e) {
      state = state.copyWith(error: e.toString()); // 오류 처리
    }
  }

  // 리소스 해제
  @override
  void dispose() {
    _subscription?.cancel(); // Firestore 구독 취소
    super.dispose();
  }
}
