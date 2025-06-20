import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:see_hear/features/calling/presentation/blocs/users_bloc/users_event.dart';
import 'package:see_hear/features/calling/presentation/blocs/users_bloc/users_state.dart';

import '../../../domain/usecases/get_all_users_usecase.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetAllUsersUsecase getAllUsers;
  StreamSubscription? _usersSubscription;

  UsersBloc({required this.getAllUsers}) : super(UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<UsersUpdated>(_onUsersUpdated);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    // Cancel previous subscription if it exists
    await _usersSubscription?.cancel();
    try {
      _usersSubscription = getAllUsers.call().listen(
        (users) {
          add(UsersUpdated(users)); // Dispatch UsersUpdated when data changes
        },
        onError: (error, stackTrace) {
          emit(UsersError('Failed to load users: ${error.toString()}'));
          print('Error loading users: $error\n$stackTrace');
        },
      );
    } catch (e, stackTrace) {
      emit(UsersError('Failed to initialize user stream: ${e.toString()}'));
      print('Error initializing user stream: $e\n$stackTrace');
    }
  }

  void _onUsersUpdated(UsersUpdated event, Emitter<UsersState> emit) {
    emit(UsersLoaded(event.users));
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel(); // Cancel subscription when BLoC is closed
    return super.close();
  }
}
