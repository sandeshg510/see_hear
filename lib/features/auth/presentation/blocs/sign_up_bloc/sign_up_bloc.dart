import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart'; // Make sure to import UserEntity
import '../../../domain/usecases/sign_up_usecase.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUsecase signUpUsecase;

  SignUpBloc({required this.signUpUsecase}) : super(SignUpInitial()) {
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  Future<void> _onSignUpButtonPressed(
    SignUpButtonPressed event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    try {
      // 1. Capture the UserEntity returned by the usecase
      final UserEntity user =
          await signUpUsecase(event.name, event.email, event.password);
      // 2. Pass the captured UserEntity to the SignUpSuccess state
      emit(SignUpSuccess(user)); // <--- Pass 'user' here
    } catch (e) {
      emit(SignUpFailure(error: e.toString()));
    }
  }
}
