import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/services/auth_service.dart';
import 'package:flutter/widgets.dart';

part 'facebook_sign_in_event.dart';
part 'facebook_sign_in_state.dart';

class FacebookSignInBloc
    extends Bloc<FacebookSignInEvent, FacebookSignInState> {
  FacebookSignInBloc({required this.authService})
      : super(const UnAuthenticated(null)) {
    on<FacebookSignInRequested>(_onFacebookSignInPressed);
    on<FacebookSignOutRequested>(_onFacebookSignOutPressed);
    on<FacebookGetMeRequested>(_onGetMe);
  }
  final AuthService authService;

  Future<void> _onFacebookSignInPressed(
    FacebookSignInRequested event,
    Emitter<FacebookSignInState> emit,
  ) async {
    emit(const Loading(null));
    final user = await authService.signInWithFacebook(event.context);

    if (user != null) {
      emit(Authenticated(user));
    }
  }

  void _onFacebookSignOutPressed(
    FacebookSignOutRequested event,
    Emitter<FacebookSignInState> emit,
  ) {
    authService.signOutWithFacebook();
    emit(const UnAuthenticated(null));
  }

  void _onGetMe(
    FacebookGetMeRequested event,
    Emitter<FacebookSignInState> emit,
  ) async {
    User? user = await authService.getMe(event.context);

    if (user != null) {
      Authenticated(user);
    }
  }
}
