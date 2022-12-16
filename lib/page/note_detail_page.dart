import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bsm_project/model/note.dart';
import 'package:bsm_project/page/edit_note_page.dart';
import 'package:encrypt/encrypt.dart' as enc;

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  final String login;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
    required this.login,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);
    var loginBytes = utf8.encode(widget.login);
    var login = sha512.convert(loginBytes).toString();
    var note = (await _storage.read(key: login));
    var _loginBytes = utf8.encode(login);
    var _login = sha512.convert(_loginBytes).toString();
    var keyIv = await _storage.read(key: _login);
    var js = jsonDecode(keyIv!);
    var key = enc.Key.fromBase64(js["key"]);
    var iv = enc.IV.fromBase64(js["iv"]);
    final encrypter = enc.Encrypter(enc.Salsa20(key));
    final encrypted = encrypter.decrypt(enc.Encrypted.fromBase64(note!), iv: iv);
    this.note = Note.fromJson(jsonDecode(encrypted));

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
      padding: EdgeInsets.all(12),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 8),
        children: [
          Text(
            note.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            note.description,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          )
        ],
      ),
    ),
  );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note, login: widget.login,),
        ));

        refreshNote();
      });

  Widget deleteButton() => IconButton(
    icon: Icon(Icons.delete),
    onPressed: () async {
      // await NotesDatabase.instance.delete(widget.noteId);
      var loginBytes = utf8.encode(widget.login);
      var _login = sha512.convert(loginBytes).toString();
      await _storage.delete(key: _login);
      Navigator.of(context).pop();
    },
  );
}