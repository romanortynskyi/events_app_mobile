import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

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

class GoogleGetMeRequested extends GoogleSignInEvent {
  final BuildContext context;

  const GoogleGetMeRequested(this.context);
}
