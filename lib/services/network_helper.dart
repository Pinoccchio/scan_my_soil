import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  // Cache for resolved addresses
  static final Map<String, List<InternetAddress>> _dnsCache = {};

  /// Check if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      // First check connectivity status
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Try multiple reliable hosts
      final hosts = [
        'google.com',
        'cloudflare.com',
        'apple.com',
        'microsoft.com'
      ];

      for (final host in hosts) {
        try {
          final result = await InternetAddress.lookup(host)
              .timeout(const Duration(seconds: 3));

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (_) {
          // Try the next host
          continue;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Try to resolve a hostname with multiple attempts
  static Future<bool> canResolveHost(String host, {int attempts = 3}) async {
    for (int i = 0; i < attempts; i++) {
      try {
        // Check cache first
        if (_dnsCache.containsKey(host) && _dnsCache[host]!.isNotEmpty) {
          return true;
        }

        // Try to resolve the hostname
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 5));

        if (result.isNotEmpty) {
          // Cache the result
          _dnsCache[host] = result;
          debugPrint('Successfully resolved $host on attempt ${i + 1}');
          return true;
        }
      } catch (e) {
        debugPrint('Failed to resolve $host on attempt ${i + 1}: $e');
        // Wait before retrying
        if (i < attempts - 1) {
          await Future.delayed(Duration(seconds: 1 * (i + 1)));
        }
      }
    }

    debugPrint('Failed to resolve $host after $attempts attempts');
    return false;
  }

  /// Get cached IP addresses for a host or resolve if not cached
  static Future<List<InternetAddress>> getHostAddresses(String host) async {
    // Check cache first
    if (_dnsCache.containsKey(host) && _dnsCache[host]!.isNotEmpty) {
      return _dnsCache[host]!;
    }

    try {
      final addresses = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));

      if (addresses.isNotEmpty) {
        _dnsCache[host] = addresses;
        return addresses;
      }
    } catch (e) {
      debugPrint('Failed to resolve $host: $e');
    }

    throw SocketException('Failed to resolve host: $host');
  }

  /// Clear the DNS cache
  static void clearDnsCache() {
    _dnsCache.clear();
  }

  /// Get a user-friendly error message based on the exception
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      if (error.message.contains('Failed host lookup')) {
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      }
      return 'Network error: ${error.message}. Please check your connection and try again.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. Please try again later.';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }
}
