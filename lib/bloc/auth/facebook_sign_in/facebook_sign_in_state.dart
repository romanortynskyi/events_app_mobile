part of 'facebook_sign_in_bloc.dart';

abstract class FacebookSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  final User? user;
  const FacebookSignInState(this.user);
}

class UnAuthenticated extends FacebookSignInState {
  const UnAuthenticated(super.user);
}

class Authenticated extends FacebookSignInState {
  const Authenticated(super.user);
}

class Loading extends FacebookSignInState {
  const Loading(super.user);
}
