import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import 'game.dart';
import 'power_ups.dart';

typedef PowerUpMap
    = Map<PowerUpTypes, PowerUp Function(Vector2 position, Vector2 size)>;

enum PowerUpTypes { health, freeze, nuke, multiFire }

class PowerUpManager extends Component with HasGameReference<SpaceShooterGame> {
  late Timer _spawnTimer;
  late Timer _freezeTimer;
  Random random = Random();
  static late Sprite nukeSprite;
  static late Sprite healthSprite;
  static late Sprite freezeSprite;
  static late Sprite multiFireSprite;
  static final PowerUpMap _powerUpMap = {
    PowerUpTypes.health: (position, size) => Health(
          position: position,
          size: size,
        ),
    PowerUpTypes.freeze: (position, size) => Freeze(
          position: position,
          size: size,
        ),
    PowerUpTypes.nuke: (position, size) => Nuke(
          position: position,
          size: size,
        ),
    PowerUpTypes.multiFire: (position, size) => MultiFire(
          position: position,
          size: size,
        ),
  };

  PowerUpManager() : super() {
    _spawnTimer = Timer(5, onTick: _spawnPowerUp, repeat: true);
    _freezeTimer = Timer(2, onTick: () {
      _spawnTimer.start();
    });
  }

  void _spawnPowerUp() {
    Vector2 initialSize = Vector2(64, 64);
    Vector2 position = Vector2(
      random.nextDouble() * game.fixedResolution.x,
      random.nextDouble() * game.fixedResolution.y,
    );

    position.clamp(
      Vector2.zero() + initialSize / 2,
      game.fixedResolution - initialSize / 2,
    );

    int randomIndex = random.nextInt(PowerUpTypes.values.length);
    final fn = _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];

    var powerUp = fn?.call(position, initialSize);

    powerUp?.anchor = Anchor.center;

    if (powerUp != null) {
      game.world.add(powerUp);
    }
  }

  @override
  void onMount() {
    _spawnTimer.start();

    healthSprite = Sprite(game.images.fromCache('icon_plusSmall.png'));
    nukeSprite = Sprite(game.images.fromCache('nuke.png'));
    freezeSprite = Sprite(game.images.fromCache('freeze.png'));
    multiFireSprite = Sprite(game.images.fromCache('multi_fire.png'));

    super.onMount();
  }

  @override
  void onRemove() {
    _spawnTimer.stop();
    super.onRemove();
  }

  @override
  void update(double dt) {
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
    super.update(dt);
  }

  void reset() {
    // Stop all the timers.
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  void freeze() {
    _spawnTimer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
