import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';

part 'google_sign_in_event.dart';
part 'google_sign_in_state.dart';

class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  GoogleSignInBloc({required this.authRepository}) : super(UnAuthenticated()) {
    on<GoogleSignInRequested>(_onGoogleSignInPressed);
    on<GoogleSignOutRequested>(_onGoogleSignOutPressed);
  }
  final AuthRepository authRepository;

  Future<void> _onGoogleSignInPressed(
    GoogleSignInRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(Loading());
    final response = await authRepository.signInWithGoogle(event.context);

    if (response) {
      emit(Authenticated());
    }
  }

  void _onGoogleSignOutPressed(
    GoogleSignOutRequested event,
    Emitter<GoogleSignInState> emit,
  ) {
    authRepository.handleSignOut();
    emit(UnAuthenticated());
  }
}
