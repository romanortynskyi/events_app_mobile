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
    required this.password
  });
}

class EmailSignOutRequested extends EmailSignInEvent {}
