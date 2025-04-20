
import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:io';
import '/connection_flag.dart';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;


  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,

      );


      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }



Future<bool> disconnectFromLG() async {
    _client?.close();
    return true;
  }
  Future<SSHSession?> execute() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final demo_result = await _client!.execute(
          ' echo "search=India" >/tmp/query.txt');
      return demo_result;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }


  Future<void> relaunchLG() async {
    try {
      for (var i = 1; i <= int.parse(_numberOfRigs); i++) {
        String cmd = """RELAUNCH_CMD="\\
        if [ -f /etc/init/lxdm.conf ]; then
          export SERVICE=lxdm
        elif [ -f /etc/init/lightdm.conf ]; then
          export SERVICE=lightdm
        else
          exit 1
        fi
        if [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
          echo ${_passwordOrKey} | sudo -S service \\\${SERVICE} start
        else
          echo ${_passwordOrKey} | sudo -S service \\\${SERVICE} restart
        fi
        " && sshpass -p ${_passwordOrKey} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await _client?.run(
            '"/home/${_username}/bin/lg-relaunch" > /home/${_username}/log.txt');
        await _client?.run(cmd);
      }
    } catch (error) {
      print(error);
    }
  }


  Future cleanrig() async {
   String clean = '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
      </Document>
</kml>

  ''';

      try {
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;}
        else{
        await _client?.execute("echo '$clean' > /var/www/html/kml/slave_2.kml");
        print('done');
      }} catch (e) {
        return Future.error(e);
      }
  }

  Future<void> rebootlg() async {
    try {
      for (var i = 1; i <= int.parse(_numberOfRigs); i++) {
        await _client?.run(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      }
    } catch (error) {
      throw error;
    }
  }



 Future  sendKml() async {
      String name = '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>task 2</name>
    <open>1</open>
    <description>dev t gadani </description>
    <Folder>

      <ScreenOverlay id="abc">
        <name>task 2 </name>
        <Icon><href>https://github.com/devtgadani/kml-dataimg/blob/5f86b3ba65ec0cba35190a9a01bf43bdaa5f2a08/devkmldataname.jpg?raw=true</href></Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0" y="0.98" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="500" y="300" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
      </Folder>
  </Document>
</kml>
  ''';

      try {
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;}
        else{
        await _client?.execute("echo '$name' > /var/www/html/kml/slave_3.kml");
        print('done');
      }} catch (e) {
        return Future.error(e);
      }
  }

 Future  sendBallon(String name, String millisecondsSinceEpoch ) async {
    String clean = '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
      </Document>
</kml>

  ''';
      try { 
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;}
        else{
          await _client?.execute("echo '$clean' > /var/www/html/kml/slave_2.kml");
        await _client?.execute("echo '$name' > /var/www/html/kml/slave_2.kml");
        print('done');
      }} catch (e) {
        return Future.error(e);
      }
  }

  String Kmlmaker(String name) {
    return  name;
  }

  Future<SSHSession?> SendAIKml(String name, String millisecondsSinceEpoch ) async {
    try {
      await connectToLG();

      await _client!
          .execute("echo '${SSH().Kmlmaker(name)}' > /var/www/html/${millisecondsSinceEpoch}.kml");
      await _client!.execute(
          'echo "http://lg1:81/${millisecondsSinceEpoch}.kml" >> /var/www/html/kmls.txt');
     
    } catch (error) {
      throw error;
    }
  }




//
  Future<SSHSession?> search(String place) async {
    try {

      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }

      final session =
      await _client!.execute("echo 'search=$place' >/tmp/query.txt");
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  String getCityData() {
    int heading = 0;
    String kml = '';

    for (var i = 0; i <= 36; i++) {
      heading += 10;
      kml += '''
<gx:FlyTo>
  <gx:duration>1.2</gx:duration>
  <gx:flyToMode>smooth</gx:flyToMode>
  	<name>Dev Place</name>
  <LookAt>
    <longitude>72.59338047456748</longitude>
    <latitude>23.02073745592954</latitude>
    <heading>$heading</heading>
   <tilt>64.34299295697522</tilt>
    <range>193.8159415534574</range>
    <gx:fovy>35</gx:fovy> 
    <altitude>75.9318908017075</altitude> 
    <gx:altitudeMode>absolute</gx:altitudeMode>
  </LookAt>
</gx:FlyTo>
  ''';
    }

    return kml;
  }
  String makeOrbit() {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <gx:Tour>
    <name>Orbit</name>
      <gx:Playlist>
        ${getCityData()}
      </gx:Playlist>
  </gx:Tour>
</kml>
  ''';
  }

 playOrbit() async {
    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );

      await _client!.execute("echo '${SSH().makeOrbit()}' > /var/www/html/orbitcity.kml");
      await  _client!.execute('echo "http://lg1:81/orbitcity.kml" >> /var/www/html/kmls.txt');
      return await _client!.execute("echo 'playtour=Orbit' > /tmp/query.txt");
    }
catch(error){
      throw error;
}

  }}


