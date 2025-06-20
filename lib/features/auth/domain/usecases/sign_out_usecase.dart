// lib/features/auth/domain/usecases/sign_out_user.dart
import '../repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository repository;

  SignOutUsecase(this.repository);

  Future<void> call() async {
    await repository.signOut(); // Call a method on your repository
  }
}
