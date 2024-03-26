import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/services/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService})
      : super(const UnAuthenticated(user: null)) {
    on<EmailSignInRequested>(_onEmailSignInPressed);
    on<EmailSignUpRequested>(_onEmailSignUpPressed);
    on<EmailSignInErrorRequested>(_onEmailSignInError);
    on<EmailGetMeRequested>(_onEmailGetMe);

    on<FacebookSignInRequested>(_onFacebookSignInPressed);
    on<FacebookGetMeRequested>(_onFacebookGetMe);

    on<GoogleSignInRequested>(_onGoogleSignInPressed);
    on<GoogleGetMeRequested>(_onGoogleGetMe);

    on<SignOutRequested>(_onSignOutPressed);
  }
  final AuthService authService;

  Future<void> _onEmailSignInPressed(
    EmailSignInRequested event,
    Emitter<AuthState> emit,
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
    Emitter<AuthState> emit,
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
    Emitter<AuthState> emit,
  ) {
    emit(Error(errorMessage: event.errorMessage));
  }

  void _onSignOutPressed(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authService.signOut();

    emit(const UnAuthenticated(user: null));
  }

  void _onEmailGetMe(
    EmailGetMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    User? user =
        await authService.getMe(event.context, FetchPolicy.networkOnly);

    if (user != null) {
      Authenticated(user: user);
    }
  }

  Future<void> _onFacebookSignInPressed(
    FacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Loading());

    final user = await authService.signInWithFacebook(event.context);

    if (user != null) {
      emit(Authenticated(user: user));
    }
  }

  void _onFacebookGetMe(
    FacebookGetMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    User? user =
        await authService.getMe(event.context, FetchPolicy.networkOnly);

    if (user != null) {
      Authenticated(user: user);
    }
  }

  Future<void> _onGoogleSignInPressed(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Loading());

    final user = await authService.signInWithGoogle(event.context);

    if (user != null) {
      emit(Authenticated(user: user));
    }
  }

  void _onGoogleGetMe(
    GoogleGetMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Loading());

    final user =
        await authService.getMe(event.context, FetchPolicy.networkOnly);

    if (user != null) {
      emit(Authenticated(user: user));
    }
  }
}
