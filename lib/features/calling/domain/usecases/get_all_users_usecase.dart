import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUsersUsecase {
  final UserRepository repository;

  GetAllUsersUsecase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getAllUsers();
  }
}
