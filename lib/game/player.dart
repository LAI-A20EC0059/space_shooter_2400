import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/experimental.dart';
import 'package:flame/particles.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/player_data.dart';
import '../models/spaceship_details.dart';

import 'game.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'command.dart';
import 'audio_player_component.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame>, KeyboardHandler {

  JoystickComponent joystick;
  int _health = 100;
  int get health => _health;
  Spaceship _spaceship;
  SpaceshipType spaceshipType;
  late PlayerData _playerData;
  int get score => _playerData.currentScore;
  bool _shootMultipleBullets = false;
  late Timer _powerUpTimer;
  final _random = Random();
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Player({
    required this.joystick,
    required this.spaceshipType,
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  })  : _spaceship = Spaceship.getSpaceshipByType(spaceshipType),
        super(sprite: sprite, position: position, size: size) {
    _powerUpTimer = Timer(4, onTick: () {
      _shootMultipleBullets = false;
    });
  }

  @override
  void onMount() {
    super.onMount();
    final shape = CircleHitbox.relative(
      0.8,
      parentSize: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(shape);

    _playerData = Provider.of<PlayerData>(game.buildContext!, listen: false);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Enemy) {
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  Vector2 keyboardDelta = Vector2.zero();
  static final _keysWatched = {
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.space,
  };

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    keyboardDelta.setZero();

    if (!_keysWatched.contains(event.logicalKey)) return true;
    if (event is RawKeyDownEvent &&
        !event.repeat &&
        event.logicalKey == LogicalKeyboardKey.space) {
      // pew pew!
      joystickAction();
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      keyboardDelta.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      keyboardDelta.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      keyboardDelta.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      keyboardDelta.x = 1;
    }

    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _powerUpTimer.update(dt);

    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * _spaceship.speed * dt);
    }

    if (!keyboardDelta.isZero()) {
      position.add(keyboardDelta * _spaceship.speed * dt);
    }

    position.clamp(
      Vector2.zero() + size / 2,
      game.fixedResolution - size / 2,
    );

    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: (position.clone() + Vector2(0, size.y / 3)),
          child: CircleParticle(
            radius: 1,
            paint: Paint()..color = Colors.white,
          ),
        ),
      ),
    );

    game.world.add(particleComponent);
  }

  void joystickAction() {
    Bullet bullet = Bullet(
      sprite: game.spriteSheet.getSpriteById(28),
      size: Vector2(64, 64),
      position: position.clone(),
      level: _spaceship.level,
    );

    bullet.anchor = Anchor.center;
    game.world.add(bullet);

    game.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laserSmall_001.ogg');
    }));

    if (_shootMultipleBullets) {
      for (int i = -1; i < 2; i += 2) {
        Bullet bullet = Bullet(
          sprite: game.spriteSheet.getSpriteById(28),
          size: Vector2(64, 64),
          position: position.clone(),
          level: _spaceship.level,
        );

        bullet.anchor = Anchor.center;
        bullet.direction.rotate(i * pi / 6);
        game.world.add(bullet);
      }
    }
  }

  void addToScore(int points) {
    _playerData.currentScore += points;
    _playerData.money += points;
    _playerData.save();
  }

  void increaseHealthBy(int points) {
    _health += points;
    if (_health > 100) {
      _health = 100;
    }
  }

  void reset() {
    _playerData.currentScore = 0;
    _health = 100;
    position = game.fixedResolution / 2;
  }

  void setSpaceshipType(SpaceshipType spaceshipType) {
    spaceshipType = spaceshipType;
    _spaceship = Spaceship.getSpaceshipByType(spaceshipType);
    sprite = game.spriteSheet.getSpriteById(_spaceship.spriteId);
  }

  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _powerUpTimer.stop();
    _powerUpTimer.start();
  }
}
