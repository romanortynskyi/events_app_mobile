part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];

  final User? user;
  final String? errorMessage;
  final int? uploadImageProgress;
  const AuthState({this.user, this.errorMessage, this.uploadImageProgress});
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

class UploadingUserImage extends AuthState {
  const UploadingUserImage({super.user, super.uploadImageProgress});
}

class Error extends AuthState {
  const Error({super.user, super.errorMessage});
}
