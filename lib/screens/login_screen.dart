import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gdoc/colors.dart';
import 'package:gdoc/repository/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void signInWithGoogle(WidgetRef ref) {
    ref.read(authRepositoryProvider).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                "GDoc",
                style: GoogleFonts.cabinSketch(
                  textStyle: const TextStyle(fontSize: 120, color: kBlackColor),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/docs-logo.png",
              height: 120,
            ),
            Expanded(
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    signInWithGoogle(ref);
                  },
                  icon: Image.asset(
                    "assets/g-logo.png",
                    height: 20,
                  ),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: kBlackColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhiteColor,
                    minimumSize: const Size(150, 50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
