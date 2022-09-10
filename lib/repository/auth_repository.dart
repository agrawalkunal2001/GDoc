import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider =
    Provider((ref) => AuthRepository(googleSignIn: GoogleSignIn()));

class AuthRepository {
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required GoogleSignIn
          googleSignIn}) // Named parameters cannot start with _
      : _googleSignIn = googleSignIn;

  void signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        print(user.email);
        print(user.displayName);
      }
    } catch (e) {
      print(e);
    }
  }
}
