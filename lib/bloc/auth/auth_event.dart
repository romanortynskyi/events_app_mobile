import 'package:flutter/widgets.dart';

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  const EmailSignInRequested({
    required this.context,
    required this.email,
    required this.password,
  });
}

class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final BuildContext context;

  const EmailSignUpRequested({
    required this.context,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });
}

class EmailSignInErrorRequested extends AuthEvent {
  final String errorMessage;

  const EmailSignInErrorRequested({ required this.errorMessage });
}

class FacebookSignInRequested extends AuthEvent {
  final BuildContext context;

  const FacebookSignInRequested(this.context);
}

class GoogleSignInRequested extends AuthEvent {
  final BuildContext context;

  const GoogleSignInRequested(this.context);
}

class GetMeRequested extends AuthEvent {
  final BuildContext context;

  const GetMeRequested(this.context);
}

class SignOutRequested extends AuthEvent {}

class UpdateUserImageRequested extends AuthEvent {
  final BuildContext context;
  final File file;

  const UpdateUserImageRequested(this.context, this.file);
}

class UpdateUserImageProgressRequested extends AuthEvent {
  final UploadUserImageProgress progress;

  const UpdateUserImageProgressRequested(this.progress);
}

class UpdateUserImageEndRequested extends AuthEvent {
  final String imgSrc;

  const UpdateUserImageEndRequested(this.imgSrc);
}
