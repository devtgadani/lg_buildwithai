import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);
  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isFlashOn = false;
  bool isProcessing = false;
  
  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }
  
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessing) return; // Prevent multiple processing attempts
      
      setState(() {
        result = scanData;
        if (result != null && result!.code != null) {
          isProcessing = true;
          _processQRData(result!.code!);
        }
      });
    });
  }
  
  void _processQRData(String data) async {
    try {
      // Pause camera to prevent multiple scans
      controller?.pauseCamera();
      
      // Show loading indicator
      _showLoadingDialog();
      
      // Parse the QR code data (expected to be in JSON format)
      final Map<String, dynamic> settings = jsonDecode(data);
      
      // Save the settings
      await _saveSettings(settings);
      bool? connected = await _connectToLG();

    // Dismiss loading
    if (Navigator.of(context).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (connected == true) {
      _showSuccessDialog();
    } else {
      _showFailureDialog();
    }
      
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      
      // Resume camera after error
      controller?.resumeCamera();
      isProcessing = false;
    }
  }
  
  Future<void> _saveSettings(Map<String, dynamic> settings) async {
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', settings['ipAddress']);
    await prefs.setString('username', settings['username']);
    await prefs.setString('password', settings['password']);
    await prefs.setString('gemini', settings['gemini']);
    await prefs.setString('sshPort', settings['sshPort'].toString());
    await prefs.setString('numberOfRigs', settings['numberOfRigs'].toString());
    
    // For demonstration purposes, we'll just print the settings
    print('Settings saved: $settings');
  }
  
  Future<bool?> _connectToLG() async {
  try {
    print('ok');
    SSH ssh = SSH();
    bool? result = await ssh.connectToLG();
    print('dev');
    if (result == true) {
      print('dev2');
    }
    return result;
  } catch (e) {
    print('Error connecting to LG: $e');
    return false;
  }
}
  
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Connecting to Liquid Galaxy...'),
              ],
            ),
          ),
        );
      },
    );
  }
  
 void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Connection Successful',
          style: TextStyle(fontSize: 22, color: Colors.green),
        ),
        content: const Text('Successfully connected to Liquid Galaxy.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(); // Close dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Navigate to first screen
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
  
  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Connection Failed',
            style: TextStyle(fontSize: 22, color: Colors.red),
          ),
          content: Text('Please check your connection settings and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Resume scanning
                controller?.resumeCamera();
                isProcessing = false;
              },
              child: Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to the previous screen
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(fontSize: 22, color: Colors.red),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Resume scanning
                controller?.resumeCamera();
                isProcessing = false;
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  void _flashToggle() async {
    if (controller != null) {
      await controller!.toggleFlash();
      bool? flashStatus = await controller!.getFlashStatus();
      setState(() {
        isFlashOn = flashStatus ?? false;
      });
    }
  }
  
  void _cameraSwitch() async {
    if (controller != null) {
      await controller!.flipCamera();
    }
  }
  
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Settings QR Code'),
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 40,
              borderWidth: 10,
              cutOutSize: 250,
            ),
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _flashToggle,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.camera_rotate_fill,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _cameraSwitch,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Scan a QR code to automatically connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Assuming you have an SSH class like this
class SSH {
  Future<bool> connectToLG() async {
    // Implement your SSH connection logic here
    // This is just a placeholder
    try {
      // Simulate connection delay
      await Future.delayed(Duration(seconds: 2));
      
      // Return true or false based on connection success
      // For testing, you can return true
      return true;
    } catch (e) {
      print('SSH connection error: $e');
      return false;
    }
  }
}