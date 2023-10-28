import 'package:events_app_mobile/bloc/auth/email_sign_in/email_sign_in_bloc.dart';
import 'package:events_app_mobile/bloc/auth/facebook_sign_in/facebook_sign_in_bloc.dart';
import 'package:events_app_mobile/bloc/auth/google_sign_in/google_sign_in_bloc.dart';
import 'package:events_app_mobile/repositories/auth_repository.dart';
import 'package:events_app_mobile/screens/login_screen.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

main() async {
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(
    'http://192.168.56.190:3000/graphql',
    defaultHeaders: {
      'apollo-require-preflight': 'true',
    },
  );

  final AuthLink authLink = AuthLink(getToken: () async {
    String? token = await SecureStorageUtils.getItem('token');

    return 'Bearer $token';
  });

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: authLink.concat(httpLink),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(MyApp(client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  const MyApp(this.client, {super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<EmailSignInBloc>(
            create: (context) {
              return EmailSignInBloc(
                authRepository: AuthRepository(),
              );
            },
          ),
          BlocProvider<GoogleSignInBloc>(
            create: (context) {
              return GoogleSignInBloc(
                authRepository: AuthRepository(),
              );
            },
          ),
          BlocProvider<FacebookSignInBloc>(
            create: (context) {
              return FacebookSignInBloc(
                authRepository: AuthRepository(),
              );
            },
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Events App',
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
