import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_assistant.dart';

class VoiceAssistantPage extends StatefulWidget {
  @override
  _VoiceAssistantPageState createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceAssistant _assistant = VoiceAssistant();

  bool _isListening = false;
  String _transcript = '';
  String _response = '';

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    if (_transcript.isNotEmpty) {
      final reply = await _assistant.askGemini(_transcript);
      setState(() {
        _response = reply;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voice Assistant"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("🧑 You: $_transcript", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("🤖 Assistant: $_response", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? "Stop Listening" : "Start Talking"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
