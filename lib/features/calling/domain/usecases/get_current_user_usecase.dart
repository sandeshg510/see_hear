// lib/features/auth/domain/usecases/get_current_user.dart

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<UserEntity?> call() async => await repository.getCurrentUser();
}
