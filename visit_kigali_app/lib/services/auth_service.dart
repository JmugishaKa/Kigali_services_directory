import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await result.user!.sendEmailVerification();

      // Create user profile in Realtime Database
      await _database.child('users').child(result.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ignore: unused_local_variable
      UserCredential resultclea = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // // Check if email is verified
      // await result.user!.reload();
      // if (!result.user!.emailVerified) {
      //   await _auth.signOut();
      //   return 'Please verify your email before logging in.';
      // }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Resend verification email
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Get user profile from Realtime Database
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DataSnapshot snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserProfile.fromRealtimeDatabase(uid, data);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}