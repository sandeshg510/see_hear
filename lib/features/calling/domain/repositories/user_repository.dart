import '../../../auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Stream<List<UserEntity>> getAllUsers();
// You might add Future<UserEntity> getUserById(String uid); later
}
