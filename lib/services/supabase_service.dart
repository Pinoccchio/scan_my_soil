import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/soil_analysis.dart';
import 'dart:async';
import 'network_helper.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  // Storage bucket names - update these to match your Supabase buckets
  static const String _avatarsBucket = 'avatars';
  static const String _soilImagesBucket = 'soil.images'; // Updated to the correct bucket name

  // Direct connection details instead of environment variables
  static const String _supabaseUrl = 'https://wvxymmmrhnvbrxorxzyq.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2eHltbW1yaG52YnJ4b3J4enlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxMjY2OTEsImV4cCI6MjA1NzcwMjY5MX0.oj_axhKN36w87yDIUo3y1aliOVPzEaesKTCpcewPnnA';

  // Extract the host from the URL
  static String get _supabaseHost {
    final uri = Uri.parse(_supabaseUrl);
    return uri.host;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // First check if we have internet
      final hasInternet = await NetworkHelper.hasInternetConnection();
      if (!hasInternet) {
        throw Exception('No internet connection available');
      }

      // Pre-resolve the Supabase host to warm up DNS
      final hostResolved = await NetworkHelper.canResolveHost(_supabaseHost);
      if (!hostResolved) {
        debugPrint('Warning: Could not resolve Supabase host, but continuing anyway');
      }

      // Initialize with retry logic
      await _initializeWithRetry();

      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  Future<void> _initializeWithRetry({int maxAttempts = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        debugPrint('Attempting to initialize Supabase (attempt $attempts)');

        // Add a small delay before initialization to allow DNS to resolve
        await Future.delayed(Duration(milliseconds: 500 * attempts));

        // Updated initialization without persistSession parameter
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            autoRefreshToken: true,
          ),
          debug: false,
        ).timeout(const Duration(seconds: 15));

        _client = Supabase.instance.client;
        return; // Success, exit the retry loop
      } catch (e) {
        lastException = Exception('Failed to initialize Supabase: $e');
        debugPrint('Initialization attempt $attempts failed: $e');

        // Wait before retrying
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: attempts));
        }
      }
    }

    // If we get here, all attempts failed
    throw lastException ?? Exception('Failed to initialize Supabase after $maxAttempts attempts');
  }

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Ensure we have internet and can resolve the host
      final hasInternet = await NetworkHelper.hasInternetConnection();
      if (!hasInternet) {
        throw Exception('No internet connection available');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      ).timeout(const Duration(seconds: 15));

      return response;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure we have internet and can resolve the host
      final hasInternet = await NetworkHelper.hasInternetConnection();
      if (!hasInternet) {
        throw Exception('No internet connection available');
      }

      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut().timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // User profile methods
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single()
          .timeout(const Duration(seconds: 10));

      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
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
      await _client.storage.from(_avatarsBucket).upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Get the public URL of the uploaded image
      final imageUrl = _client.storage.from(_avatarsBucket).getPublicUrl(filePath);

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

  // SOIL ANALYSIS METHODS

  // Upload soil image to Supabase Storage
  Future<String> uploadSoilImage(File imageFile) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Create a unique filename for the image
      final fileExt = path.extension(imageFile.path);
      final fileName = 'soil_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'soil_images/$fileName';

      // Upload the image to Supabase Storage
      await _client.storage.from(_soilImagesBucket).upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Get the public URL of the uploaded image
      final imageUrl = _client.storage.from(_soilImagesBucket).getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading soil image: $e');
      rethrow;
    }
  }

  // Save soil analysis to Supabase Database
  Future<void> saveSoilAnalysis(SoilAnalysis analysis) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client.from('soil_analyses').insert({
        'id': analysis.id,
        'user_id': user.id,
        'soil_type': analysis.soilType,
        'color': analysis.color,
        'texture': analysis.texture,
        'ph_level': analysis.phLevel,
        'fragments': analysis.fragments,
        'mottles': analysis.mottles,
        'organic_matter': analysis.organicMatter,
        'image_url': analysis.imageUrl,
        'timestamp': analysis.timestamp.toIso8601String(),
        // Ensure recommendation fields are included
        'suitable_crops': analysis.suitableCrops,
        'fertilizer_needs': analysis.fertilizerNeeds,
        'soil_management': analysis.soilManagement,
        'has_recommendations': analysis.hasRecommendations,
      });
    } catch (e) {
      debugPrint('Error saving soil analysis: $e');
      rethrow;
    }
  }

  // Get all soil analyses from Supabase Database
  Future<List<SoilAnalysis>> getSoilAnalyses() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _client
          .from('soil_analyses')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false);

      return data.map<SoilAnalysis>((item) => SoilAnalysis.fromMap({
        'id': item['id'],
        'soilType': item['soil_type'],
        'color': item['color'],
        'texture': item['texture'],
        'phLevel': item['ph_level'],
        'fragments': item['fragments'],
        'mottles': item['mottles'],
        'organicMatter': item['organic_matter'],
        'imageUrl': item['image_url'],
        'timestamp': item['timestamp'],
        'suitableCrops': item['suitable_crops'],
        'fertilizerNeeds': item['fertilizer_needs'],
        'soilManagement': item['soil_management'],
        'hasRecommendations': item['has_recommendations'] ?? false,
      })).toList();
    } catch (e) {
      debugPrint('Error getting soil analyses: $e');
      return [];
    }
  }

  // Delete a soil analysis by id
  Future<void> deleteSoilAnalysis(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Get the analysis to find the image URL
      final analysis = await _client
          .from('soil_analyses')
          .select('image_url')
          .eq('id', id)
          .eq('user_id', user.id)
          .single();

      // Delete the image if it exists
      if (analysis != null && analysis['image_url'] != null) {
        await deleteImage(analysis['image_url']);
      }

      // Delete the analysis record
      await _client
          .from('soil_analyses')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error deleting soil analysis: $e');
      rethrow;
    }
  }

  // Delete image from Supabase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.last;
      final String bucket = uri.pathSegments[uri.pathSegments.length - 2];

      await _client
          .storage
          .from(bucket)
          .remove([filePath]);
    } catch (e) {
      debugPrint('Error deleting image: $e');
      // Don't rethrow - if image deletion fails, we still want to delete the record
    }
  }

  // Update soil analysis with recommendations
  Future<void> updateSoilAnalysisRecommendations(
      String id,
      String suitableCrops,
      String fertilizerNeeds,
      String soilManagement
      ) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.from('soil_analyses').update({
        'suitable_crops': suitableCrops,
        'fertilizer_needs': fertilizerNeeds,
        'soil_management': soilManagement,
        'has_recommendations': true,
      }).eq('id', id).eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error updating soil analysis recommendations: $e');
      rethrow;
    }
  }
}
