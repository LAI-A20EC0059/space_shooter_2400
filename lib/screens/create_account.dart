import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:space_shooter_2400/models/firebase.dart';

import '../models/account.dart';
import 'select_spaceship.dart';
import 'dart:async';
import 'dart:io';

class IDStorage {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/ID.txt');
  }

  Future<String> readID() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<File> writeID(String id) async {
    final file = await _localFile;
    return file.writeAsString('$id');
  }
}

class CreateAccount extends StatefulWidget {
  CreateAccount({Key? key}) : super(key: key);
  final IDStorage storage = IDStorage();

  @override
  State<StatefulWidget> createState() => _StatefulTextField();
}

class _StatefulTextField extends State<CreateAccount> {
  late FocusNode _focusNode;
  bool _focused = false;
  String _name = "What should we call you?";
  final _formKey = GlobalKey<FormState>();
  String _errorText = "";
  String _id = "0";

  FireBase fb = FireBase();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'TextField');
    _focusNode.addListener(_handleFocusChange);
    widget.storage.readID().then((String value) {
      setState(() {
        _id = value;
      });
    });
  }

  Future<File> saveIDToLocalDir(String value) {
    _id = value;
    return widget.storage.writeID(_id);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() {
        _focused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (_focused) {
            _focusNode.unfocus();
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          } else {
            _focusNode.requestFocus();
          }
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Text(
                    'Hi There!\nNew Player!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50.0,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          blurRadius: 20.0,
                          color: Colors.white,
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        filled: _focused ? false : true,
                        fillColor: Colors.blue,
                        border: const OutlineInputBorder(),
                        hintText: _name,
                      ),
                      focusNode: _focusNode,
                      autofocus: true,
                      validator: (value) {
                        if (value == "" || value == null) {
                          _errorText = "You deserve a name";
                          return _errorText;
                        } else {
                          _name = value;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: ElevatedButton(
                    onPressed: () {
                      SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersiveSticky);
                      if (_formKey.currentState!.validate()) {
                        fb.addAccountByName(_name);
                        fb
                            .getIDByName(_name)
                            .then((String value) => saveIDToLocalDir(value));
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SelectSpaceship(),
                          ),
                        );
                      } else {
                        null;
                      }
                    },
                    child: const Text('Let\'s Rock'),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
