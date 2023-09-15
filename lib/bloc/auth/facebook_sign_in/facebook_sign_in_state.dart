part of 'facebook_sign_in_bloc.dart';

abstract class FacebookSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  User? user;
  FacebookSignInState(this.user);
}

class UnAuthenticated extends FacebookSignInState {
  UnAuthenticated(super.user);
}

class Authenticated extends FacebookSignInState {
  Authenticated(super.user);
}

class Loading extends FacebookSignInState {
  Loading(super.user);
}
