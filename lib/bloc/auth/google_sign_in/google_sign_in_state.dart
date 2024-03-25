part of 'google_sign_in_bloc.dart';

abstract class GoogleSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  final User? user;
  const GoogleSignInState(this.user);
}

class UnAuthenticated extends GoogleSignInState {
  const UnAuthenticated(super.user);
}

class Authenticated extends GoogleSignInState {
  const Authenticated(super.user);
}

class Loading extends GoogleSignInState {
  const Loading(super.user);
}
