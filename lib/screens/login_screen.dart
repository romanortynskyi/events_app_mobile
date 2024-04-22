// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/controllers/login_screen_controler.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/or_continue_with.dart';
import 'package:events_app_mobile/widgets/sign_up_button.dart';
import 'package:events_app_mobile/widgets/social_button.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  String _email = '';
  String _password = '';

  late LoginScreenController _loginScreenController;

  void onPasswordHiddenPressed() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void onForgotPasswordPressed() {}

  void onLoginPressed() {
    _loginScreenController.onLoginPressed(
      context: context,
      formKey: _formKey,
      email: _email,
      password: _password,
    );
  }

  void onSignUpPressed() {
    _loginScreenController.onSignUpPressed(context);
  }

  void onLoginError(BuildContext context, String message) {
    _loginScreenController.onLoginError(context, message);
  }

  void onEmailChanged(String value) {
    setState(() => _email = value);
  }

  void onPasswordChanged(String value) {
    setState(() => _password = value);
  }

  void onLoginWithGoogle() async {
    _loginScreenController.onLoginWithGoogle(context);
  }

  void onLoginWithFacebook() async {
    _loginScreenController.onLoginWithFacebook(context);
  }

  @override
  void initState() {
    super.initState();

    _loginScreenController = LoginScreenController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<auth_bloc.AuthBloc, auth_bloc.AuthState>(
        listener: (BuildContext context, auth_bloc.AuthState state) {
      _loginScreenController.blocListener(context, state);
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
                            validator: _loginScreenController.emailValidator,
                            hintText: 'Email',
                            obscureText: false,
                            onChanged: onEmailChanged,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            validator: _loginScreenController.passwordValidator,
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
                          const SizedBox(height: 10),
                          TouchableOpacity(
                            onTap: onForgotPasswordPressed,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 25.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                          color: LightThemeColors.text),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: AppButton(
                              onPressed: onLoginPressed,
                              text: 'Login',
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
                          const SizedBox(height: 20),
                          SignUpButton(onPressed: onSignUpPressed),
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
