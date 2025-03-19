import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/soil_analysis.dart';
import '../services/supabase_service.dart';
import '../screens/analysis_detail_screen.dart';

class DatasetsSection extends StatefulWidget {
  final VoidCallback? onScanButtonPressed;

  const DatasetsSection({
    super.key,
    this.onScanButtonPressed,
  });

  @override
  State<DatasetsSection> createState() => _DatasetsSectionState();
}

class _DatasetsSectionState extends State<DatasetsSection> {
  List<SoilAnalysis> _analyses = [];
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadAnalyses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final analyses = await _supabaseService.getSoilAnalyses();

      if (!mounted) return;

      setState(() {
        _analyses = analyses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading analyses: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(SoilAnalysis analysis) async {
    if (!mounted) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Analysis'),
          content: const Text('Are you sure you want to delete this soil analysis? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeleteAnalysis(analysis);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteAnalysis(SoilAnalysis analysis) async {
    try {
      await _supabaseService.deleteSoilAnalysis(analysis.id);

      if (!mounted) return;

      setState(() {
        _analyses.removeWhere((a) => a.id == analysis.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete analysis: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
              'Datasets',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your soil analysis history',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Analysis list
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _analyses.isEmpty
                  ? _buildEmptyState()
                  : _buildAnalysisList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          const Text('Loading your datasets...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No soil analyses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a soil sample to get started',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.onScanButtonPressed,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Soil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisList() {
    return RefreshIndicator(
      onRefresh: _loadAnalyses,
      color: Colors.green.shade600,
      child: ListView.builder(
        itemCount: _analyses.length,
        itemBuilder: (context, index) {
          final analysis = _analyses[index];
          return _buildAnalysisCard(analysis);
        },
      ),
    );
  }

  Widget _buildAnalysisCard(SoilAnalysis analysis) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisDetailScreen(analysis: analysis),
            ),
          ).then((_) {
            if (mounted) {
              _loadAnalyses();
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (analysis.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: analysis.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(analysis.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmationDialog(analysis),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: 'Delete analysis',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.soilType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Replace Row with Wrap for better responsiveness
                  Wrap(
                    spacing: 8, // horizontal space between chips
                    runSpacing: 8, // vertical space between lines
                    children: [
                      _buildPropertyChip('pH: ${analysis.phLevel}'),
                      _buildPropertyChip(analysis.texture),
                      // Add a chip to indicate if recommendations are available
                      if (analysis.hasRecommendations)
                        _buildPropertyChip('Recommendations ✓', isRecommendation: true),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Make organic matter text responsive
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Organic Matter: ${analysis.organicMatter}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis, // Add text overflow handling
                          maxLines: 1, // Limit to one line
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyChip(String label, {bool isRecommendation = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isRecommendation ? Colors.blue.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isRecommendation ? Colors.blue.shade800 : Colors.green.shade800,
          fontWeight: FontWeight.bold,
        ),
        // Add text overflow handling
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

