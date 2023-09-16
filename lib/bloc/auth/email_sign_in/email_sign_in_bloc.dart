import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';

part 'email_sign_in_event.dart';
part 'email_sign_in_state.dart';

class EmailSignInBloc extends Bloc<EmailSignInEvent, EmailSignInState> {
  EmailSignInBloc({required this.authRepository})
      : super(UnAuthenticated(null)) {
    on<EmailSignInRequested>(_onEmailSignInPressed);
    on<EmailSignOutRequested>(_onEmailSignOutPressed);
    on<EmailGetMeRequested>(_onGetMe);
  }
  final AuthRepository authRepository;

  Future<void> _onEmailSignInPressed(
    EmailSignInRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    emit(Loading(null));
    final user = await authRepository.signIn(
      context: event.context,
      email: event.email,
      password: event.password,
    );

    if (user != null) {
      emit(Authenticated(user));
    }
  }

  void _onEmailSignOutPressed(
    EmailSignOutRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    await authRepository.signOut();
    emit(UnAuthenticated(null));
  }

  void _onGetMe(
    EmailGetMeRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    User? user = await authRepository.getMe(event.context);

    if (user != null) {
      Authenticated(user);
    }
  }
}
