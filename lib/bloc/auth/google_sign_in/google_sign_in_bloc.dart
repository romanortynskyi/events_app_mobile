import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/services/auth_service.dart';
import 'package:flutter/widgets.dart';

part 'google_sign_in_event.dart';
part 'google_sign_in_state.dart';

class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  GoogleSignInBloc({required this.authService})
      : super(const UnAuthenticated(null)) {
    on<GoogleSignInRequested>(_onGoogleSignInPressed);
    on<GoogleSignOutRequested>(_onGoogleSignOutPressed);
    on<GoogleGetMeRequested>(_getMe);
  }
  final AuthService authService;

  Future<void> _onGoogleSignInPressed(
    GoogleSignInRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(const Loading(null));

    final user = await authService.signInWithGoogle(event.context);

    if (user != null) {
      emit(Authenticated(user));
    }
  }

  void _onGoogleSignOutPressed(
    GoogleSignOutRequested event,
    Emitter<GoogleSignInState> emit,
  ) {
    authService.signOutWithGoogle();
    emit(const UnAuthenticated(null));
  }

  void _getMe(
    GoogleGetMeRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(Loading(null));
    final user = await authService.getMe(event.context);

    if (user != null) {
      emit(Authenticated(user));
    }
  }
}
