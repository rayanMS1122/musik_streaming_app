import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final String clientId =
      '251836884122-8ujpngvd1bru72bl410nt1u0pf4o61km.apps.googleusercontent.com';
  final String redirectUri =
      'https://melodyflow-now-playing.firebaseapp.com/__/auth/handler';
  final List<String> scopes = ['openid', 'email', 'profile'];

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        // Verwende hier den bestehenden Code für Android, iOS und Web
        return await _signInWithGoogleMobile();
      } else if (Platform.isWindows) {
        return await _signInWithGoogleWindows();
      } else {
        debugPrint("Unsupported platform");
        return null;
      }
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      return null;
    }
  }

  /// Google Sign-In for Windows
  Future<User?> _signInWithGoogleWindows() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
        clientId,
        redirectUri,
        scopes: ['openid', 'email', 'profile'],
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
          tokenEndpoint: 'https://oauth2.googleapis.com/token',
        ),
      ));

      if (result == null) {
        debugPrint("Authorization canceled or failed");
        return null;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: result.idToken,
        accessToken: result.accessToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      debugPrint("Windows sign-in failed: $e");
      return null;
    }
  }

  /// Existing Google Sign-In implementation for mobile/web
  Future<User?> _signInWithGoogleMobile() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(clientId: clientId);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      debugPrint("Google sign-in canceled");
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Sign-in failed: ${e.message}");
      return null;
    }
  }

  /// Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      print("Sign-up failed: ${e.message}");
      return null;
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    // await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut(); // Sign out from Firebase
  }
}
