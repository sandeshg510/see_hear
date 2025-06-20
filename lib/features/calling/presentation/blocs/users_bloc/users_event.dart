import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/user_entity.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UsersEvent {}

class UsersUpdated extends UsersEvent {
  final List<UserEntity> users;
  const UsersUpdated(this.users);

  @override
  List<Object> get props => [users];
}
