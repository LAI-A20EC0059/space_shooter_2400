import 'package:flutter/material.dart';
import 'package:space_shooter_2400/screens/create_account.dart';

import 'settings_menu.dart';
import 'select_spaceship.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

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
                  IDStorage storage = IDStorage();
                  //storage.writeID("0");
                  storage.readID().then((String value) {
                    if (value==""||value=="0") {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => CreateAccount(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SelectSpaceship(),
                        ),
                      );
                    }
                  });
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
