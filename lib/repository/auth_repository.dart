import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gdoc/constants.dart';
import 'package:gdoc/models/error_model.dart';
import 'package:gdoc/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider(
    (ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client()));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client}) // Named parameters cannot start with _
      : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error occurred!", data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
            // user without uid and token
            name: user.displayName ?? "",
            email: user.email,
            profilePic: user.photoUrl ?? "",
            uid: "",
            token: "");

        var res = await _client.post(Uri.parse("$host/api/signup"),
            body: userAcc.toJson(),
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            }); // Mongo db assigns id to user

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)["user"][
                  "_id"], // copying userAcc to newUser and assigning uid brught in from Mongo db via res.
            );
            error = ErrorModel(error: null, data: newUser);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
