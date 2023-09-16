import 'package:flutter/widgets.dart';

part of 'facebook_sign_in_bloc.dart';

abstract class FacebookSignInEvent extends Equatable {
  const FacebookSignInEvent();

  @override
  List<Object> get props => [];
}

class FacebookSignInRequested extends FacebookSignInEvent {
  final BuildContext context;

  const FacebookSignInRequested(this.context);
}

class FacebookSignOutRequested extends FacebookSignInEvent {}

class FacebookGetMeRequested extends FacebookSignInEvent {
  final BuildContext context;

  const FacebookGetMeRequested(this.context);
}
