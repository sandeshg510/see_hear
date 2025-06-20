import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository repository;

  SignInUsecase({required this.repository});

  Future<UserEntity> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
