import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUp(String name, String email, String password);
  Future<UserEntity> signIn(String email, String password);
  Future<void> signOut();
  bool isLoggedIn(); // Changed to sync for Firebase check
  Future<UserEntity?> getCurrentUser(); // Added to retrieve full user data
}
