import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../morseless_game.dart';

class PortalZone extends PositionComponent {
  final String targetMap;
  final double spawnX;
  final double spawnY;
  bool isLocked;
  final String? lockMessage;
  final int? minScene;
  final int? maxScene;

  PortalZone({
    required super.position,
    required super.size,
    required this.targetMap,
    required this.spawnX,
    required this.spawnY,
    this.isLocked = false,
    this.lockMessage,
    this.minScene,
    this.maxScene,
  }) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  bool canEnter(MorselessGame game) {
    if (isLocked) return false;
    if (minScene != null && minScene! > 0 && game.currentScene < minScene!) return false;
    if (maxScene != null && maxScene! > 0 && game.currentScene > maxScene!) return false;
    return true;
  }
}