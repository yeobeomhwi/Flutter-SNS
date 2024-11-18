import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final List<String>? followers;
  final List<String>? following;
  final String photoURL;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.followers,
    this.following,
    required this.photoURL,
  });

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    List<String>? followers,
    List<String>? following,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'uid': uid});
    result.addAll({'displayName': displayName});
    result.addAll({'email': email});
    result.addAll({'followers': followers?.join(',')});
    result.addAll({'following': following?.join(',')});
    result.addAll({'photoURL': photoURL});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      followers: map['followers'] != null ? List<String>.from(map['followers'].split(',')) : null,
      following: map['following'] != null ? List<String>.from(map['following'].split(',')) : null,
      photoURL: map['photoURL'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, email: $email, followers: $followers, following: $following, photoURL: $photoURL)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.displayName == displayName &&
        other.email == email &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following) &&
        other.photoURL == photoURL;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
    displayName.hashCode ^
    email.hashCode ^
    followers.hashCode ^
    following.hashCode ^
    photoURL.hashCode;
  }
}
