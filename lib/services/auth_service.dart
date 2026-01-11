import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? "875686930856-02kdiued8c6mflgq7nn4qsqqluhscpf1.apps.googleusercontent.com"
        : null,
  );

  // --- SIGN UP (With Error Messages) ---
  Future<dynamic> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "This email is already registered.";
      } else if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      }
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // --- LOGIN (With Specific "Invalid Email or Password" logic) ---
  Future<dynamic> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // By returning the same message for both, you prevent "User Enumeration" (A security best practice)
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return "Invalid email or password.";
      }
      return e.message;
    } catch (e) {
      return "Login failed. Please try again.";
    }
  }

  // --- PASSWORD RESET ---
  Future<String> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "success";
    } catch (e) {
      return "Failed to send reset email.";
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google sign-in cancelled.";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      return "Google sign-in failed.";
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
