import 'package:events_app_mobile/bloc/auth/auth_cubit.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/graphql/mutations/login.dart';
import 'package:events_app_mobile/graphql/mutations/login_with_google.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/screens/home_screen.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/or_continue_with.dart';
import 'package:events_app_mobile/widgets/sign_up_button.dart';
import 'package:events_app_mobile/widgets/social_button.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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

  void onPasswordHiddenPressed() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void onForgotPasswordPressed() {}

  void onLoginPressed(RunMutation runLoginMutation) {
    if (_formKey.currentState!.validate()) {
      runLoginMutation({
        'input': {
          'email': _email,
          'password': _password,
        },
      });
    }
  }

  void onSignUpPressed() {}

  void onLoginCompleted(BuildContext context, dynamic resultData) async {
    onAfterLogin(
      context: context,
      resultData: resultData,
      fieldName: 'login',
    );
  }

  void onLoginWithGoogleCompleted(
      BuildContext context, dynamic resultData) async {
    onAfterLogin(
      context: context,
      resultData: resultData,
      fieldName: 'loginWithGoogle',
    );
  }

  void onAfterLogin({
    required BuildContext context,
    required dynamic resultData,
    required String fieldName,
  }) async {
    if (resultData?[fieldName] != null) {
      User user = User.fromMap(resultData[fieldName]);
      await SecureStorageUtils.setItem('token', user.token);

      // ignore: use_build_context_synchronously
      // BlocProvider.of<AuthCubit>(context).setCurrentUser(user);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

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

  void onLoginWithGoogle(RunMutation runLoginWithGoogleMutation) async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount?.authentication;
      final idToken = googleAuth?.idToken;

      runLoginWithGoogleMutation({
        'idToken': idToken,
      });
    } catch (error) {
      print(error.toString());
    }
  }

  void onLoginWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      print(loginResult.accessToken);
      final userInfo = await FacebookAuth.instance
          .getUserData(fields: 'first_name,last_name,email,picture.width(200)');
    } else {
      print('ResultStatus: ${loginResult.status}');
      print('Message: ${loginResult.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(loginWithGoogle),
        onCompleted: (dynamic resultData) =>
            onLoginWithGoogleCompleted(context, resultData),
        onError: onLoginError,
      ),
      builder: (RunMutation runLoginWithGoogleMutation, QueryResult? result) {
        return Mutation(
          options: MutationOptions(
            document: gql(login),
            onCompleted: (dynamic resultData) =>
                onLoginCompleted(context, resultData),
            onError: onLoginError,
          ),
          builder: (RunMutation runLoginMutation, QueryResult? result) {
            return Scaffold(
              backgroundColor: LightThemeColors.background,
              body: SafeArea(
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
                            onPressed: () => onLoginPressed(runLoginMutation),
                            text: 'Login',
                          ),
                          const OrContinueWith(),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton(
                                imgSrc: 'lib/images/google.png',
                                onPressed: () => onLoginWithGoogle(
                                    runLoginWithGoogleMutation),
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
          },
        );
      },
    );
  }
}
