import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  // Check if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      // First check connectivity status
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Then verify actual internet connection by trying to reach a reliable host
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get a user-friendly error message based on the exception
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      if (error.message.contains('Failed host lookup') ||
          error.message.contains('No address associated with hostname')) {
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      }
      return 'Network error: ${error.message}. Please check your connection and try again.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. Please try again later.';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }

  // Try to pre-resolve a hostname to warm up DNS cache
  static Future<bool> preResolveHost(String host) async {
    try {
      debugPrint('Pre-resolving host: $host');
      final addresses = await InternetAddress.lookup(host);
      debugPrint('Successfully resolved $host: ${addresses.map((a) => a.address).join(', ')}');
      return addresses.isNotEmpty;
    } catch (e) {
      debugPrint('Failed to pre-resolve $host: $e');
      return false;
    }
  }
}
