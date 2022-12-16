import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

import 'notes_page.dart';

class Login extends StatefulWidget {
  final String deviceId;

  const Login({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController password = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  Future<String?> login(String deviceId, String password) async {
    var passLog = deviceId + password;
    var passBytes = utf8.encode(passLog.toString());
    var pass = sha512.convert(passBytes).toString();
    var deviceIdBytes = utf8.encode(deviceId.toString());
    var dev = sha512.convert(deviceIdBytes).toString();
    Map<String, String> allUsers = await _storage.readAll();
    if(allUsers.containsKey(dev)){
      var _password = allUsers[dev];
      if(_password == pass){
        return "1";
      } else {
        return "0";
      }
    } else {
      _storage.write(key: dev, value: pass);
      return "1";
    }

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
                        'Log in with your password',
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
                              labelText: 'Password'),
                          validator:  Validators.patternRegExp(
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
                              var x = await login(widget.deviceId, password.text);
                              var deviceIdBytes = utf8.encode(widget.deviceId.toString());
                              var dev = sha512.convert(deviceIdBytes).toString();
                              await Future.delayed(Duration(seconds: 1));
                              if(x == "1") {
                                await Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => NotesPage(login: dev)),
                                );
                              } else {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => AlertDialog(
                                        title: const Text('Password incorrect'),
                                        content: const Text('Police is on their way!'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      )),
                                );
                              }
                            }
                          },
                          child: Text("Log in"),
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
