import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';

part 'facebook_sign_in_event.dart';
part 'facebook_sign_in_state.dart';

class FacebookSignInBloc
    extends Bloc<FacebookSignInEvent, FacebookSignInState> {
  FacebookSignInBloc({required this.authRepository})
      : super(UnAuthenticated(null)) {
    on<FacebookSignInRequested>(_onFacebookSignInPressed);
    on<FacebookSignOutRequested>(_onFacebookSignOutPressed);
  }
  final AuthRepository authRepository;

  Future<void> _onFacebookSignInPressed(
    FacebookSignInRequested event,
    Emitter<FacebookSignInState> emit,
  ) async {
    emit(Loading(null));
    final user = await authRepository.signInWithFacebook(event.context);

    if (user != null) {
      emit(Authenticated(user));
    }
  }

  void _onFacebookSignOutPressed(
    FacebookSignOutRequested event,
    Emitter<FacebookSignInState> emit,
  ) {
    authRepository.signOutWithFacebook();
    emit(UnAuthenticated(null));
  }
}
