// lib/features/auth/domain/usecases/check_login_status_usecase.dart
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckLoginStatusUsecase {
  final AuthRepository repository;

  CheckLoginStatusUsecase(this.repository);

  // This use case will attempt to get the current UserEntity if logged in.
  Future<UserEntity?> call() async {
    if (repository.isLoggedIn()) {
      // Check directly if a user is logged in via Firebase
      return await repository.getCurrentUser(); // Then fetch their full data
    }
    return null;
  }
}
