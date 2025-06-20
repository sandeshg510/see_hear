import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository repository;

  SignUpUsecase({required this.repository});

  Future<UserEntity> call(String name, String email, String password) {
    return repository.signUp(name, email, password);
  }
}
