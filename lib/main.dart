import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart';
import 'package:events_app_mobile/bloc/auth/auth_bloc.dart';
import 'package:events_app_mobile/consts/enums/route_name.dart';
import 'package:events_app_mobile/links/custom_link.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/screens/login_screen.dart';
import 'package:events_app_mobile/screens/main_screen.dart';
import 'package:events_app_mobile/screens/profile_screen.dart';
import 'package:events_app_mobile/screens/sign_up_screen.dart';
import 'package:events_app_mobile/services/auth_service.dart';
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

    if (token == null) {
      return null;
    }

    return 'Bearer $token';
  });

  final customLink = CustomLink(getHeaders: () async {
    return {
      'Accept-Language': 'en',
    };
  });

  final link = Link.from([
    customLink,
    httpLink,
  ]);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: authLink.concat(link),
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
            initialRoute: '/',
            routes: {
              RouteName.main.value: (context) => const MainScreen(),
              RouteName.login.value: (context) => const LoginScreen(),
              RouteName.signUp.value: (context) => const SignUpScreen(),
              RouteName.profile.value: (context) => const ProfileScreen(),
              RouteName.event.value: (context) => EventScreen(
                  ModalRoute.of(context)?.settings.arguments
                      as EventScreenArguments),
            }),
      ),
    );
  }
}
