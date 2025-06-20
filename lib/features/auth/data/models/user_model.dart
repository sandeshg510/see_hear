import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.uid, required super.email, required super.name});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'email': email};
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snap.id, // Document ID is the UID
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      // profileImageUrl: data['profileImageUrl'] ?? '',
      // lastMessage: data['lastMessage'] ?? '', // Make sure these fields exist in Firestore
      // lastMessageTime: data['lastMessageTime'] ?? '',
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));

  String toJson() => json.encode(toMap());
}
