import 'package:events_app_mobile/bloc/auth/google_sign_in/google_sign_in_bloc.dart';
import 'package:events_app_mobile/repositories/auth_repository.dart';
import 'package:events_app_mobile/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

main() async {
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(
    'http://192.168.56.190:3000/graphql',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
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
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => GoogleSignInBloc(
          authRepository: RepositoryProvider.of(context),
        ),
        child: GraphQLProvider(
          client: client,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Events App',
            theme: ThemeData(
              useMaterial3: true,
            ),
            home: const LoginScreen(),
          ),
        ),
      ),
    );
  }
}
