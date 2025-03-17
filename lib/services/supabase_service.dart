import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL',
          defaultValue: 'https://wvxymmmrhnvbrxorxzyq.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2eHltbW1yaG52YnJ4b3J4enlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxMjY2OTEsImV4cCI6MjA1NzcwMjY5MX0.oj_axhKN36w87yDIUo3y1aliOVPzEaesKTCpcewPnnA'),
    );

    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    // We don't need to manually create a profile record anymore
    // The database trigger we defined in our SQL script will handle this

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // User profile methods
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? bio,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _client
        .from('profiles')
        .update(updates)
        .eq('id', user.id);
  }

  // Profile image methods
  Future<String?> uploadProfileImage(File imageFile) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      // Create a unique filename for the image
      final fileExt = path.extension(imageFile.path);
      final fileName = '${user.id}${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'profile_images/$fileName';

      // Upload the image to Supabase Storage
      await _client.storage.from('avatars').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Get the public URL of the uploaded image
      final imageUrl = _client.storage.from('avatars').getPublicUrl(filePath);

      // Update the user's profile with the new image URL
      await _client
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Soil data methods
  Future<List<Map<String, dynamic>>> getSoilDatasets() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('soil_datasets')
        .select('*, soil_nutrients(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createSoilDataset({
    required String name,
    required String location,
    required Map<String, dynamic> nutrients,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Create the dataset
    final datasetResponse = await _client
        .from('soil_datasets')
        .insert({
      'user_id': user.id,
      'name': name,
      'location': location,
      'created_at': DateTime.now().toIso8601String(),
    })
        .select()
        .single();

    // Add nutrients data
    final datasetId = datasetResponse['id'];
    await _client.from('soil_nutrients').insert({
      'dataset_id': datasetId,
      'nitrogen': nutrients['N'],
      'phosphorus': nutrients['P'],
      'potassium': nutrients['K'],
      'ph': nutrients['pH'],
      'moisture': nutrients['moisture'],
    });

    // Return the complete dataset with nutrients
    final completeDataset = await _client
        .from('soil_datasets')
        .select('*, soil_nutrients(*)')
        .eq('id', datasetId)
        .single();

    return completeDataset;
  }

  Future<void> deleteSoilDataset(int datasetId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Delete the dataset (cascade delete should handle nutrients)
    await _client
        .from('soil_datasets')
        .delete()
        .eq('id', datasetId)
        .eq('user_id', user.id);
  }
}