// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/upload_user_image_progress.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/services/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dart_numerics/dart_numerics.dart' as numerics;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService})
      : super(const UnAuthenticated(user: null)) {
    on<EmailSignInRequested>(_onEmailSignInRequested);
    on<EmailSignUpRequested>(_onEmailSignUpRequested);
    on<EmailSignInErrorRequested>(_onEmailSignInError);

    on<FacebookSignInRequested>(_onFacebookSignInRequested);

    on<GoogleSignInRequested>(_onGoogleSignInPressed);

    on<GetMeRequested>(_onGetMeRequested);
    on<SignOutRequested>(_onSignOutRequested);

    on<UpdateUserImageRequested>(_onUpdateUserImageRequested);
    on<UpdateUserImageProgressRequested>(_onUploadUserImageProgressRequested);
    on<UpdateUserImageEndRequested>(_onUpdateUserImageEndRequested);
  }
  final AuthService authService;

  Future<void> _onEmailSignInRequested(
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

  void _onEmailSignUpRequested(
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

  void _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authService.signOut();

    emit(const UnAuthenticated(user: null));
  }

  void _onGetMeRequested(
    GetMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    User? user =
        await authService.getMe(event.context, FetchPolicy.networkOnly);

    if (user != null) {
      Authenticated(user: user);
    }
  }

  Future<void> _onFacebookSignInRequested(
    FacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Loading());

    final user = await authService.signInWithFacebook(event.context);

    if (user != null) {
      emit(Authenticated(user: user));
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

  Future<void> _onUpdateUserImageRequested(
    UpdateUserImageRequested event,
    Emitter<AuthState> emit,
  ) async {
    UploadUserImageProgress progress = UploadUserImageProgress(
      loaded: 0,
      total: numerics.int64MaxValue,
    );

    emit(UploadingUserImage(user: state.user, uploadImageProgress: progress));

    await authService.updateUserImage(
      context: event.context,
      file: event.file,
    );
  }

  void _onUploadUserImageProgressRequested(
    UpdateUserImageProgressRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(UploadingUserImage(
      user: state.user,
      uploadImageProgress: event.progress,
    ));
  }

  void _onUpdateUserImageEndRequested(
    UpdateUserImageEndRequested event,
    Emitter<AuthState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    User updatedUser = state.user!.copyWith(image: Asset(src: event.imgSrc));

    emit(Authenticated(user: updatedUser));
  }
}
