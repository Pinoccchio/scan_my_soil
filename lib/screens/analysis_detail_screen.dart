import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/soil_analysis.dart';

class AnalysisDetailScreen extends StatefulWidget {
  final SoilAnalysis analysis;

  const AnalysisDetailScreen({
    super.key,
    required this.analysis,
  });

  @override
  State<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen> {
  late SoilAnalysis _analysis;

  @override
  void initState() {
    super.initState();
    _analysis = widget.analysis;
  }

  @override
  Widget build(BuildContext context) {
    // Check for dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final cardBorderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final accentColor = Colors.green.shade600;
    final sectionBgColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.green.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Soil Analysis Details'),
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: isDarkMode ? 0 : 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, primaryTextColor, secondaryTextColor),
            const SizedBox(height: 16),

            // Display the soil image
            if (_analysis.imageUrl.isNotEmpty)
              _buildImageCard(context, cardColor, cardBorderColor),

            const SizedBox(height: 24),
            _buildDetailCard(context, cardColor, cardBorderColor, primaryTextColor, secondaryTextColor),
            const SizedBox(height: 24),

            // Only show recommendations if they exist
            if (_analysis.hasRecommendations)
              _buildRecommendations(
                  context,
                  cardColor,
                  cardBorderColor,
                  primaryTextColor,
                  secondaryTextColor,
                  sectionBgColor,
                  accentColor
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryTextColor, Color secondaryTextColor) {
    final dateFormat = DateFormat('MMMM d, yyyy - h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Analysis',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Analyzed on ${dateFormat.format(_analysis.timestamp)}',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(BuildContext context, Color cardColor, Color borderColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: _analysis.imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 250,
              color: Colors.grey.shade700,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 250,
              color: Colors.grey.shade700,
              child: const Center(
                child: Icon(Icons.error, size: 50, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, Color cardColor, Color borderColor, Color primaryTextColor, Color secondaryTextColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Soil Characteristics', primaryTextColor),
            const SizedBox(height: 16),
            _buildDetailItem('Soil Type', _analysis.soilType, primaryTextColor, secondaryTextColor),
            _buildDetailItem('Color', _analysis.color, primaryTextColor, secondaryTextColor),
            _buildDetailItem('Texture', _analysis.texture, primaryTextColor, secondaryTextColor),
            _buildDetailItem('pH Level', _analysis.phLevel, primaryTextColor, secondaryTextColor),
            _buildDetailItem('Fragments', _analysis.fragments, primaryTextColor, secondaryTextColor),
            _buildDetailItem('Mottles', _analysis.mottles, primaryTextColor, secondaryTextColor),
            _buildDetailItem('Organic Matter', _analysis.organicMatter, primaryTextColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }

  // Update the _buildRecommendations method to ensure recommendations are displayed
  Widget _buildRecommendations(
      BuildContext context,
      Color cardColor,
      Color borderColor,
      Color primaryTextColor,
      Color secondaryTextColor,
      Color sectionBgColor,
      Color accentColor
      ) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Recommendations', primaryTextColor),
            const SizedBox(height: 16),

            if (!_analysis.hasRecommendations ||
                (_analysis.suitableCrops == null &&
                    _analysis.fertilizerNeeds == null &&
                    _analysis.soilManagement == null))
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No recommendations available',
                        style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This analysis does not include recommendations',
                        style: TextStyle(color: secondaryTextColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  if (_analysis.suitableCrops != null && _analysis.suitableCrops!.isNotEmpty)
                    _buildRecommendationItem(
                      'Suitable Crops',
                      _analysis.suitableCrops!,
                      Icons.grass,
                      accentColor,
                      sectionBgColor,
                      primaryTextColor,
                    ),
                  if (_analysis.suitableCrops != null && _analysis.suitableCrops!.isNotEmpty)
                    const SizedBox(height: 12),

                  if (_analysis.fertilizerNeeds != null && _analysis.fertilizerNeeds!.isNotEmpty)
                    _buildRecommendationItem(
                      'Fertilizer Needs',
                      _analysis.fertilizerNeeds!,
                      Icons.science,
                      accentColor,
                      sectionBgColor,
                      primaryTextColor,
                    ),
                  if (_analysis.fertilizerNeeds != null && _analysis.fertilizerNeeds!.isNotEmpty)
                    const SizedBox(height: 12),

                  if (_analysis.soilManagement != null && _analysis.soilManagement!.isNotEmpty)
                    _buildRecommendationItem(
                      'Soil Management',
                      _analysis.soilManagement!,
                      Icons.eco,
                      accentColor,
                      sectionBgColor,
                      primaryTextColor,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String content, IconData icon, Color iconColor, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

