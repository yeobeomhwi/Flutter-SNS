const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Firebase Admin SDK 초기화
admin.initializeApp();

exports.notifyPostOwner = functions.firestore.onDocumentUpdated(
  "posts/{postId}",
  async (event) => {
    const beforeComments = event.data.before.data().comments || [];
    const afterComments = event.data.after.data().comments || [];

    // 새로 추가된 댓글 감지
    if (afterComments.length <= beforeComments.length) return null;
    const newComment = afterComments[afterComments.length - 1];

    const userId = event.data.after.data().userId; // 게시물 작성자의 userId
    const userName = newComment.userName || "Unknown User";
    const comment = newComment.comment || "";

    if (!userId) {
      console.log("게시물 작성자의 userId가 없습니다.");
      return null;
    }

    try {
      // `users/{userId}`에서 FCM 토큰 가져오기
      const userDoc = await admin.firestore()
        .collection("users").doc(userId).get();

      if (!userDoc.exists) {
        console.log("게시물 작성자의 사용자 문서를 찾을 수 없습니다.");
        return null;
      }

      const tokens = userDoc.data().fcmTokens || [];
      if (tokens.length === 0) {
        console.log("게시물 작성자의 FCM 토큰이 없습니다.");
        return null;
      }

      // 알림 제목과 본문 설정
      const title = "새로운 댓글이 달렸습니다.";
      const body = `${userName}: ${comment}`;

      // FCM으로 알림 보내기
      const payload = {
        notification: {title, body},
      };

      await admin.messaging().sendToDevice(tokens, payload);
      console.log("알림 전송 성공:", {title, body, tokens});
    } catch (error) {
      console.error("알림 전송 실패:", error);
    }

    return null;
  }
);

exports.notifyPostOwnerOnLike = functions.firestore.onDocumentUpdated(
  "posts/{postId}",
  async (event) => {
    const beforeLikes = event.data.before.data().likes || [];
    const afterLikes = event.data.after.data().likes || [];

    // 새로 추가된 좋아요 감지
    if (afterLikes.length <= beforeLikes.length) return null;
    const newLike = afterLikes[afterLikes.length - 1];

    const userId = event.data.after.data().userId; // 게시물 작성자의 userId
    const userName = newLike.userName || "Unknown User";

    if (!userId) {
      console.log("게시물 작성자의 userId가 없습니다.");
      return null;
    }

    try {
      // 디버깅 메시지 추가
      console.log("userId:", userId);

      // `users/{userId}`에서 FCM 토큰 가져오기
      const userDoc = await admin.firestore()
        .collection("users").doc(userId).get();

      console.log("userDoc.exists:", userDoc.exists);

      if (!userDoc.exists) {
        console.log("게시물 작성자의 사용자 문서를 찾을 수 없습니다.");
        return null;
      }

      const tokens = userDoc.data().fcmTokens || [];
      if (tokens.length === 0) {
        console.log("게시물 작성자의 FCM 토큰이 없습니다.");
        return null;
      }

      // 알림 제목과 본문 설정
      const title = "새로운 좋아요가 추가되었습니다.";
      const body = `${userName}님이 게시물을 좋아합니다.`;

      // FCM으로 알림 보내기
      const payload = {
        notification: {title, body},
      };

      await admin.messaging().sendToDevice(tokens, payload);
      console.log("알림 전송 성공:", {title, body, tokens});
    } catch (error) {
      console.error("알림 전송 실패:", error);
    }

    return null;
  }
);
