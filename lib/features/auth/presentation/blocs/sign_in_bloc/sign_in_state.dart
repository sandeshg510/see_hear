part of 'sign_in_bloc.dart';

sealed class SignInState extends Equatable {
  const SignInState();
}

final class SignInInitial extends SignInState {
  @override
  List<Object> get props => [];
}

final class SignInLoading extends SignInState {
  @override
  List<Object> get props => [];
}

final class SignInSuccess extends SignInState {
  final UserEntity user;

  const SignInSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

final class SignInFailure extends SignInState {
  final String error;

  const SignInFailure({required this.error});

  @override
  List<Object> get props => [];
}
