import 'package:flutter/material.dart';
import '../widgets/soil_info_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter options
            Row(
              children: [
                const Text('Filter by: '),
                DropdownButton<String>(
                  value: 'All',
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                    DropdownMenuItem(value: 'Last Month', child: Text('Last Month')),
                  ],
                  onChanged: (value) {
                    // Filter functionality would go here
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    // Sort functionality would go here
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // History list
            Expanded(
              child: ListView(
                children: const [
                  SoilInfoCard(
                    soilType: 'Clay Loam',
                    phLevel: 6.8,
                    nitrogenLevel: 'Medium',
                    date: 'March 16, 2025',
                    showActions: true,
                  ),
                  SizedBox(height: 8),
                  SoilInfoCard(
                    soilType: 'Sandy Soil',
                    phLevel: 5.5,
                    nitrogenLevel: 'Low',
                    date: 'March 10, 2025',
                    showActions: true,
                  ),
                  SizedBox(height: 8),
                  SoilInfoCard(
                    soilType: 'Silt Loam',
                    phLevel: 7.2,
                    nitrogenLevel: 'High',
                    date: 'February 28, 2025',
                    showActions: true,
                  ),
                  SizedBox(height: 8),
                  SoilInfoCard(
                    soilType: 'Peaty Soil',
                    phLevel: 4.8,
                    nitrogenLevel: 'Medium',
                    date: 'February 15, 2025',
                    showActions: true,
                  ),
                  SizedBox(height: 8),
                  SoilInfoCard(
                    soilType: 'Chalky Soil',
                    phLevel: 7.8,
                    nitrogenLevel: 'Low',
                    date: 'January 30, 2025',
                    showActions: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}