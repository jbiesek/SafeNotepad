Safe Notepad written in Flutter.
You can authenticate via password or fingerprint.
Password is hashed with SHA512 and storred in FlutterSecureStorage.
Note is encryted with Salsa20 algorithm, using random 32-bit key and random 8-bit initial vector.
Note is also stored in FlutterSecureStorage.
