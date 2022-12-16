import 'dart:convert';

import 'package:bsm_project/page/auth_page.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

import 'login.dart';
import 'notes_page.dart';

class ChangePassword extends StatefulWidget {
  final String deviceId;

  const ChangePassword({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController password = TextEditingController();
  TextEditingController new_password = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String _deviceId = "";

  @override
  void initState() {
    super.initState();


    getDeviceId();
  }

  Future<String?> changePassword(String password, String new_password) async {
    var passLog = _deviceId + password;
    var passBytes = utf8.encode(passLog.toString());
    var pass = sha512.convert(passBytes).toString();
    var deviceIdBytes = utf8.encode(_deviceId.toString());
    var dev = sha512.convert(deviceIdBytes).toString();
    Map<String, String> allUsers = await _storage.readAll();
    if(allUsers.containsKey(dev)){
      var _password = allUsers[dev];
      if(_password == pass){
        await _storage.delete(key: dev);
        var passLogNew = _deviceId + new_password;
        var _passBytes = utf8.encode(passLogNew.toString());
        var _pass = sha512.convert(_passBytes).toString();
        await _storage.write(key: dev, value: _pass);
        return "1";
      } else {
        return "0";
      }
    } else {
      return "0";
    }

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Change Your Password',
                        style: TextStyle(fontSize: 30),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextFormField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.white)),
                              labelText: 'Old Password'),
                          validator: Validators.compose(
                              [Validators.required('password is required')]),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextFormField(
                          controller: new_password,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.white)),
                              labelText: 'New Password'),
                            validator: Validators.patternRegExp(
                                RegExp(r'^.{10,}$'), "Minimum ten characters")
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: FlatButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var x = await changePassword(password.text, new_password.text);
                              var deviceIdBytes = utf8.encode(_deviceId.toString());
                              var dev = sha512.convert(deviceIdBytes).toString();
                              if(x == "1") {
                                await Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => NotesPage(login: dev)),
                                );
                              } else {
                                await Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => AlertDialog(
                                        title: const Text('Password incorrect'),
                                        content: const Text('Police is on their way!'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) => AuthPage()),
                                            ),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      )),
                                );
                              }
                            }
                          },
                          child: Text("Change Password"),
                          textColor: Colors.white,
                          color: Colors.black,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
