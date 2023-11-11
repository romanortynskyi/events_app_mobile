part of 'email_sign_in_bloc.dart';

abstract class EmailSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  User? user;
  String? errorMessage;
  EmailSignInState({this.user, this.errorMessage});
}

class UnAuthenticated extends EmailSignInState {
  UnAuthenticated({super.user, super.errorMessage});
}

class Authenticated extends EmailSignInState {
  Authenticated({super.user, super.errorMessage});
}

class Loading extends EmailSignInState {
  Loading({super.user, super.errorMessage});
}

class Error extends EmailSignInState {
  Error({super.user, super.errorMessage});
}
