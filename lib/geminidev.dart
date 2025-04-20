import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mini/quiz_question.dart';
import 'package:shared_preferences/shared_preferences.dart';


const apiKey = 'AIzaSyBAFa_HJpK2r0NVHsMLskYShRYqHSEXAkA'; // Make sure to assign your actual API key
class GeminiI {
   GenerativeModel? model;
  
  // Initialize with API key from shared preferences
  Future<void> initialize() async {
    final apiKey = await _getApiKeyFromPrefs();
    model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }
  
  // Get API key from shared preferences
  Future<String> _getApiKeyFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini') ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not found in shared preferences');
    }
    return apiKey;
  }
  
  // Method to generate content
 

Future<dynamic> generateContent({
  required String query,
  double? lat,
  double? lan,
  required String topic,
  int numberOfQuestions = 5,
}) async {
    if (model == null) {
        await initialize();
      }
  String prompt = '';

  // Prompt selection
  if (topic == 'tourist') {
    prompt = '''
Given the query: "$query", generate a JSON array of 5 places in India.
Each place should have:
  - name: (String)
  - des: (String)
  - lat: (double)
  - lan: (double)
''';
  } else if (topic == 'mini') {
    prompt = '''
You are a quiz generator for educational purposes about Liquid Galaxy.

Search ONLY the following sources:
- https://lg-wiki-coral.vercel.app/
- https://liquidgalaxy.eu

Generate $numberOfQuestions multiple-choice quiz questions about "$query".
Each question must be based on verifiable info from these sites.

Return ONLY a valid JSON array. Do NOT add markdown, explanation, or any extra text.

Each object should be formatted like this:
{
  "question": "What is Liquid Galaxy?",
  "options": [
    "a. A gaming platform",
    "b. A panoramic visualization system",
    "c. A machine learning tool",
    "d. A 3D printer"
  ],
  "correctAnswerIndex": 1
}
''';
  } else if (topic == 'kml') {
    prompt = '''
Given the place name: "$query" and coordinates: "lat: ${lat}, lon: ${lan}", generate a valid JSON OBJECT ONLY, like this:

{
  "description": "HTML or plain text description",
  "polygon": "<KML polygon using the coordinates>"
}

- Use a simple rectangle polygon based on the coordinates.
- DO NOT include markdown, explanation, or extra text.
- ONLY return the pure JSON object.
''';
  } else {
    throw Exception("Invalid topic: $topic");
  }

  // 👇 Common call to Gemini
  try {
    final response = await model?.generateContent([Content.text(prompt)]);
    final rawText = response?.text?.trim();
    if (rawText == null || rawText.isEmpty) {
      print("❌ Error: Empty response from Gemini");
      return [];
    }

    // 👇 Decide parsing strategy
    if (topic == 'kml') {
      final jsonStart = rawText.indexOf('{');
      final jsonEnd = rawText.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        print('❌ Error: JSON object brackets not found');
        print("🌍 Full KML Response: $rawText");
        return {};
      }

      final jsonString = rawText.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(jsonString);
      return decoded; // 👈 returning object (Map)
    } else {
      final jsonStart = rawText.indexOf('[');
      final jsonEnd = rawText.lastIndexOf(']');
      if (jsonStart == -1 || jsonEnd == -1) {
        print('❌ Error: JSON array brackets not found');
        print("🌍 Full Array Response: $rawText");
        return [];
      }

      final jsonString = rawText.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(jsonString);
      return decoded; // 👈 returning array (List)
    }
  } catch (error) {
    print('❌ Error generating content: $error');
    return topic == 'kml' ? {} : [];
  }
}
}