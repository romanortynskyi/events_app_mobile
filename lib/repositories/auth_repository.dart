// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/consts/enums/auth_provider.dart';
import 'package:events_app_mobile/graphql/mutations/login.dart';
import 'package:events_app_mobile/graphql/mutations/login_with_google.dart';
import 'package:events_app_mobile/graphql/mutations/login_with_facebook.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
import 'package:events_app_mobile/graphql/queries/get_me.dart' as get_me;
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthRepository {
  Future<User?> signInWithGoogle(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleSignInAccount?.authentication;
    final idToken = googleAuth?.idToken;

    try {
      final QueryResult signInResult =
          await GraphQLProvider.of(context).value.query(
                QueryOptions(document: gql(loginWithGoogle), variables: {
                  'idToken': idToken,
                }),
              );

      var data = signInResult.data ?? {};
      final user = User.fromMap(data['loginWithGoogle'] ?? {});

      await SecureStorageUtils.setItem('token', user.token);
      await SecureStorageUtils.setItem('provider', AuthProvider.google.value);

      return user;
    } catch (e) {
      print('An Error Occurred $e');

      return null;
    }
  }

  Future<void> signOutWithGoogle() async {
    GoogleSignIn().disconnect();
    await SecureStorageUtils.setItem('token', null);
    await SecureStorageUtils.setItem('provider', AuthProvider.facebook.value);
  }

  Future<User?> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        AccessToken? accessToken = loginResult.accessToken;

        final QueryResult signInResult =
            await GraphQLProvider.of(context).value.query(
                  QueryOptions(document: gql(loginWithFacebook), variables: {
                    'accessToken': accessToken?.token,
                  }),
                );

        var data = signInResult.data ?? {};
        final user = User.fromMap(data['loginWithFacebook'] ?? {});

        await SecureStorageUtils.setItem('token', user.token);

        return user;
      } else {
        print('ResultStatus: ${loginResult.status}');
        print('Message: ${loginResult.message}');

        return null;
      }
    } catch (e) {
      print('An Error Occurred $e');

      return null;
    }
  }

  Future<void> signOutWithFacebook() async {}

  Future<User?> signIn(
      {required BuildContext context,
      required String email,
      required String password}) async {
    final QueryResult getMeResult =
        await GraphQLProvider.of(context).value.mutate(
              MutationOptions(document: gql(login)),
            );

    var data = getMeResult.data ?? {};
    final user = User.fromMap(data['login'] ?? {});

    return user;
  }

  Future<void> signOut() async {}

  Future<User?> getMe(BuildContext context) async {
    final QueryResult getMeResult =
        await GraphQLProvider.of(context).value.query(
              QueryOptions(document: gql(get_me.getMe)),
            );

    var data = getMeResult.data ?? {};
    final user = User.fromMap(data['getMe'] ?? {});

    return user;
  }
}
