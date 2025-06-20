import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props =>
      []; // Added for the sealed class, if not already present
}

final class SignUpInitial extends SignUpState {
  @override
  List<Object?> get props => [];
}

final class SignUpLoading extends SignUpState {
  @override
  List<Object?> get props => [];
}

final class SignUpSuccess extends SignUpState {
  final UserEntity user; // <--- ADD THIS PROPERTY

  const SignUpSuccess(this.user); // <--- ADD THIS CONSTRUCTOR

  @override
  List<Object?> get props => [user]; // <--- ADD 'user' to props
}

final class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
