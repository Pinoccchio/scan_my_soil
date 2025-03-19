import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _profile;
  static const String _rememberMeKey = 'remember_me';
  static const String _emailKey = 'saved_email';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get profile => _profile;

  // Check if user is authenticated
  bool get isAuthenticated => _supabaseService.client.auth.currentUser != null;

  // Initialize and check auth state
  Future<bool> checkAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get current user
      final user = _supabaseService.client.auth.currentUser;

      if (user != null) {
        // Fetch user profile
        await _fetchUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user profile data
  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _supabaseService.getUserProfile();
      _profile = profile;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Sign up
  Future<bool> signUp(String email, String password, String fullName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      return response.user != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<bool> signIn(String email, String password, {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Save remember me preference
        await _saveRememberMe(rememberMe, email);

        // Fetch user profile after successful sign in
        await _fetchUserProfile();

        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signOut();

      // Clear profile data
      _profile = null;

      // Check if we should clear saved credentials
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (!rememberMe) {
        // If remember me is not enabled, clear saved email
        await prefs.remove(_emailKey);
        await prefs.remove(_rememberMeKey);
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Removed resetPassword method

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      return response.user != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save remember me preference
  Future<void> _saveRememberMe(bool rememberMe, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);

    if (rememberMe) {
      // Save email if remember me is enabled
      await prefs.setString(_emailKey, email);
    } else {
      // Clear saved email if remember me is disabled
      await prefs.remove(_emailKey);
    }
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (rememberMe) {
      return prefs.getString(_emailKey);
    }

    return null;
  }

  // Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}

