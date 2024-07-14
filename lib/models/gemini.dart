import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GenerationConfig {
  final double temperature;
  final double topP;
  final double topK;
  final String responseMimeType;

  GenerationConfig({
    required this.temperature,
    required this.topP,
    required this.topK,
    required this.responseMimeType,
  });
}

class GenerativeModelConfig {
  final String model;
  final GenerationConfig generationConfig;

  GenerativeModelConfig({
    required this.model,
    required this.generationConfig,
  });
}

final generativeModelConfig = GenerativeModelConfig(
  model: 'gemini-1.5-flash',
  generationConfig: GenerationConfig(
      temperature: 0.95,
      topP: 0.95,
      topK: 50,
      responseMimeType: 'text/plain'), // Use the imported GenerationConfig
);

// Optional: API Key Utility
Future<String> loadApiKey() async {
  await dotenv.load(fileName: 'vars.env');
  return dotenv.env['API_KEY'] ?? '';
}

// Function to create the GenerativeModel instance
Future<GenerativeModel> createGenerativeModel() async {
  final apiKey = await loadApiKey();
  var generationConfig;
  return GenerativeModel(
    model: generativeModelConfig.model,
    apiKey: apiKey,
    generationConfig: generationConfig,
  );
}
