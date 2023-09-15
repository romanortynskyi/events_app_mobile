import 'package:events_app_mobile/bloc/auth/google_sign_in_bloc.dart';
import 'package:events_app_mobile/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleSignInView extends StatelessWidget {
  const GoogleSignInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In With Google'),
      ),
      body: const ShowSignInButton(),
    );
  }
}

class ShowSignInButton extends StatelessWidget {
  const ShowSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoogleSignInBloc, GoogleSignInState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.push<Type>(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: BlocBuilder<GoogleSignInBloc, GoogleSignInState>(
        builder: (context, state) {
          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context
                      .read<GoogleSignInBloc>()
                      .add(GoogleSignInRequested(context));
                },
                child: const Text('Sign In With Google'),
              ),
            ],
          );
        },
      ),
    );
  }
}
