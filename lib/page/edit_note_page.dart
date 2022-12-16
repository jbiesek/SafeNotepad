import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:bsm_project/model/note.dart';
import 'package:bsm_project/widget/note_form_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

class AddEditNotePage extends StatefulWidget {
  final Note? note;
  final String? login;

  const AddEditNotePage({
    Key? key,
    this.note,
    required this.login,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late int number;
  late String title;
  late String description;
  final _storage = const FlutterSecureStorage();


  @override
  void initState() {
    super.initState();
    number = widget.note?.number ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: NoteFormWidget(
        number: number,
        title: title,
        description: description,
        onChangedNumber: (number) => setState(() => this.number = number),
        onChangedTitle: (title) => setState(() => this.title = title),
        onChangedDescription: (description) =>
            setState(() => this.description = description),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      number: number,
      title: title,
      description: description,
    );
    var loginBytes = utf8.encode(widget.login!);
    var _login = sha512.convert(loginBytes).toString();
    var _value = json.encode(note.toJson());
    await _storage.delete(key: _login);
    final key = enc.Key.fromSecureRandom(32);
    final iv = enc.IV.fromSecureRandom(8);
    final encrypter = enc.Encrypter(enc.Salsa20(key));
    var data = jsonEncode({"key": key.base64, "iv": iv.base64});
    var _loginBytes = utf8.encode(_login);
    var login = sha512.convert(_loginBytes).toString();
    await _storage.write(key: login, value: data);
    final encrypted = encrypter.encrypt(_value, iv: iv);
    await _storage.write(key: _login, value: encrypted.base64);
  }

  Future addNote() async {
    final note = Note(
      title: title,
      number: number,
      description: description,
    );
    var loginBytes = utf8.encode(widget.login!);
    var _login = sha512.convert(loginBytes).toString();
    var _value = json.encode(note.toJson());
    final key = enc.Key.fromSecureRandom(32);
    final iv = enc.IV.fromSecureRandom(8);
    final encrypter = enc.Encrypter(enc.Salsa20(key));
    var data = jsonEncode({"key": key.base64, "iv": iv.base64});
    var _loginBytes = utf8.encode(_login);
    var login = sha512.convert(_loginBytes).toString();
    await _storage.write(key: login, value: data);
    final encrypted = encrypter.encrypt(_value, iv: iv);
    await _storage.write(key: _login, value: encrypted.base64);
  }
}