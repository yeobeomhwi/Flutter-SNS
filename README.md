# SNS 앱 프로젝트

오프라인 환경에서도 동작하는 SNS 앱으로, SQLite와 Firebase를 활용하여 로컬 데이터베이스를 구축하고 효율적인 데이터 관리를 구현한 프로젝트입니다.

## 📅 개발 기간
- 2024.11.11 ~ 2024.11.22

## 🛠 사용 기술
### 프레임워크 & 언어
- Dart
- Flutter

### 상태관리
- flutter_riverpod

### Firebase 서비스
- Firebase Auth
- Cloud Firestore
- Cloud Functions
- Cloud Storage
- Cloud Messaging

### 주요 패키지
- connectivity_plus
- shared_preferences
- flutter_local_notifications
- permission_handler
- cached_network_image
- image_picker
- go_router
- path_provider

## 🔍 주요 기능

### 1. 회원가입 & 로그인
- Firebase Auth를 통한 이메일/구글 로그인 구현
- 회원가입 시 기본 프로필 이미지 Storage 저장
- FCM 토큰 관리 및 알림 데이터 컬렉션 생성

### 2. 프로필 관리
- 프로필 사진 변경 (디바이스 갤러리 연동)
- 닉네임 변경
- 오프라인 데이터 로딩 지원

### 3. 피드 기능
- 온라인/오프라인 게시물 작성
- 오프라인 작성 게시물 자동 동기화
- Cached Network Image를 통한 이미지 캐싱

### 4. 좋아요 & 댓글
- 실시간 좋아요 기능
- 댓글 시스템
- FCM을 통한 알림 전송
- 알림 이력 관리

### 5. 오프라인 지원
- SQLite를 통한 로컬 데이터 저장
- 네트워크 상태 모니터링
- 자동 데이터 동기화

## 💡 특징
- Offline-First 앱 개발 방법론 적용
- Firebase의 오프라인 기능과 캐시 활용
- Riverpod을 통한 체계적인 상태 관리
- 실시간 데이터 동기화

## 🔧 구현 내용
1. **로컬 데이터베이스 구축**
  - SQLite를 활용한 오프라인 데이터 저장
  - Firebase와의 자동 동기화 구현

2. **사용자 인증 시스템**
  - 이메일/구글 로그인 지원
  - 프로필 관리 기능

3. **실시간 알림 시스템**
  - Cloud Functions를 통한 알림 로직 구현
  - FCM을 활용한 푸시 알림

4. **이미지 최적화**
  - 이미지 캐싱 시스템 구현
  - 오프라인 이미지 접근 지원

## 📱 스크린샷
[스크린샷 추가 예정]

## 🔗 링크
- [GitHub 저장소](https://github.com/yeobeomhwi/Flutter-SNS)