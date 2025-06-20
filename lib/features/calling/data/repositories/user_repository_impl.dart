import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart'; // Your remote data source

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<UserEntity>> getAllUsers() {
    // Convert the stream of UserModels to a stream of UserEntities
    return remoteDataSource.getAllUsers().map((userModels) {
      return userModels.map((model) => model as UserEntity).toList();
    });
  }
}
