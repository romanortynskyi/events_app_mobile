import 'package:events_app_mobile/bloc/auth/email_sign_in/email_sign_in_bloc.dart';
import 'package:events_app_mobile/bloc/auth/facebook_sign_in/facebook_sign_in_bloc.dart';
import 'package:events_app_mobile/bloc/auth/google_sign_in/google_sign_in_bloc.dart';
import 'package:events_app_mobile/repositories/auth_repository.dart';
import 'package:events_app_mobile/screens/login_screen.dart';
import 'package:events_app_mobile/utils/env_utils.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

main() async {
  await dotenv.load(fileName: '.env');

  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(
    EnvUtils.getEnv('API_URL'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
