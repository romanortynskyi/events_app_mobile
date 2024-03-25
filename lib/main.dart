import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart';
import 'package:events_app_mobile/bloc/auth/auth_bloc.dart';
import 'package:events_app_mobile/services/auth_service.dart';
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
  final AuthService authService = AuthService();

  MyApp(this.client, {super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              return AuthBloc(
                authService: authService,
              );
            },
          ),
          BlocProvider<AddEventBloc>(
            create: (context) {
              return AddEventBloc();
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
