import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/consts/enums/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreenController {
  void onLoginPressed({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
  }) {
    if (formKey.currentState!.validate()) {
      context.read<auth_bloc.AuthBloc>().add(auth_bloc.EmailSignInRequested(
            context: context,
            email: email,
            password: password,
          ));
    }
  }

  void onSignUpPressed(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(
      RouteName.signUp.value,
    );
  }

  void onLoginError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String? emailValidator(String? value) {
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  void onLoginWithGoogle(BuildContext context) {
    context
        .read<auth_bloc.AuthBloc>()
        .add(auth_bloc.GoogleSignInRequested(context));
  }

  void onLoginWithFacebook(BuildContext context) {
    context
        .read<auth_bloc.AuthBloc>()
        .add(auth_bloc.FacebookSignInRequested(context));
  }

  void blocListener(BuildContext context, auth_bloc.AuthState state) {
    if (state is auth_bloc.Authenticated) {
      Navigator.of(context).popUntil(ModalRoute.withName(RouteName.main.value));
    }

    if (state is auth_bloc.Error) {
      onLoginError(context, state.errorMessage ?? '');
    }
  }
}
