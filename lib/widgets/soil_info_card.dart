import 'package:flutter/material.dart';

class SoilInfoCard extends StatelessWidget {
  final String soilType;
  final double phLevel;
  final String nitrogenLevel;
  final String date;
  final bool showActions;

  const SoilInfoCard({
    super.key,
    required this.soilType,
    required this.phLevel,
    required this.nitrogenLevel,
    required this.date,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getSoilColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soilType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (showActions)
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'view') {
                        Navigator.pushNamed(context, '/results');
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPropertyChip('pH: $phLevel', Icons.science),
                _buildPropertyChip('Nitrogen: $nitrogenLevel', Icons.eco),
                _buildPropertyChip('Tap to view more', Icons.arrow_forward),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyChip(String label, IconData icon) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      avatar: Icon(icon, size: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getSoilColor() {
    switch (soilType) {
      case 'Clay Loam':
        return Colors.brown.shade400;
      case 'Sandy Soil':
        return Colors.amber.shade300;
      case 'Silt Loam':
        return Colors.brown.shade200;
      case 'Peaty Soil':
        return Colors.brown.shade800;
      case 'Chalky Soil':
        return Colors.grey.shade300;
      default:
        return Colors.brown.shade500;
    }
  }
}