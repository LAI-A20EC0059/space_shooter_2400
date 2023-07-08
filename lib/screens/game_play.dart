import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter_2400/widgets/overlays/game_over_menu.dart';

import '../game/game.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/pause_menu.dart';

SpaceShooterGame _spaceshooterGame = SpaceShooterGame();

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: GameWidget(
          game: _spaceshooterGame,
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, SpaceShooterGame game) =>
                PauseButton(
                  game: game,
                ),
            PauseMenu.id: (BuildContext context, SpaceShooterGame game) =>
                PauseMenu(
                  game: game,
                ),
            GameOverMenu.id: (BuildContext context, SpaceShooterGame game) =>
                GameOverMenu(
                  game: game,
                ),
          },
        ),
      ),
    );
  }
}
