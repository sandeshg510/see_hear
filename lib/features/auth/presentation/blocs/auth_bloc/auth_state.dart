// lib/features/auth/presentation/blocs/auth_bloc/auth_state.dart
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart'; // Import UserEntity

// Use 'sealed class' for the base state
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state, before any authentication check.
class AuthInitial extends AuthState {}

/// State indicating an authentication operation is in progress.
class AuthLoading extends AuthState {}

/// State indicating the user is authenticated.
class Authenticated extends AuthState {
  final UserEntity user; // <--- ADD THIS PROPERTY
  const Authenticated({required this.user}); // <--- ADD THIS CONSTRUCTOR

  @override
  List<Object> get props => [user]; // <--- ADD 'user' to props
}

/// State indicating the user is not authenticated.
class Unauthenticated extends AuthState {}

/// State indicating an error during an authentication operation.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
