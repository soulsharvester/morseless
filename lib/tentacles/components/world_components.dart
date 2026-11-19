import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialogue/dialogue_model.dart';
import '../dialogue/dialogue_repository.dart';
import '../morseless_game.dart';

class WallHitbox extends PositionComponent {
  WallHitbox({required super.position, required super.size}) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}

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

class InteractableZone extends PositionComponent {
  final String dialogueId;
  final bool autoTrigger;
  bool hasTriggered = false;

  InteractableZone({
    required super.position,
    required super.size,
    required this.dialogueId,
    required this.autoTrigger,
  }) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
