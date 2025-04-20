import 'package:flutter/material.dart';
import 'package:mini/geminidev.dart';
import 'package:mini/ssh.dart';

class LG_Task extends StatefulWidget {
   const LG_Task({Key? key}) : super(key: key);

  @override
  _LGTaskState createState() => _LGTaskState();
  

}

class _LGTaskState extends State<LG_Task> {
  var gsd = GeminiI();
  late SSH ssh;
  bool connectionStatus = false;
  

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even spacing
          children: [
            _buildButton(Icons.restart_alt, 'Restart', ()async {
              print('dev');
            await ssh.rebootlg();
              print('dev');

              // Handle restart action
            }),
            _buildButton(Icons.power_settings_new, 'Clean kml', () async{
              await ssh.cleanrig();
              // Handle shutdown action
            }),
            _buildButton(Icons.autorenew, 'Reboot', ()async {
              await ssh.rebootlg();
            }),
            _buildButton(Icons.image, 'Display Logo', () async {
              await ssh.sendKml();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: 250, // Ensures all buttons have the same width
      height: 60, // Optional: Set equal height for buttons
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }
}
