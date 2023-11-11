import 'package:flutter/widgets.dart';

part of 'email_sign_in_bloc.dart';

abstract class EmailSignInEvent extends Equatable {
  const EmailSignInEvent();

  @override
  List<Object> get props => [];
}

class EmailSignInRequested extends EmailSignInEvent {
  final String email;
  final String password;
  final BuildContext context;

  const EmailSignInRequested({
    required this.context,
    required this.email,
    required this.password,
  });
}

class EmailSignUpRequested extends EmailSignInEvent {
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

class EmailSignOutRequested extends EmailSignInEvent {}

class EmailGetMeRequested extends EmailSignInEvent {
  final BuildContext context;

  const EmailGetMeRequested(this.context);
}

class EmailSignInErrorRequested extends EmailSignInEvent {
  final String errorMessage;

  const EmailSignInErrorRequested({ required this.errorMessage });
}
