import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({Key? key}) : super(key: key);

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController(text: '22');
  final TextEditingController _rigsController = TextEditingController();
  final TextEditingController _gemini = TextEditingController();

  String _qrData = '';
  bool _hasError = false;
  String _errorMessage = '';

  void _generateQRCode() {
    // Clear previous error
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    // Validate inputs
    if (_ipController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _sshPortController.text.isEmpty ||
        _rigsController.text.isEmpty||
        _gemini.text.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'All fields are required';
      });
      return;
    }

    try {
      // Create a map with the settings
      final Map<String, dynamic> settings = {
        'ipAddress': _ipController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'sshPort': int.tryParse(_sshPortController.text) ?? 22,
        'numberOfRigs': int.tryParse(_rigsController.text) ?? 1,
        'gemini':_gemini.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch, // Add timestamp for uniqueness
      };

      // Convert the map to a JSON string
      final String jsonSettings = jsonEncode(settings);
      
      setState(() {
        _qrData = jsonSettings;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error generating QR code: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate LG Settings QR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IP Address field
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address *',
                hintText: 'Enter Master IP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Username field
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username *',
                hintText: 'Enter LG username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password *',
                hintText: 'Enter LG password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // SSH Port field
            TextField(
              controller: _sshPortController,
              decoration: const InputDecoration(
                labelText: 'SSH Port *',
                hintText: '22',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Number of Rigs field
            TextField(
              controller: _gemini,
              decoration: const InputDecoration(
                labelText: 'enter gemini key ',
                hintText: 'AIzaSyBAFa_HJpK2r0NhRYqHSEXAkA',
                border: OutlineInputBorder(),
              ),
             
            ),


            const SizedBox(height: 24),
              TextField(
              controller: _rigsController,
              decoration: const InputDecoration(
                labelText: 'Number of Rigs *',
                hintText: 'Enter number of LG rigs',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Error message display
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // Generate QR button
            ElevatedButton(
              onPressed: _generateQRCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('GENERATE QR CODE'),
            ),
            const SizedBox(height: 24),

            // QR code display area
            if (_qrData.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 250.0,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H, // Higher error correction
                        gapless: false, // Add some padding between modules
                        padding: const EdgeInsets.all(10.0), // Padding around the QR code
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan this QR code with your LG control app to load settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Display the generated JSON data for debugging
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Generated Data:\n$_qrData',
                        style: TextStyle(fontSize: 12, fontFamily: 'Courier'),
                      ),
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