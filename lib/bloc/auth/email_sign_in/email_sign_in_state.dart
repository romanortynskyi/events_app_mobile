part of 'email_sign_in_bloc.dart';

abstract class EmailSignInState extends Equatable {
  @override
  List<Object?> get props => [];

  final User? user;
  final String? errorMessage;
  const EmailSignInState({this.user, this.errorMessage});
}

class UnAuthenticated extends EmailSignInState {
  const UnAuthenticated({super.user, super.errorMessage});
}

class Authenticated extends EmailSignInState {
  const Authenticated({super.user, super.errorMessage});
}

class Loading extends EmailSignInState {
  const Loading({super.user, super.errorMessage});
}

class Error extends EmailSignInState {
  const Error({super.user, super.errorMessage});
}
