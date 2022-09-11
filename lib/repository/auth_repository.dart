import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gdoc/constants.dart';
import 'package:gdoc/models/error_model.dart';
import 'package:gdoc/models/user_model.dart';
import 'package:gdoc/repository/local_storage_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageRepository
          localStorageRepository}) // Named parameters cannot start with _
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

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
              token: jsonDecode(res.body)["token"],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error occurred!", data: null);
    try {
      String? token = await _localStorageRepository.getToken();
      if (token != null) {
        var res = await _client.get(Uri.parse("$host/"), headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token,
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonEncode(jsonDecode(res.body)["user"]),
            ).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
