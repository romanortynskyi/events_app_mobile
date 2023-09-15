part of 'email_sign_in_bloc.dart';

abstract class EmailSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  User? user;
  EmailSignInState(this.user);
}

class UnAuthenticated extends EmailSignInState {
  UnAuthenticated(super.user);
}

class Authenticated extends EmailSignInState {
  Authenticated(super.user);
}

class Loading extends EmailSignInState {
  Loading(super.user);
}
