import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  // Sign in with email and password
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
}