part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];

  final User? user;
  final String? errorMessage;
  const AuthState({this.user, this.errorMessage});
}

class UnAuthenticated extends AuthState {
  const UnAuthenticated({super.user, super.errorMessage});
}

class Authenticated extends AuthState {
  const Authenticated({super.user, super.errorMessage});
}

class Loading extends AuthState {
  const Loading({super.user, super.errorMessage});
}

class Error extends AuthState {
  const Error({super.user, super.errorMessage});
}
