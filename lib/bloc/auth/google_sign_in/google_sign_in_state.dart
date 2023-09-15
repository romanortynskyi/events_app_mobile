part of 'google_sign_in_bloc.dart';

abstract class GoogleSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  User? user;
  GoogleSignInState(this.user);
}

class UnAuthenticated extends GoogleSignInState {
  UnAuthenticated(super.user);
}

class Authenticated extends GoogleSignInState {
  Authenticated(super.user);
}

class Loading extends GoogleSignInState {
  Loading(super.user);
}
