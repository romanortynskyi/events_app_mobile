import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/consts/enums/route_name.dart';
import 'package:events_app_mobile/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreenController {
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

  String? firstNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }

    return null;
  }

  String? lastNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
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

  void onSignUpPressed({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    if (formKey.currentState!.validate()) {
      context.read<auth_bloc.AuthBloc>().add(auth_bloc.EmailSignUpRequested(
            context: context,
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ));
    }
  }

  void onSignUpError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void blocListener(BuildContext context, auth_bloc.AuthState state) {
    if (state is auth_bloc.Authenticated) {
      Navigator.of(context).popUntil(ModalRoute.withName(RouteName.main.value));
    }

    if (state is auth_bloc.Error) {
      onSignUpError(context, state.errorMessage ?? '');
    }
  }
}
