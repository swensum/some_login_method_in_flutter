
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  String generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Generate SHA256 hash of nonce
  String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
Future<User?> signInWithEmailPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'invalid-email':
        message = 'Invalid email address.';
        break;
      case 'user-disabled':
        message = 'This user has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Try again later.';
        break;
      case 'invalid-credential':  // ← ADD THIS CASE
        message = 'Incorrect email or password. Please try again.';
        break;
      default:
        message = 'Login failed: ${e.message}';
    }
    throw Exception(message);
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-up is not enabled.';
          break;
        default:
          message = 'Signup failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Failed to send reset email: ${e.message}';
      }
      throw Exception(message);
    }
  }
   Future<void> sendEmailVerification() async {
  User? user = _auth.currentUser;
  if (user != null) {
    if (!user.emailVerified) {
      try {
        await user.sendEmailVerification();
        print('Verification email sent successfully to ${user.email}');
      } catch (e) {
        print('Failed to send verification email: $e');
        rethrow; // Re-throw to be caught in signupUser
      }
    } else {
      print('Email already verified for ${user.email}');
    }
  } else {
    throw Exception('No user is currently signed in');
  }
}
  // Check if email is verified
bool isEmailVerified() {
  User? user = _auth.currentUser;
  return user != null && user.emailVerified;
}

// Reload user to get latest verification status
Future<void> reloadUser() async {
  User? user = _auth.currentUser;
  if (user != null) {
    await user.reload();
  }
}





//---------------------google sign in---------------------//
Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out from previous Google account
      await _googleSignIn.signOut();
      
      // Start Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user');
      }
      
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        print("✅ Google sign-in success: ${user.email}");
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign In Successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        return user;
      } else {
        throw Exception('Firebase sign-in failed');
      }
    } catch (e) {
      print("❌ Google Sign-in Error: $e");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      return null;
    }
  }


//---------------------apple sign in---------------------//

Future<User?> signInWithApple(BuildContext context) async {
  try{
    print('Starting Apple Sign-in...');
    final rawNonce = generateNonce();
    final hashedNonce = sha256Hash(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
   scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
    );
    print('Apple credentials received');
    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw Exception('No identity token received from Apple');
    }

    final credential  = OAuthProvider('apple.com').credential(
      idToken: idToken,
      rawNonce: rawNonce,
    );
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      print("✅ Apple sign-in success: ${user.email}");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Sign In Successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      return user;
    } else {
      throw Exception('Firebase sign-in failed');
    }
  } catch (e) {
    if (context.mounted) {
      String errorMessage = 'Apple Sign-in failed';

      if (e is PlatformException) {
        if (e.code == 'ERROR_CANCELED') {
          errorMessage = 'Apple Sign-in was cancelled';
        } else {
          errorMessage = 'Apple Sign-in error: ${e.message ?? e.code}';
        }
      } else {
        errorMessage = 'Apple Sign-in failed: ${e.toString().replaceAll('Exception: ', '')}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return null;
  }
}
}