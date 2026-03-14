import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  // Load user profile from Firebase Database
  Future<void> _loadUserProfile(String uid) async {
    _userProfile = await _authService.getUserProfile(uid);
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? error = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );

    _isLoading = false;
    _error = error;
    notifyListeners();

    return error == null;
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? error = await _authService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;
    _error = error;
    notifyListeners();

    return error == null;
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    return await _authService.isEmailVerified();
  }

  // Resend verification email
  Future<void> resendVerification() async {
    await _authService.sendVerificationEmail();
  }
}