import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:space_shooter_2400/screens/create_account.dart';

import '../models/firebase.dart';
import '../widgets/overlays/pause_menu.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/game_over_menu.dart';

import '../models/player_data.dart';
import '../models/spaceship_details.dart';

import 'enemy.dart';
import 'health_bar.dart';
import 'player.dart';
import 'bullet.dart';
import 'command.dart';
import 'power_ups.dart';
import 'enemy_manager.dart';
import 'power_up_manager.dart';
import 'audio_player_component.dart';

class SpaceShooterGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final World world = World();
  late CameraComponent primaryCamera;
  late Player _player;
  late JoystickComponent joystick;
  late SpriteSheet spriteSheet;
  late EnemyManager _enemyManager;
  late PowerUpManager _powerUpManager;
  late TextComponent _playerScore;
  late TextComponent _playerHealth;
  late AudioPlayerComponent _audioPlayerComponent;
  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);
  bool _isAlreadyLoaded = false;
  Vector2 fixedResolution = Vector2(540, 960);

  final FireBase fb = FireBase();
  IDStorage idStorage = IDStorage();
  late String userID;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!_isAlreadyLoaded) {
      await images.loadAll([
        'simpleSpace_tilesheet@2.png',
        'freeze.png',
        'icon_plusSmall.png',
        'multi_fire.png',
        'nuke.png',
      ]);

      spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('simpleSpace_tilesheet@2.png'),
        columns: 8,
        rows: 6,
      );

      await add(world);
      joystick = JoystickComponent(
        anchor: Anchor.bottomLeft,
        //position: Vector2(30, fixedResolution.y - 30),
        margin: const EdgeInsets.only(left: 20, bottom: 20),
        background: CircleComponent(
          radius: 60,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
        ),
        knob: CircleComponent(radius: 30),
      );

      primaryCamera = CameraComponent.withFixedResolution(
        world: world,
        width: fixedResolution.x,
        height: fixedResolution.y,
        hudComponents: [joystick],
      )..viewfinder.position = fixedResolution / 2;
      await add(primaryCamera);

      _audioPlayerComponent = AudioPlayerComponent();
      final stars = await ParallaxComponent.load(
        [ParallaxImageData('stars1.png'), ParallaxImageData('stars2.png')],
        repeat: ImageRepeat.repeat,
        baseVelocity: Vector2(0, -50),
        velocityMultiplierDelta: Vector2(0, 1.5),
        size: fixedResolution,
      );

      const spaceshipType = SpaceshipType.canary;
      final spaceship = Spaceship.getSpaceshipByType(spaceshipType);

      _player = Player(
        joystick: joystick,
        spaceshipType: spaceshipType,
        sprite: spriteSheet.getSpriteById(spaceship.spriteId),
        size: Vector2(64, 64),
        position: fixedResolution / 2,
      );

      _player.anchor = Anchor.center;

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      _powerUpManager = PowerUpManager();

      _playerScore = TextComponent(
        text: 'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );

      _playerHealth = TextComponent(
        text: 'Health: 100%',
        position: Vector2(fixedResolution.x - 10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );

      _playerHealth.anchor = Anchor.topRight;

      final healthBar = HealthBar(
        player: _player,
        position: _playerHealth.positionOfAnchor(Anchor.topLeft),
        priority: -1,
      );

      final button = ButtonComponent(
        button: CircleComponent(
          radius: 80,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
        ),
        anchor: Anchor.bottomRight,
        position: Vector2(fixedResolution.x - 30, fixedResolution.y - 30),
        onPressed: _player.joystickAction,
      );

      await world.addAll([
        _audioPlayerComponent,
        stars,
        button,
        _player,
        _enemyManager,
        _powerUpManager,
        _playerScore,
        _playerHealth,
        healthBar,
      ]);

      _isAlreadyLoaded = false;
    idStorage.readID().then((value) => userID = value);
    }
  }

  Player get newMethod => _player;

  @override
  void onAttach() {
    if (buildContext != null) {
      final playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      _player.setSpaceshipType(playerData.spaceshipType);
    }
    _audioPlayerComponent.playBgm('9. Space Invaders.wav');
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var command in _commandList) {
      for (var component in world.children) {
        command.run(component);
      }
    }

    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    if (_player.isMounted) {
      _playerScore.text = 'Score: ${_player.score}';
      _playerHealth.text = 'Health: ${_player.health}%';

      if (_player.health <= 0) {
        pauseEngine();
        fb.updateScore(userID, _player.score);
        overlays.remove(PauseButton.id);
        overlays.add(GameOverMenu.id);
      }
    } 
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }

    super.lifecycleStateChange(state);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();

    world.children.whereType<Enemy>().forEach((enemy) {
      enemy.removeFromParent();
    });

    world.children.whereType<Bullet>().forEach((bullet) {
      bullet.removeFromParent();
    });

    world.children.whereType<PowerUp>().forEach((powerUp) {
      powerUp.removeFromParent();
    });
  }
}
