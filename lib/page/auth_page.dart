import 'package:bsm_project/api/local_auth_api.dart';
import 'package:bsm_project/main.dart';
import 'package:bsm_project/page/notes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'login.dart';

class AuthPage extends StatefulWidget {

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  String _deviceId = "";
  var dev;
  
  @override
  void initState() {
    super.initState();


    getDeviceId();
  }

  Future getDeviceId() async {
    String? deviceId;
    var deviceIdBytes;
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
      deviceIdBytes = utf8.encode(deviceId.toString());
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }
    if (!mounted) return;
    setState(() {
      _deviceId = deviceId!;
      dev = sha512.convert(deviceIdBytes).toString();
    });
  }

  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(MyApp.title),
      centerTitle: true,
    ),
    backgroundColor: Colors.white70,
    body: Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildLogin(context),
            SizedBox(height: 24),
            buildAuthenticate(context),
          ],
        ),
      ),
    ),
  );

  Widget buildLogin(BuildContext context) => buildButton(
    text: 'Authenticate with password',
    icon: Icons.keyboard_alt_outlined,

    onClicked: () async {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Login(deviceId: _deviceId),
        )
      );
    },
  );

  Widget buildAuthenticate(BuildContext context) => buildButton(
    text: 'Authenticate with fingerprint',
    icon: Icons.fingerprint,
    onClicked: () async {
      final isAuthenticated = await LocalAuthApi.authenticate();
      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NotesPage(login: dev)),
        );
      }
    },
  );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
          primary: Colors.black
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );
}