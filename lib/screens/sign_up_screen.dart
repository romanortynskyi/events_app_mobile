// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/controllers/sign_up_screen_controller.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/or_continue_with.dart';
import 'package:events_app_mobile/widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';

  late SignUpScreenController _signUpScreenController;

  void onPasswordHiddenPressed() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void onSignUpPressed() {
    _signUpScreenController.onSignUpPressed(
      formKey: _formKey,
      context: context,
      email: _email,
      password: _password,
      firstName: _firstName,
      lastName: _lastName,
    );
  }

  void onSignUpError(BuildContext context, String message) {
    _signUpScreenController.onSignUpError(context, message);
  }

  void onEmailChanged(String value) {
    setState(() => _email = value);
  }

  void onPasswordChanged(String value) {
    setState(() => _password = value);
  }

  void onFirstNameChanged(String value) {
    setState(() => _firstName = value);
  }

  void onLastNameChanged(String value) {
    setState(() => _lastName = value);
  }

  void onLoginWithGoogle() async {
    _signUpScreenController.onLoginWithGoogle(context);
  }

  void onLoginWithFacebook() async {
    _signUpScreenController.onLoginWithFacebook(context);
  }

  @override
  void initState() {
    super.initState();

    _signUpScreenController = SignUpScreenController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<auth_bloc.AuthBloc, auth_bloc.AuthState>(
        listener: (context, state) {
      _signUpScreenController.blocListener(context, state);
    }, builder: (BuildContext context, auth_bloc.AuthState state) {
      bool isLoading = state is auth_bloc.Loading;

      return Scaffold(
        backgroundColor: LightThemeColors.background,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          const Icon(
                            Icons.lock,
                            size: 100,
                          ),
                          const SizedBox(height: 50),
                          AppTextField(
                            validator: _signUpScreenController.emailValidator,
                            hintText: 'Email',
                            obscureText: false,
                            onChanged: onEmailChanged,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            validator:
                                _signUpScreenController.passwordValidator,
                            hintText: 'Password',
                            obscureText: _isPasswordHidden,
                            onChanged: onPasswordChanged,
                            suffixIcon: IconButton(
                              onPressed: onPasswordHiddenPressed,
                              icon: Icon(_isPasswordHidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            validator:
                                _signUpScreenController.firstNameValidator,
                            hintText: 'First name',
                            obscureText: false,
                            onChanged: onFirstNameChanged,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            validator:
                                _signUpScreenController.lastNameValidator,
                            hintText: 'Last name',
                            obscureText: false,
                            onChanged: onLastNameChanged,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: AppButton(
                              onPressed: onSignUpPressed,
                              text: 'Sign up',
                            ),
                          ),
                          const OrContinueWith(),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton(
                                imgSrc: 'lib/images/google.png',
                                onPressed: onLoginWithGoogle,
                              ),
                              const SizedBox(width: 10),
                              SocialButton(
                                imgSrc: 'lib/images/facebook.png',
                                onPressed: onLoginWithFacebook,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
