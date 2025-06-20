import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/sign_in_usecase.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInUsecase signInUsecase;

  SignInBloc({required this.signInUsecase}) : super(SignInInitial()) {
    on<SignInButtonPressed>(_onSignInButtonPressed);
  }

  Future<void> _onSignInButtonPressed(
    SignInButtonPressed event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading());
    try {
      // Capture the UserEntity returned by the use case
      final UserEntity user = await signInUsecase(event.email, event.password);
      // Emit SignInSuccess with the obtained UserEntity
      emit(SignInSuccess(user: user));
    } catch (e) {
      emit(SignInFailure(error: e.toString()));
    }
  }
}
