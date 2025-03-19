import 'package:uuid/uuid.dart';

class SoilAnalysis {
  final String id;
  final String soilType;
  final String color;
  final String texture;
  final String phLevel;
  final String fragments;
  final String mottles;
  final String organicMatter;
  final DateTime timestamp;
  final String imageUrl;

  // Add recommendation fields
  final String? suitableCrops;
  final String? fertilizerNeeds;
  final String? soilManagement;
  final bool hasRecommendations;

  SoilAnalysis({
    String? id,
    required this.soilType,
    required this.color,
    required this.texture,
    required this.phLevel,
    required this.fragments,
    required this.mottles,
    required this.organicMatter,
    required this.imageUrl,
    DateTime? timestamp,
    this.suitableCrops,
    this.fertilizerNeeds,
    this.soilManagement,
    this.hasRecommendations = false,
  }) :
        id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory SoilAnalysis.fromMap(Map<String, dynamic> map) {
    return SoilAnalysis(
      id: map['id'] ?? const Uuid().v4(),
      soilType: map['soilType'] ?? 'Unknown',
      color: map['color'] ?? 'Unknown',
      texture: map['texture'] ?? 'Unknown',
      phLevel: map['phLevel'] ?? 'Unknown',
      fragments: map['fragments'] ?? 'None',
      mottles: map['mottles'] ?? 'None',
      organicMatter: map['organicMatter'] ?? 'Unknown',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      suitableCrops: map['suitableCrops'],
      fertilizerNeeds: map['fertilizerNeeds'],
      soilManagement: map['soilManagement'],
      hasRecommendations: map['hasRecommendations'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'soilType': soilType,
      'color': color,
      'texture': texture,
      'phLevel': phLevel,
      'fragments': fragments,
      'mottles': mottles,
      'organicMatter': organicMatter,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'suitableCrops': suitableCrops,
      'fertilizerNeeds': fertilizerNeeds,
      'soilManagement': soilManagement,
      'hasRecommendations': hasRecommendations,
    };
  }

  // Helper method to create a copy with recommendations
  SoilAnalysis copyWithRecommendations({
    required String suitableCrops,
    required String fertilizerNeeds,
    required String soilManagement,
  }) {
    return SoilAnalysis(
      id: id,
      soilType: soilType,
      color: color,
      texture: texture,
      phLevel: phLevel,
      fragments: fragments,
      mottles: mottles,
      organicMatter: organicMatter,
      imageUrl: imageUrl,
      timestamp: timestamp,
      suitableCrops: suitableCrops,
      fertilizerNeeds: fertilizerNeeds,
      soilManagement: soilManagement,
      hasRecommendations: true,
    );
  }
}

