  import 'package:google_generative_ai/google_generative_ai.dart';
  import 'package:flutter_tts/flutter_tts.dart';

  class VoiceAssistant {
    final _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyBAFa_HJpK2r0NVHsMLskYShRYqHSEXAkA',
    );

    final _tts = FlutterTts();
    late final ChatSession _chat;

    VoiceAssistant() {
      _chat = _model.startChat();
    }

    Future<String> askGemini(String input) async {
      try {
        final response = await _chat.sendMessage(Content.text(input));
        final reply = response.text ?? 'Sorry, I didn’t get that.';
        await _tts.speak(reply);
        return reply;
      } catch (e) {
        await _tts.speak("Something went wrong.");
        return 'Error: $e';
      }
    }
  }
