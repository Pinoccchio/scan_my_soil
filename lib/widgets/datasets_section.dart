import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';

class DatasetsSection extends StatefulWidget {
  const DatasetsSection({super.key});

  @override
  State<DatasetsSection> createState() => _DatasetsSectionState();
}

class _DatasetsSectionState extends State<DatasetsSection> {
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String _filterType = 'All';
  List<Map<String, dynamic>> _datasets = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  Future<void> _loadDatasets() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final datasets = await _supabaseService.getSoilDatasets();

      // Apply filters if needed
      if (_filterType == 'Recent') {
        datasets.sort((a, b) {
          final aDate = DateTime.parse(a['created_at']);
          final bDate = DateTime.parse(b['created_at']);
          return bDate.compareTo(aDate);
        });
      } else if (_filterType == 'Favorites') {
        datasets.removeWhere((dataset) => dataset['is_favorite'] != true);
      }

      setState(() {
        _datasets = datasets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load datasets: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDataset(int datasetId) async {
    try {
      await _supabaseService.deleteSoilDataset(datasetId);
      await _loadDatasets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dataset deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete dataset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              'View and manage your soil analysis data',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis, // Prevent text overflow
            ),
            const SizedBox(height: 24),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search datasets',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),

            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, 'All', _filterType == 'All'),
                  _buildFilterChip(context, 'Recent', _filterType == 'Recent'),
                  _buildFilterChip(context, 'Favorites', _filterType == 'Favorites'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            // Datasets list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDatasetsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _filterType = label;
            });
            _loadDatasets();
          }
        },
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        selectedColor: Colors.green.shade100,
        checkmarkColor: Colors.green.shade700,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.green.shade700
              : (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800),
        ),
      ),
    );
  }

  Widget _buildDatasetsList(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No datasets yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan your first soil sample to create a dataset',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to scan screen
                Navigator.pushNamed(context, '/scan');
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Soil Sample'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDatasets,
      child: ListView.builder(
        itemCount: _datasets.length,
        itemBuilder: (context, index) {
          final dataset = _datasets[index];
          final nutrients = dataset['soil_nutrients'] ?? {};

          // Format the date
          String formattedDate = 'No date';
          if (dataset['created_at'] != null) {
            try {
              final date = DateTime.parse(dataset['created_at']);
              formattedDate = DateFormat('MMM d, yyyy').format(date);
            } catch (e) {
              // Use default value if date parsing fails
            }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dataset['name'] as String? ?? 'Unnamed Dataset',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent text overflow
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                        onPressed: () {
                          _showDatasetOptions(context, dataset);
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent text overflow
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dataset['location'] as String? ?? 'No location',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent text overflow
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutrientChip(context, 'N', _getNutrientLevel(nutrients['nitrogen'])),
                      _buildNutrientChip(context, 'P', _getNutrientLevel(nutrients['phosphorus'])),
                      _buildNutrientChip(context, 'K', _getNutrientLevel(nutrients['potassium'])),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getNutrientLevel(dynamic value) {
    if (value == null) return 'Unknown';

    double numValue;
    if (value is int) {
      numValue = value.toDouble();
    } else if (value is double) {
      numValue = value;
    } else if (value is String) {
      try {
        numValue = double.parse(value);
      } catch (e) {
        return value; // Return the string value if it can't be parsed
      }
    } else {
      return 'Unknown';
    }

    // Determine level based on value
    if (numValue < 10) return 'Low';
    if (numValue < 20) return 'Medium';
    return 'High';
  }

  Widget _buildNutrientChip(BuildContext context, String nutrient, String level) {
    Color chipColor;
    Color textColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (level) {
      case 'Low':
        chipColor = isDarkMode ? Colors.red.shade900 : Colors.red.shade100;
        textColor = isDarkMode ? Colors.red.shade100 : Colors.red.shade900;
        break;
      case 'Medium':
        chipColor = isDarkMode ? Colors.amber.shade900 : Colors.amber.shade100;
        textColor = isDarkMode ? Colors.amber.shade100 : Colors.amber.shade900;
        break;
      case 'High':
        chipColor = isDarkMode ? Colors.green.shade900 : Colors.green.shade100;
        textColor = isDarkMode ? Colors.green.shade100 : Colors.green.shade900;
        break;
      default:
        chipColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
        textColor = isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800;
    }

    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$nutrient: $level',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis, // Prevent text overflow
        ),
      ),
    );
  }

  void _showDatasetOptions(BuildContext context, Map<String, dynamic> dataset) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: Colors.blue.shade700),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to dataset details screen
                },
              ),
              ListTile(
                leading: Icon(
                  dataset['is_favorite'] == true
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber.shade700,
                ),
                title: Text(
                  dataset['is_favorite'] == true
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Toggle favorite status
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.green.shade700),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, dataset);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> dataset) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Dataset'),
          content: Text('Are you sure you want to delete "${dataset['name']}"? This action cannot be undone.'),
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDataset(dataset['id']);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
  }
}