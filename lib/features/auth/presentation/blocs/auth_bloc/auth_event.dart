// lib/features/auth/presentation/blocs/auth_bloc/auth_event.dart
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart'; // Import UserEntity

// Use 'sealed class' for the base event
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched when the app starts to check the initial authentication status.
class AuthStatusRequested extends AuthEvent {}

/// Event dispatched by SignInBloc or SignUpBloc upon successful authentication.
class AuthLoggedIn extends AuthEvent {
  final UserEntity user; // <--- ADD THIS PROPERTY
  const AuthLoggedIn(this.user); // <--- ADD THIS CONSTRUCTOR

  @override
  List<Object> get props => [user]; // <--- ADD 'user' to props
}

/// Event dispatched to log the user out.
class AuthLoggedOut extends AuthEvent {}
