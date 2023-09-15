// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/bloc/auth/email_sign_in/email_sign_in_bloc.dart'
    as email_sign_in_bloc;
import 'package:events_app_mobile/bloc/auth/google_sign_in/google_sign_in_bloc.dart'
    as google_sign_in_bloc;
import 'package:events_app_mobile/bloc/auth/facebook_sign_in/facebook_sign_in_bloc.dart'
    as facebook_sign_in_bloc;
import 'package:events_app_mobile/consts/enums/auth_provider.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/screens/main_screen.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
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

  @override
  void initState() {
    super.initState();

    onInit();
  }

  Future<void> onInit() async {
    String? providerStr = await SecureStorageUtils.getItem('provider');

    if (providerStr != null) {
      AuthProvider authProvider = AuthProvider.values.byName(providerStr);

      switch (authProvider) {
        case AuthProvider.google:
          context
              .read<google_sign_in_bloc.GoogleSignInBloc>()
              .add(google_sign_in_bloc.GoogleGetMeRequested(context));
          break;

        case AuthProvider.facebook:
          break;

        default:
          break;
      }
    }
  }

  void onPasswordHiddenPressed() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void onForgotPasswordPressed() {}

  void onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context
          .read<email_sign_in_bloc.EmailSignInBloc>()
          .add(email_sign_in_bloc.EmailSignInRequested(
            context: context,
            email: _email,
            password: _password,
          ));
    }
  }

  void onSignUpPressed() {}

  void onLoginError(dynamic errorData) {
    String message = errorData.graphqlErrors[0].message;
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

  void onEmailChanged(String value) {
    setState(() => _email = value);
  }

  void onPasswordChanged(String value) {
    setState(() => _password = value);
  }

  void onLoginWithGoogle() async {
    context
        .read<google_sign_in_bloc.GoogleSignInBloc>()
        .add(google_sign_in_bloc.GoogleSignInRequested(context));
  }

  void onLoginWithFacebook() async {
    context
        .read<facebook_sign_in_bloc.FacebookSignInBloc>()
        .add(facebook_sign_in_bloc.FacebookSignInRequested(context));
  }

  @override
  Widget build(BuildContext context) {
    var googleSignInState = context.select(
        (google_sign_in_bloc.GoogleSignInBloc googleSignInBloc) =>
            googleSignInBloc.state);
    var facebookSignInState = context.select(
        (facebook_sign_in_bloc.FacebookSignInBloc facebookSignInBloc) =>
            facebookSignInBloc.state);
    var emailSignInState = context.select(
        (email_sign_in_bloc.EmailSignInBloc emailSignInBloc) =>
            emailSignInBloc.state);

    return MultiBlocListener(
      listeners: [
        BlocListener<google_sign_in_bloc.GoogleSignInBloc,
            google_sign_in_bloc.GoogleSignInState>(
          listener: (context, state) {
            if (state is google_sign_in_bloc.Authenticated) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            }
          },
        ),
        BlocListener<facebook_sign_in_bloc.FacebookSignInBloc,
            facebook_sign_in_bloc.FacebookSignInState>(
          listener: (context, state) {
            if (state is facebook_sign_in_bloc.Authenticated) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: LightThemeColors.background,
        body: emailSignInState is email_sign_in_bloc.Loading ||
                googleSignInState is google_sign_in_bloc.Loading ||
                facebookSignInState is facebook_sign_in_bloc.Loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    // heightFactor: 1.3,
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
                            validator: emailValidator,
                            hintText: 'Email',
                            obscureText: false,
                            onChanged: onEmailChanged,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            validator: passwordValidator,
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
                          AppButton(
                            onPressed: onLoginPressed,
                            text: 'Login',
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
      ),
    );
  }
}
