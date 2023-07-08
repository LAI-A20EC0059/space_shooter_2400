import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import 'spaceship_details.dart';

part 'player_data.g.dart';

@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  static const String playerDataBox = 'PlayerDataBox';
  static const String playerDataKey = 'PlayerData';

  @HiveField(0)
  SpaceshipType spaceshipType;

  @HiveField(1)
  final List<SpaceshipType> ownedSpaceships;

  @HiveField(2)
  late int _highScore;
  int get highScore => _highScore;

  @HiveField(3)
  int money;
  int _currentScore = 0;
  int get currentScore => _currentScore;

  set currentScore(int newScore) {
    _currentScore = newScore;

    if (_highScore < _currentScore) {
      _highScore = _currentScore;
    }
  }

  PlayerData({
    required this.spaceshipType,
    required this.ownedSpaceships,
    int highScore = 0,
    required this.money,
  }) {
    _highScore = highScore;
  }

  PlayerData.fromMap(Map<String, dynamic> map)
      : spaceshipType = map['currentSpaceshipType'],
        ownedSpaceships = map['ownedSpaceshipTypes']
            .map((e) => e as SpaceshipType)
            .cast<SpaceshipType>()
            .toList(), 
        _highScore = map['highScore'],
        money = map['money'];

  static Map<String, dynamic> defaultData = {
    'currentSpaceshipType': SpaceshipType.canary,
    'ownedSpaceshipTypes': [SpaceshipType.canary],
    'highScore': 0,
    'money': 0,
  };

  bool isOwned(SpaceshipType spaceshipType) {
    return ownedSpaceships.contains(spaceshipType);
  }

  bool canBuy(SpaceshipType spaceshipType) {
    return (money >= Spaceship.getSpaceshipByType(spaceshipType).cost);
  }

  bool isEquipped(SpaceshipType spaceshipType) {
    return (this.spaceshipType == spaceshipType);
  }

  void buy(SpaceshipType spaceshipType) {
    if (canBuy(spaceshipType) && (!isOwned(spaceshipType))) {
      money -= Spaceship.getSpaceshipByType(spaceshipType).cost;
      ownedSpaceships.add(spaceshipType);
      notifyListeners();

      save();
    }
  }

  void equip(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    notifyListeners();

    save();
  }
}
