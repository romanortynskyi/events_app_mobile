import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/services/auth_service.dart';
import 'package:flutter/widgets.dart';

part 'email_sign_in_event.dart';
part 'email_sign_in_state.dart';

class EmailSignInBloc extends Bloc<EmailSignInEvent, EmailSignInState> {
  EmailSignInBloc({required this.authService})
      : super(const UnAuthenticated(user: null)) {
    on<EmailSignInRequested>(_onEmailSignInPressed);
    on<EmailSignUpRequested>(_onEmailSignUpPressed);
    on<EmailSignInErrorRequested>(_onEmailSignInError);
    on<EmailSignOutRequested>(_onEmailSignOutPressed);
    on<EmailGetMeRequested>(_onGetMe);
  }
  final AuthService authService;

  Future<void> _onEmailSignInPressed(
    EmailSignInRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    emit(const Loading());

    try {
      final user = await authService.signIn(
        context: event.context,
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        emit(Authenticated(user: user));
      }
    } catch (e) {
      emit(Error(errorMessage: e.toString()));
    }
  }

  void _onEmailSignUpPressed(
    EmailSignUpRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    emit(const Loading());

    try {
      final user = await authService.signUp(
        context: event.context,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );

      if (user != null) {
        emit(Authenticated(user: user));
      }
    } catch (e) {
      emit(Error(errorMessage: e.toString()));
    }
  }

  void _onEmailSignInError(
    EmailSignInErrorRequested event,
    Emitter<EmailSignInState> emit,
  ) {
    emit(Error(errorMessage: event.errorMessage));
  }

  void _onEmailSignOutPressed(
    EmailSignOutRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    await authService.signOut();

    emit(const UnAuthenticated(user: null));
  }

  void _onGetMe(
    EmailGetMeRequested event,
    Emitter<EmailSignInState> emit,
  ) async {
    User? user = await authService.getMe(event.context);

    if (user != null) {
      Authenticated(user: user);
    }
  }
}
