import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount?.authentication;
      final idToken = googleAuth?.idToken;

      return true;
    } catch (e) {
      print('An Error Occurred $e');

      return false;
    }
  }

  Future<void> handleSignOut() => GoogleSignIn().disconnect();
}
