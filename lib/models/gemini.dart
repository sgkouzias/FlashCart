import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Function to create the GenerativeModel instance
Future<GenerativeModel> createGenerativeModel() async {
  // Load API key
  await dotenv.load(fileName: 'vars.env');
  final apiKey = dotenv.env['API_KEY'] ?? '';

   final generationConfig = GenerationConfig(
    temperature: 0.95,
    topP: 0.95,
    topK: 50,
    responseMimeType: 'text/plain',
  ); 

  // Explicitly cast generationConfig to GenerationConfig?
  return GenerativeModel(
    model: 'gemini-1.5-flash', // Directly specify the model name
    apiKey: apiKey,
    generationConfig: generationConfig as GenerationConfig?, 
  );
}