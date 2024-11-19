const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { getFirestore } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");
const fs = require('fs');
const path = require('path');

// Firebase Admin SDK 초기화
admin.initializeApp();

const db = getFirestore();
exports.sendLikeNotification = onDocumentWritten('posts/{postId}', async (event) => {
    const postId = event.params.postId;
    logger.info('-------------가져온 데이터: ' + postId);

    const postData = event.data.after.exists ? event.data.after.data() : null;
    logger.info('-------------변경된 post 데이터: ' + JSON.stringify(postData));

    if (!postData) {
      logger.info('-------------Post 데이터가 존재하지 않습니다');
      return null;
    }

    const previousLikes = event.data.before.exists ? event.data.before.data().likes : [];
    const currentLikes = postData.likes;

    if (currentLikes.length > previousLikes.length) {
      const postOwnerUserId = postData.userId;
      const newLikeUserId = currentLikes[currentLikes.length - 1];

      logger.info('-------------Post owner userId:' + postOwnerUserId);
      const userDocRef = db.collection('users').doc(postOwnerUserId);
      const userSnapshot = await userDocRef.get();

      if (!userSnapshot.exists) {
        logger.info('-------------FCM 토큰에 대한 사용자를 찾을 수 없습니다');
        return null;
      }

      const userData = userSnapshot.data();
      const fcmTokens = userData?.fcmTokens;

      if (!fcmTokens || fcmTokens.length === 0) {
        logger.info('-------------사용자에 대한 FCM 토큰을 찾을 수 없습니다');
        return null;
      }

      const likerDocRef = db.collection('users').doc(newLikeUserId);
      const likerSnapshot = await likerDocRef.get();

      if (!likerSnapshot.exists) {
        logger.info('-------------좋아요를 누른 사용자 정보를 찾을 수 없습니다');
        return null;
      }

      const likerData = likerSnapshot.data();
      const likerName = likerData?.name;
      if (!likerName) {
        logger.info('-------------좋아요 누른 사람의 이름을 찾을 수 없습니다');
        return null;
      }

      logger.info('------------좋아요 누른 유저: ' + likerName);

      // FCM 메시지 생성
      const message = {
        notification: {
          title: "새로운 좋아요",
          body: `${likerName}님이 게시물에 새로운 좋아요를 눌렀습니다.`,
        },
        tokens: fcmTokens, // 유효한 FCM 토큰 배열 그대로 사용
      };

      logger.info('------------FCM 메시지: ' + JSON.stringify(message));

      try {
        // sendMulticast() 사용
        const response = await admin.messaging().sendEachForMulticast({
          tokens: message.tokens,
          notification: message.notification,
        });

        if (response.failureCount > 0) {
          // 실패한 항목을 로그로 출력
          logger.error('FCM 전송 실패 항목: ', response.responses.filter(r => !r.success));
        } else {
          logger.info('FCM 메시지 전송 성공');
        }
      } catch (error) {
        logger.error('FCM 메시지 전송 중 오류 발생:', error);
      }
    }

    return null;
});

exports.sendCommentNotification = onDocumentWritten('posts/{postId}', async (event) => {
    const postId = event.params.postId;
    logger.info('-------------가져온 데이터: ' + postId);

    const postData = event.data.after.exists ? event.data.after.data() : null;
    logger.info('-------------변경된 post 데이터: ' + JSON.stringify(postData));

    if (!postData) {
      logger.info('-------------Post 데이터가 존재하지 않습니다');
      return null;
    }

    const previousComments = event.data.before.exists ? event.data.before.data().comments : [];
    const currentComments = postData.comments;

    if (currentComments.length > previousComments.length) {
      // 새로운 댓글 추가됨
      const postOwnerUserId = postData.userId;
      const newComment = currentComments[currentComments.length - 1];
      const newCommentUserId = newComment.userId;
      const newCommentUserName = newComment.userName;

      logger.info('-------------Post owner userId:' + postOwnerUserId);
      const userDocRef = db.collection('users').doc(postOwnerUserId);
      const userSnapshot = await userDocRef.get();

      if (!userSnapshot.exists) {
        logger.info('-------------FCM 토큰에 대한 사용자를 찾을 수 없습니다');
        return null;
      }

      const userData = userSnapshot.data();
      const fcmTokens = userData?.fcmTokens;

      if (!fcmTokens || fcmTokens.length === 0) {
        logger.info('-------------사용자에 대한 FCM 토큰을 찾을 수 없습니다');
        return null;
      }

      // 댓글을 단 사용자 정보
      const commenterDocRef = db.collection('users').doc(newCommentUserId);
      const commenterSnapshot = await commenterDocRef.get();

      if (!commenterSnapshot.exists) {
        logger.info('-------------댓글을 단 사용자 정보를 찾을 수 없습니다');
        return null;
      }

      const commenterData = commenterSnapshot.data();
      const commenterName = commenterData?.name;
      if (!commenterName) {
        logger.info('-------------댓글 단 사람의 이름을 찾을 수 없습니다');
        return null;
      }

      logger.info('------------댓글 단 유저: ' + commenterName);

      // FCM 메시지 생성
      const message = {
        notification: {
          title: "새로운 댓글",
          body: `${commenterName}님이 게시물에 새로운 댓글을 남겼습니다.`,
        },
        tokens: fcmTokens, // 유효한 FCM 토큰 배열 그대로 사용
      };

      logger.info('------------FCM 메시지: ' + JSON.stringify(message));

      try {
        // sendEachForMulticast() 사용
        const response = await admin.messaging().sendEachForMulticast({
          tokens: message.tokens,
          notification: message.notification,
        });

        if (response.failureCount > 0) {
          // 실패한 항목을 로그로 출력
          logger.error('FCM 전송 실패 항목: ', response.responses.filter(r => !r.success));
        } else {
          logger.info('FCM 메시지 전송 성공');
        }
      } catch (error) {
        logger.error('FCM 메시지 전송 중 오류 발생:', error);
      }
    }

    return null;
});
