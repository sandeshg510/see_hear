import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart'; // Alias to avoid conflict with UserEntity

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  // Helper to map Firebase User and Firestore data to UserEntity
  Future<UserEntity?> _mapFirebaseUserToUserEntity(
      fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) return null;

    // Fetch additional user data from Firestore
    final authUserModel =
        await remoteDataSource.getAuthUserModel(firebaseUser.uid);

    return UserEntity(
      uid: firebaseUser.uid,
      name: authUserModel?.name ??
          firebaseUser.displayName ??
          firebaseUser.email?.split('@')[0] ??
          'User',
      email: authUserModel?.email ?? firebaseUser.email!,
      // profileImageUrl: authUserModel?.profileImageUrl ?? firebaseUser.photoURL,
      // lastMessage: null, // Placeholder, populate from chat feature
      // lastMessageTime: null, // Placeholder, populate from chat feature
    );
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final fb_auth.User firebaseUser =
          await remoteDataSource.signIn(email, password);
      final userEntity = await _mapFirebaseUserToUserEntity(firebaseUser);
      if (userEntity == null) {
        throw Exception(
            'Failed to map Firebase User to UserEntity after sign-in.');
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password) async {
    try {
      final fb_auth.User firebaseUser =
          await remoteDataSource.signUp(name, email, password);
      final userEntity = await _mapFirebaseUserToUserEntity(firebaseUser);
      if (userEntity == null) {
        throw Exception(
            'Failed to map Firebase User to UserEntity after sign-up.');
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool isLoggedIn() {
    // Rely directly on FirebaseAuth's current user. Firebase handles persistence.
    final firebaseUser = remoteDataSource.currentFirebaseUser;
    return firebaseUser != null && !firebaseUser.isAnonymous;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = remoteDataSource.currentFirebaseUser;
    if (firebaseUser != null) {
      return await _mapFirebaseUserToUserEntity(firebaseUser);
    }
    return null;
  }
}
