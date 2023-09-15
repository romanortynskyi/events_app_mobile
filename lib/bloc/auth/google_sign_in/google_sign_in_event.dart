import 'package:flutter/widgets.dart';

part of 'google_sign_in_bloc.dart';

abstract class GoogleSignInEvent extends Equatable {
  const GoogleSignInEvent();

  @override
  List<Object> get props => [];
}

class GoogleSignInRequested extends GoogleSignInEvent {
  final BuildContext context;

  const GoogleSignInRequested(this.context);
}

class GoogleSignOutRequested extends GoogleSignInEvent {}
