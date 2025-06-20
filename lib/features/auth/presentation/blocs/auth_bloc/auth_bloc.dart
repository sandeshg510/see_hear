// lib/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/check_login_status_usecase.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckLoginStatusUsecase checkLoginStatusUsecase;
  final SignOutUsecase signOutUser;

  AuthBloc({
    required this.checkLoginStatusUsecase,
    required this.signOutUser,
  }) : super(AuthInitial()) {
    on<AuthStatusRequested>(_onAuthStatusRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  Future<void> _onAuthStatusRequested(
      AuthStatusRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Use the usecase to check if Firebase has a current user and get their data
      final UserEntity? user = await checkLoginStatusUsecase.call();
      if (user != null) {
        emit(Authenticated(user: user));
        print('AuthBloc: User is Authenticated: ${user.name}');
      } else {
        emit(Unauthenticated());
        print('AuthBloc: User is Unauthenticated.');
      }
    } catch (e, stackTrace) {
      print('AuthBloc Error: Failed to check authentication status. $e');
      print('StackTrace: $stackTrace');
      emit(AuthError(
          'Failed to check authentication status. Please try again.'));
    }
  }

  Future<void> _onAuthLoggedIn(
      AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(Authenticated(user: event.user));
    print(
        'AuthBloc: Successfully logged in and user data provided: ${event.user.name}');
  }

  Future<void> _onAuthLoggedOut(
      AuthLoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Show loading while signing out
    try {
      await signOutUser.call();
      emit(Unauthenticated());
      print('AuthBloc: User successfully logged out.');
    } catch (e, stackTrace) {
      print('AuthBloc Error: Failed to sign out. $e');
      print('StackTrace: $stackTrace');
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }
}
