import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mini/ssh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiquidGalaxyChatbot extends StatefulWidget {
  @override
  _LiquidGalaxyChatbotState createState() => _LiquidGalaxyChatbotState();
}
class _LiquidGalaxyChatbotState extends State<LiquidGalaxyChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  late SSH ssh;

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isBotTyping = false;
  String? apiKey;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
    _initializeChatbot();
    _clearMessagesOnRestart();
  }

  Future<void> _initializeChatbot() async {
    await _loadSettings();

    if (apiKey == null || apiKey!.isEmpty) {
      print("API key not found!");
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey:  '${apiKey}',
    );

    _chat = _model.startChat(
      history: [
        Content.text(
          "This chatbot specializes in answering questions about Liquid Galaxy. Use information from the official site (https://www.liquidgalaxy.eu/) and any KML documentation.",
        ),
      ],
    );
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('gemini') ?? '';
  }
  Future<void> _clearMessagesOnRestart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
    setState(() {
      _messages.clear();
    });
  }

  Future<void> _connectToLG() async {
    await ssh.connectToLG();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _messages.map((m) => Map<String, dynamic>.from(m)).toList();
    await prefs.setString('chat_messages', encoded.toString());
  }

  Future<void> _sendMessage(String input) async {
    setState(() {
      _messages.add({'role': 'user', 'content': input});
      _isBotTyping = true;
      _controller.clear();
    });

    try {
      final response = await _chat.sendMessage(Content.text(input));
      final reply = response.text ?? 'Sorry, I didn’t get that.';

      final kmlStart = reply.indexOf('<?xml');
      final kmlEnd = reply.lastIndexOf('</kml>') + 6;
      final containsKml = kmlStart != -1 && kmlEnd != -1 && kmlEnd > kmlStart;
      final kmlExtract = containsKml ? reply.substring(kmlStart, kmlEnd) : null;

      String? placemarkKml;
      String? styledDescriptionKml;

      if (containsKml && kmlExtract != null) {
        final placemarkRegex = RegExp(r'<Placemark>[\s\S]*?</Placemark>');
        final placemarkMatch = placemarkRegex.firstMatch(kmlExtract);
        var placemark = placemarkMatch?.group(0) ?? '';

        String? extractedDescription;
        final descriptionMatch = RegExp(r'<description>([\s\S]*?)</description>')
            .firstMatch(placemark);
        if (descriptionMatch != null) {
          extractedDescription = descriptionMatch.group(1);
        }

        if (!placemark.contains('<styleUrl>')) {
          placemark = placemark.replaceFirstMapped(
            RegExp(r'<description>[\s\S]*?</description>'),
            (match) =>
                '${match.group(0)}\n      <styleUrl>#tourist_place_style</styleUrl>\n       <gx:balloonVisibility>1</gx:balloonVisibility>',
          );
        }

        placemarkKml =
            '''<?xml version="1.0" encoding="UTF-8"?>\n<kml xmlns="http://www.opengis.net/kml/2.2">\n  <Document>\n    $placemark\n  </Document>\n</kml>''';

        styledDescriptionKml =
            '''<?xml version="1.0" encoding="UTF-8"?>\n<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n  <Document>\n    <name>Tourist Place Data</name>\n    <Style id="tourist_place_style">\n      <BalloonStyle>\n        <textColor>#ffff0000</textColor>\n        <bgColor>#f0f4c3</bgColor>\n        <text><![CDATA[\n          ${extractedDescription ?? "No Description"}\n        ]]></text>\n        <bgColor>#d4e157</bgColor>\n      </BalloonStyle>\n    </Style>\n $placemark\n  </Document>\n</kml>''';
      }

      setState(() {
        _messages.add({
          'role': 'bot',
          'content': reply,
          'isKml': containsKml,
          'placemarkKml': placemarkKml,
          'styledKml': styledDescriptionKml,
        });
        _isBotTyping = false;
      });

      await _saveMessages();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() {
        _isBotTyping = false;
        _messages.add({'role': 'bot', 'content': 'Error: $e', 'isKml': false});
      });
    }
  }

  Future<void> _shareKml(Map<String, dynamic> msg) async {
    await ssh.sendBallon(
        msg['styledKml'], DateTime.now().millisecondsSinceEpoch.toString());
    await ssh.SendAIKml(
        msg['placemarkKml'], DateTime.now().millisecondsSinceEpoch.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isUser ? Colors.blueAccent : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isUser
                            ? Text(
                                msg['content'],
                                style: TextStyle(color: Colors.white),
                              )
                            : MarkdownBody(
                                data: msg['content'],
                                styleSheet:
                                    MarkdownStyleSheet.fromTheme(Theme.of(context))
                                        .copyWith(p: TextStyle(color: Colors.black)),
                              ),
                      ),
                      if (!isUser && (msg['isKml'] ?? false))
                        TextButton.icon(
                          onPressed: () => _shareKml(msg),
                          icon: Icon(Icons.place),
                          label: Text("Show KML on LG Rig"),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isBotTyping)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "Bot is typing...",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ask about LG or generate KML...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final input = _controller.text.trim();
                    if (input.isNotEmpty) {
                      _sendMessage(input);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
