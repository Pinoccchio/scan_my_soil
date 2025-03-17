import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();

  User? _user;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> checkAuthState() async {
    try {
      _user = _supabaseService.client.auth.currentUser;

      if (_user != null) {
        await _fetchUserProfile();
      }

      return isAuthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;

      if (_user != null) {
        await _fetchUserProfile();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Failed to sign in: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      _user = response.user;

      if (_user != null) {
        await _fetchUserProfile();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Failed to sign up: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _user = null;
      _profile = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      _errorMessage = 'Failed to reset password: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      _profile = await _supabaseService.getUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to fetch profile: ${e.toString()}';
    }
  }

  Future<void> updateProfile({String? fullName, String? bio}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.updateUserProfile(
        fullName: fullName,
        bio: bio,
      );

      await _fetchUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}