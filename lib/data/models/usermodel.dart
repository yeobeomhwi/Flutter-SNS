import 'dart:convert';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
  });

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'uid': uid});
    result.addAll({'displayName': displayName});
    result.addAll({'email': email});
    result.addAll({'photoURL': photoURL});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, email: $email photoURL: $photoURL)';

  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.displayName == displayName &&
        other.email == email &&
        other.photoURL == photoURL;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        displayName.hashCode ^
        email.hashCode ^
        photoURL.hashCode;

  }
}
