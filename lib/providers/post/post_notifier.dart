import 'dart:async';
import 'dart:io';

import 'package:app_team2/data/models/post.dart';
import 'package:app_team2/providers/post/post_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../network/network_providers.dart';

class PostNotifier extends StateNotifier<PostState> {
  final FirebaseFirestore _firestore;
  final Ref ref; // Add reference to the provider

  PostNotifier(this._firestore, this.ref) : super(PostState(posts: [])) {
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

  // 캐시 데이터 로드
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
          createdAt: (data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now()),
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
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(), // null인 경우 현재 시간 사용
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

  // 단일 게시물 불러오기
  Future<void> loadPost(String postId) async {
    try {
      // Firestore에서 해당 postId의 게시물 데이터를 가져오는 로직
      final docSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (docSnapshot.exists) {
        final postData = docSnapshot.data()!;
        // 기존 posts 리스트에 새로운 post 추가
        state = state.copyWith(
          posts: [
            ...state.posts,
            Post.fromMap({...postData, 'postId': postId})
          ],
        );
      }
    } catch (e) {
      print('Error loading post: $e');
    }
  }

  // 게시물 추가 함수
  Future<void> addPost({
    required String userId,
    required String userName,
    required String profileImage,
    required String caption,
    required bool isSynced,
    required FieldValue createdAt,
    required List<String> likes,
    required List<String> comments,
    required List<String> imageUrls,
    required String postId,
  }) async {
    try {
      // Firestore에 저장할 데이터
      final newPost = {
        'postId': postId, // 게시물 ID
        'userId': userId, // 작성자 ID
        'userName': userName, // 작성자 이름
        'profileImage': profileImage, // 작성자 프로필 이미지
        'imageUrls': imageUrls,
        'caption': caption, // 게시물 내용
        'isSynced': false, // 동기화 여부는 오프라인이므로 false
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'likes': likes, // 좋아요 리스트
        'comments': <Map<String, dynamic>>[], // 빈 댓글 리스트로 초기화
      };

      final currentPosts = state.posts;

      final updatedPost = Post(
        postId: postId,
        userId: userId,
        userName: userName,
        profileImage: profileImage,
        imageUrls: imageUrls,
        caption: caption,
        createdAt: createdAt ?? FieldValue.serverTimestamp(),
        likes: likes,
        comments: [],
        isSynced: false,
      );
      final updatedPosts = List<Post>.from(currentPosts)..add(updatedPost);
      state = state.copyWith(posts: updatedPosts);

      // Firestore에 오프라인 상태로 저장
      await _firestore.collection('posts').doc(postId).set(newPost);

      // 네트워크가 연결되면 Firestorage에 이미지를 업로드하고 URL을 업데이트
      if (ref.read(networkStateProvider).isOnline) {
        List<String> updatedImageUrls = [];

        for (String imageUrl in imageUrls) {
          // 이미지 파일 리사이징
          final imageFile = File(imageUrl);
          final resizedImageFile = await resizeImage(imageFile, 600);

          // Firestorage에 업로드
          String fileName =
              'images/$postId/${Uri.parse(imageUrl).pathSegments.last}';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);

          // 리사이징된 이미지 업로드
          final uploadTask = storageRef.putFile(resizedImageFile);
          final downloadUrl = await (await uploadTask).ref.getDownloadURL();

          updatedImageUrls.add(downloadUrl);
        }

        // Firestore에서 imageUrls 업데이트
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'imageUrls': updatedImageUrls,
          'isSynced': true, // 동기화 완료
        });
        print('이미지 URL 업데이트 완료');
      }
    } catch (e) {
      print("게시물 추가 중 오류 발생: $e");
    }
  }

  // 임시 저장 경로에 이미지 저장
  Future<String> saveImageLocally(
      File imageFile, String postId, int index) async {
    try {
      // 로컬 경로 얻기
      final directory = await getTemporaryDirectory();
      final localPath = '${directory.path}/${postId}_{$index}.jpg';

      // 로컬 파일로 저장
      await imageFile.copy(localPath);

      return localPath;
    } catch (e) {
      print("로컬 저장 중 오류 발생: $e");
      rethrow;
    }
  }

  // Firebase Storage에 이미지 업로드
  Future<String> uploadImageToStorage(
      File imageFile, String postId, int index) async {
    try {
      // Firebase Storage 경로 정의
      final path = 'post_images/${postId}_{$index}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(path);

      // Firebase Storage에 이미지 업로드
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("이미지 업로드 중 오류 발생: $e");
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

  // 게시물 캡션 업데이트
  Future<void> updateCaption({
    required String postId,
    required String newCaption,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'caption': newCaption,
      });
      state =
          state.copyWith(isUpdateCaption: true); // isUpdateCaption 값을 true로 변경
    } catch (e) {
      state = state.copyWith(error: e.toString()); // 오류 처리
      throw Exception('게시물 수정 중 오류가 발생했습니다');
    }
  }

  Future<File> resizeImage(File imageFile, int targetHeight) async {
    // 원본 이미지 로드
    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) {
      throw Exception("이미지 디코딩에 실패했습니다.");
    }

    // 비율에 맞게 너비 계산
    final aspectRatio = originalImage.width / originalImage.height;
    final targetWidth = (targetHeight * aspectRatio).round();

    // 리사이징
    final resizedImage = img.copyResize(
      originalImage,
      width: targetWidth,
      height: targetHeight, // 세로 고정
    );

    // 리사이징된 이미지 저장
    final resizedImagePath = '${imageFile.path}_resized.jpg';
    final resizedImageFile = File(resizedImagePath);
    await resizedImageFile.writeAsBytes(img.encodeJpg(resizedImage));

    return resizedImageFile;
  }

  // 리소스 해제
  @override
  void dispose() {
    _subscription?.cancel(); // Firestore 구독 취소
    super.dispose();
  }
}
