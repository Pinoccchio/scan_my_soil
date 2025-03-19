import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/soil_analysis.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';

class ScanSection extends StatefulWidget {
  const ScanSection({Key? key}) : super(key: key);

  @override
  State<ScanSection> createState() => _ScanSectionState();
}

class _ScanSectionState extends State<ScanSection> {
  File? _imageFile;
  SoilAnalysis? _analysisResult;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, String> _recommendations = {};

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Analyze the image using Gemini
      final analysis = await GeminiService.analyzeSoilImage(_imageFile!);

      setState(() {
        // We'll set the imageUrl later when saving
        _analysisResult = analysis;
        _isAnalyzing = false;

        // Store recommendations directly from the analysis
        _recommendations = {
          'suitableCrops': analysis.suitableCrops ?? '',
          'fertilizerNeeds': analysis.fertilizerNeeds ?? '',
          'soilManagement': analysis.soilManagement ?? '',
        };
      });

      // Print the analysis results for debugging
      print('Analysis results:');
      print('Soil Type: ${analysis.soilType}');
      print('Has Recommendations: ${analysis.hasRecommendations}');
      print('Suitable Crops: ${analysis.suitableCrops}');
      print('Fertilizer Needs: ${analysis.fertilizerNeeds}');
      print('Soil Management: ${analysis.soilManagement}');

    } catch (e) {
      print("Error analyzing image: $e");

      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAnalysis() async {
    if (_analysisResult == null || _imageFile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Upload image to Supabase Storage
      final imageUrl = await _supabaseService.uploadSoilImage(_imageFile!);

      // Create a new analysis with the image URL
      final analysisWithImage = SoilAnalysis(
        soilType: _analysisResult!.soilType,
        color: _analysisResult!.color,
        texture: _analysisResult!.texture,
        phLevel: _analysisResult!.phLevel,
        fragments: _analysisResult!.fragments,
        mottles: _analysisResult!.mottles,
        organicMatter: _analysisResult!.organicMatter,
        imageUrl: imageUrl,
        suitableCrops: _analysisResult!.suitableCrops,
        fertilizerNeeds: _analysisResult!.fertilizerNeeds,
        soilManagement: _analysisResult!.soilManagement,
        hasRecommendations: _analysisResult!.hasRecommendations,
      );

      // Print the analysis being saved for debugging
      print('Saving analysis with recommendations:');
      print('Has Recommendations: ${analysisWithImage.hasRecommendations}');
      print('Suitable Crops: ${analysisWithImage.suitableCrops}');
      print('Fertilizer Needs: ${analysisWithImage.fertilizerNeeds}');
      print('Soil Management: ${analysisWithImage.soilManagement}');

      // Save to Supabase Database
      await _supabaseService.saveSoilAnalysis(analysisWithImage);

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis saved to datasets'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error saving analysis: $e");

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving analysis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Soil Scanner',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Analyze your soil sample',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Image selection area
            if (_imageFile == null)
              _buildImageSelectionArea()
            else
              _buildSelectedImageArea(),

            const SizedBox(height: 16),

            // Analysis results
            if (_analysisResult != null)
              Expanded(
                child: _buildAnalysisResults(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelectionArea() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        height: 300,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_search,
              size: 80,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a soil sample image to analyze',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildOptionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImageArea() {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _imageFile!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.7),
                radius: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      _analysisResult = null;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeImage,
            icon: _isAnalyzing
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Icon(Icons.science_outlined),
            label: Text(_isAnalyzing ? 'Analyzing soil & generating recommendations...' : 'Analyze Soil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisResults() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Analysis Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildResultItem('Soil Type', _analysisResult!.soilType),
            _buildResultItem('Color', _analysisResult!.color),
            _buildResultItem('Texture', _analysisResult!.texture),
            _buildResultItem('pH Level', _analysisResult!.phLevel),
            _buildResultItem('Fragments', _analysisResult!.fragments),
            _buildResultItem('Mottles', _analysisResult!.mottles),
            _buildResultItem('Organic Matter', _analysisResult!.organicMatter),

            if (_analysisResult!.hasRecommendations) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.eco_outlined,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultItem('Suitable Crops', _analysisResult!.suitableCrops ?? ''),
              _buildResultItem('Fertilizer Needs', _analysisResult!.fertilizerNeeds ?? ''),
              _buildResultItem('Soil Management', _analysisResult!.soilManagement ?? ''),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _saveAnalysis,
                icon: _isSaving
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green.shade700,
                  ),
                )
                    : Icon(Icons.save_alt, color: Colors.green.shade700),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save to Datasets',
                  style: TextStyle(color: Colors.green.shade700),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.green.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.green.shade700,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAnalyzeButtonText() {
    if (_isAnalyzing) {
      return 'Analyzing...';
    } else {
      return 'Analyze Soil';
    }
  }
}

