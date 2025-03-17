import 'package:flutter/material.dart';
import '../widgets/soil_property_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result summary card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.landscape,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clay Loam Soil',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Scanned on March 16, 2025',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your soil is moderately fertile with good water retention. Suitable for most garden plants with proper amendments.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Soil Properties',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // Soil properties
              const SoilPropertyCard(
                title: 'pH Level',
                value: '6.8',
                description: 'Slightly acidic, ideal for most plants',
                icon: Icons.science,
                color: Colors.blue,
              ),

              const SoilPropertyCard(
                title: 'Nitrogen (N)',
                value: 'Medium',
                description: 'Adequate for plant growth',
                icon: Icons.eco,
                color: Colors.green,
              ),

              const SoilPropertyCard(
                title: 'Phosphorus (P)',
                value: 'Low',
                description: 'Consider adding phosphorus-rich fertilizer',
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),

              const SoilPropertyCard(
                title: 'Potassium (K)',
                value: 'High',
                description: 'Excellent levels for plant health',
                icon: Icons.check_circle,
                color: Colors.green,
              ),

              const SoilPropertyCard(
                title: 'Moisture Content',
                value: '42%',
                description: 'Good water retention capacity',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),

              const SizedBox(height: 24),

              // Recommendations section
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• Add phosphorus-rich fertilizer to improve nutrient balance\n'
                            '• Consider adding organic matter to improve soil structure\n'
                            '• Suitable for growing: Tomatoes, Peppers, Beans, Cucumbers\n'
                            '• Monitor moisture levels during dry periods',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Save result functionality would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Result saved to history'),
                              ),
                            );
                          },
                          child: const Text('Save Result'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}