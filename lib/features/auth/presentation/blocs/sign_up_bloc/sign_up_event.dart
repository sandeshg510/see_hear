import 'package:equatable/equatable.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();
}

final class SignUpButtonPressed extends SignUpEvent {
  final String name;
  final String email;
  final String password;

  const SignUpButtonPressed({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}
