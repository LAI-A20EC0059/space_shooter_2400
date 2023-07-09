import 'package:flutter/material.dart';
import 'package:space_shooter_2400/screens/create_account.dart';

import '../models/firebase.dart';
import 'settings_menu.dart';
import 'select_spaceship.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final FireBase fb = FireBase();
  final IDStorage idStorage = IDStorage();
  late String _username = "";
  bool newUser = true;

  @override
  void initState() {
    super.initState();
    idStorage.readID().then((String value) {
      if (value != "") {
        fb.getNameByID(value).then((String username) {
          setState(() {
            _username = username;
            newUser = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                'Space\nShooter\n2400',
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
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  if (newUser) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CreateAccount(),
                      ),
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectSpaceship(username: _username),
                      ),
                    );
                  }
                },
                child: const Text('Play'),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsMenu(),
                    ),
                  );
                },
                child: const Text('Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
