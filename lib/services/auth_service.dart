// ignore_for_file: use_build_context_synchronously, constant_pattern_never_matches_value_type

import 'dart:io';

import 'package:events_app_mobile/consts/enums/auth_provider.dart';
import 'package:events_app_mobile/consts/enums/error_message.dart';
import 'package:events_app_mobile/exceptions/wrong_email_or_password_exception.dart';
import 'package:events_app_mobile/graphql/global/mutations/login.dart';
import 'package:events_app_mobile/graphql/global/mutations/sign_up.dart'
    as sign_up;
import 'package:events_app_mobile/graphql/global/mutations/login_with_google.dart';
import 'package:events_app_mobile/graphql/global/mutations/login_with_facebook.dart';
import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/utils/multipart_file_utils.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
import 'package:events_app_mobile/graphql/queries/get_me.dart' as get_me;
import 'package:events_app_mobile/graphql/profile_screen/mutations/update_user_image.dart'
    as update_user_image;
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';

class AuthService {
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
      final user = User.create().fromMap(data['loginWithGoogle'] ?? {});

      await SecureStorageUtils.setItem('token', user.token);
      await SecureStorageUtils.setItem('provider', AuthProvider.google.value);

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOutWithGoogle() async {
    GoogleSignIn().disconnect();

    await SecureStorageUtils.setItem('token', null);
    await SecureStorageUtils.setItem('provider', null);
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
        final user = User.create().fromMap(data['loginWithFacebook'] ?? {});

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
    final QueryResult loginResult =
        await GraphQLProvider.of(context).value.mutate(
              MutationOptions(document: gql(login), variables: {
                'input': {
                  'email': email,
                  'password': password,
                },
              }),
            );

    String? message = loginResult.exception?.graphqlErrors[0].message;

    if (message == ErrorMessage.wrongEmailOrPassword.value) {
      throw WrongEmailOrPasswordException(context);
    }

    var data = loginResult.data ?? {};
    final user = User.create().fromMap(data['login'] ?? {});

    await SecureStorageUtils.setItem('token', user.token);
    await SecureStorageUtils.setItem('provider', AuthProvider.email.value);

    return user;
  }

  Future<User?> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final QueryResult signUpResult =
        await GraphQLProvider.of(context).value.mutate(
              MutationOptions(document: gql(sign_up.signUp), variables: {
                'input': {
                  'email': email,
                  'password': password,
                  'firstName': firstName,
                  'lastName': lastName,
                },
              }),
            );

    String? message = signUpResult.exception?.graphqlErrors[0].message;

    if (message == ErrorMessage.emailAlreadyExists.value) {
      throw WrongEmailOrPasswordException(context);
    }

    var data = signUpResult.data ?? {};
    final user = User.create().fromMap(data['signUp'] ?? {});

    await SecureStorageUtils.setItem('token', user.token);
    await SecureStorageUtils.setItem('provider', AuthProvider.email.value);

    return user;
  }

  Future<void> signOut() async {
    String providerStr = await SecureStorageUtils.getItem('provider');

    AuthProvider provider = AuthProvider.values
        .firstWhere((e) => e.toString() == 'AuthProvider.$providerStr');

    switch (provider) {
      case AuthProvider.email:
        await SecureStorageUtils.setItem('token', null);
        await SecureStorageUtils.setItem('provider', null);

        break;

      case AuthProvider.google:
        await signOutWithGoogle();

        break;

      default:
        await signOutWithFacebook();

        break;
    }
  }

  Future<User?> getMe(BuildContext context, FetchPolicy fetchPolicy) async {
    GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryResult getMeResult = await client.query(
      QueryOptions(
        document: gql(get_me.getMe),
        fetchPolicy: fetchPolicy,
      ),
    );

    var data = getMeResult.data;

    if (data != null) {
      final user = User.create().fromMap(data['getMe']);

      return user;
    }

    return null;
  }

  Future<Asset> updateUserImage({
    required BuildContext context,
    required File file,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;

    MultipartFile multipartFile =
        MultipartFileUtils.getMultipartFile(file, 'image');

    final QueryResult updateUserImageResult = await client.mutate(
      MutationOptions(
        document: gql(update_user_image.updateUserImage),
        variables: {
          'input': {
            'image': multipartFile,
          },
        },
        fetchPolicy: fetchPolicy,
      ),
    );

    var data = updateUserImageResult.data ?? {};

    final asset = Asset().fromMap(data['updateUserImage'] ?? {});

    return asset;
  }
}
