import 'package:flutter/material.dart';
import 'dart:async';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  bool _hasScanned = false;
  Timer? _scanTimer;

  void _startScan() {
    setState(() {
      _isScanning = true;
    });

    // Simulate scanning process
    _scanTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isScanning = false;
        _hasScanned = true;
      });
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Soil Sample'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Camera preview placeholder
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isScanning
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing soil...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
                  : Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            Text(
              'Instructions:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Place your soil sample on a clean, well-lit surface\n'
                  '2. Hold your camera 15-20cm above the sample\n'
                  '3. Ensure the entire sample is visible in the frame\n'
                  '4. Press the scan button to analyze',
              style: TextStyle(fontSize: 16),
            ),

            const Spacer(),

            // Scan button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _hasScanned
                  ? ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/results');
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              )
                  : ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScan,
                icon: const Icon(Icons.camera),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}