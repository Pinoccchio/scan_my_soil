import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/soil_analysis.dart';

class GeminiService {
  // IMPORTANT: Be careful with hardcoded API keys in production apps
  // This key will be visible in your app's binary and could be extracted
  static const String _apiKey = "AIzaSyBomw7nWLyhb8uAPDhast7TtaLH-DSUw7Y"; // Replace with your actual API key
  static const String _modelName = 'gemini-1.5-pro';

  static Future<SoilAnalysis> analyzeSoilImage(File imageFile) async {
    try {
      // Initialize the Gemini model
      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
      );

      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();

      // Create a prompt for soil analysis with recommendations
      final prompt = '''
    You are a soil analysis expert. Analyze this soil image and provide detailed information about:
    1. Soil type (e.g., Sandy, Clay, Loam, etc.)
    2. Color (using Munsell color system if possible)
    3. Texture (e.g., Fine, Medium, Coarse)
    4. Estimated pH level (numeric value between 0-14)
    5. Visible fragments (e.g., rocks, organic debris)
    6. Presence of mottles (yes/no and description)
    7. Estimated percentage of organic matter

    Additionally, provide recommendations for:
    8. Suitable crops that would grow well in this soil
    9. Fertilizer needs and amendments to improve soil quality
    10. Soil management practices for optimal plant growth

    Format your response ONLY as a valid JSON object with these properties:
    {
      "soilType": "string",
      "color": "string",
      "texture": "string",
      "phLevel": "string",
      "fragments": "string",
      "mottles": "string",
      "organicMatter": "string",
      "suitableCrops": "string",
      "fertilizerNeeds": "string",
      "soilManagement": "string"
    }
    ''';

      // Create content parts with the image and prompt
      final imagePart = DataPart('image/jpeg', bytes);
      final textPart = TextPart(prompt);
      final content = [Content.multi([textPart, imagePart])];

      // Generate content
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse the JSON response
      try {
        // Extract JSON from the response text
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(responseText);

        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
            return SoilAnalysis(
              soilType: jsonData['soilType'] ?? 'Unknown',
              color: jsonData['color'] ?? 'Unknown',
              texture: jsonData['texture'] ?? 'Unknown',
              phLevel: jsonData['phLevel'] ?? 'Unknown',
              fragments: jsonData['fragments'] ?? 'Unknown',
              mottles: jsonData['mottles'] ?? 'Unknown',
              organicMatter: jsonData['organicMatter'] ?? 'Unknown',
              imageUrl: '', // Add empty imageUrl that will be updated later
              suitableCrops: jsonData['suitableCrops'],
              fertilizerNeeds: jsonData['fertilizerNeeds'],
              soilManagement: jsonData['soilManagement'],
              hasRecommendations: jsonData['suitableCrops'] != null ||
                  jsonData['fertilizerNeeds'] != null ||
                  jsonData['soilManagement'] != null,
            );
          } else {
            throw Exception('Could not extract JSON from response');
          }
        } else {
          throw Exception('Could not extract JSON from response');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        print('Response text: $responseText');

        // Fallback to default values if parsing fails
        return SoilAnalysis(
          soilType: 'Analysis failed',
          color: 'Unknown',
          texture: 'Unknown',
          phLevel: 'Unknown',
          fragments: 'Unknown',
          mottles: 'Unknown',
          organicMatter: 'Unknown',
          imageUrl: '', // Add empty imageUrl
          suitableCrops: null,
          fertilizerNeeds: null,
          soilManagement: null,
          hasRecommendations: false,
        );
      }
    } catch (e) {
      print('Error in analyzeSoilImage: $e');
      rethrow;
    }
  }
}

