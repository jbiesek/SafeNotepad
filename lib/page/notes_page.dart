import 'package:bsm_project/page/change_password.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:bsm_project/model/note.dart';
import 'package:bsm_project/page/edit_note_page.dart';
import 'package:bsm_project/page/note_detail_page.dart';
import 'package:bsm_project/widget/note_card_widget.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

class NotesPage extends StatefulWidget {

  final String login;

  const NotesPage({
    Key? key,
    required this.login,
  }) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    var loginBytes = utf8.encode(widget.login);
    var login = sha512.convert(loginBytes).toString();
    Map<String, String> allNotes = await _storage.readAll();
    if(allNotes.containsKey(login)) {
      var note = (await _storage.read(key: login));
      var _loginBytes = utf8.encode(login);
      var _login = sha512.convert(_loginBytes).toString();
      var keyIv = await _storage.read(key: _login);
      var js = jsonDecode(keyIv!);
      var key = enc.Key.fromBase64(js["key"]);
      var iv = enc.IV.fromBase64(js["iv"]);
      final encrypter = enc.Encrypter(enc.Salsa20(key));
      final encrypted = encrypter.decrypt(enc.Encrypted.fromBase64(note!), iv: iv);
      Note _note = Note.fromJson(jsonDecode(encrypted));
      List<Note> notesList = [_note];
      this.notes = notesList;
    } else {
      this.notes = [];
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Notes',
        style: TextStyle(fontSize: 24),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey.shade900),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangePassword(deviceId: widget.login,)),
            );
        },
          child: Text('Change Password'),
        )
  ]
    ),
    body: Center(
      child: isLoading
          ? CircularProgressIndicator()
          : notes.isEmpty
          ? Text(
        'No Notes',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
          : buildNotes(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: Icon(Icons.add),
      onPressed: () async {
        if(notes.isEmpty) {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddEditNotePage(login: widget.login,)),
          );
          refreshNotes();
        }
      },
    ),
  );

  Widget buildNotes() => StaggeredGridView.countBuilder(
    padding: EdgeInsets.all(8),
    itemCount: notes.length,
    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    itemBuilder: (context, index) {
      final note = notes[index];

      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteDetailPage(noteId: 0, login: widget.login,),
          ));

          refreshNotes();
        },
        child: NoteCardWidget(note: note, index: index),
      );
    },
  );
}