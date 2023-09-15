import 'package:events_app_mobile/bloc/auth/email_sign_in/email_sign_in_bloc.dart'
    as email_sign_in_bloc;
import 'package:events_app_mobile/bloc/auth/google_sign_in/google_sign_in_bloc.dart'
    as google_sign_in_bloc;
import 'package:events_app_mobile/bloc/auth/facebook_sign_in/facebook_sign_in_bloc.dart'
    as facebook_sign_in_bloc;
import 'package:events_app_mobile/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

    User? user = googleSignInState.user ??
        facebookSignInState.user ??
        emailSignInState.user;

    return MultiBlocListener(listeners: [
      BlocListener<google_sign_in_bloc.GoogleSignInBloc,
          google_sign_in_bloc.GoogleSignInState>(
        listener: (context, state) {},
      ),
      BlocListener<facebook_sign_in_bloc.FacebookSignInBloc,
          facebook_sign_in_bloc.FacebookSignInState>(
        listener: (context, state) {},
      ),
    ], child: Text(user?.firstName ?? 'user first name'));
  }
}
