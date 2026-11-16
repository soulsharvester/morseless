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
  final bool isLocked;
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
    if (isLocked && !game.storyFlags.contains('has_basement_key')) {
      return false;
    }
    if (minScene != null && game.currentScene < minScene!) return false;
    if (maxScene != null && game.currentScene > maxScene!) return false;

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

class PlayerComponent extends PositionComponent
    with HasGameRef<MorselessGame>, CollisionCallbacks, KeyboardHandler {
  bool canMove = true;
  final double speed = 115.0;
  Vector2 moveDirection = Vector2.zero();
  Vector2 _lastValidPosition = Vector2.zero();

  PlayerComponent({required super.position}) : super(size: Vector2(24, 32)) {
    add(RectangleComponent(
      size: Vector2(24, 32),
      paint: Paint()..color = Colors.blueGrey.shade200,
    ));
    add(RectangleHitbox(
      size: Vector2(18, 14),
      position: Vector2(3, 18),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!canMove || moveDirection == Vector2.zero()) return;

    _lastValidPosition = position.clone();
    position += moveDirection.normalized() * speed * dt;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!canMove) {
      moveDirection = Vector2.zero();
      return false;
    }

    moveDirection = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      moveDirection.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      moveDirection.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveDirection.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveDirection.x += 1;
    }

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyE || event.logicalKey == LogicalKeyboardKey.space)) {
      final interactable = gameRef.nearbyPrompt.value;
      if (interactable != null) {
        final lines = DialogueRepository.getDialogue(interactable.dialogueId);
        gameRef.startDialogue(lines);
      }
    }
    return true;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PortalZone && !gameRef.isTransitioning.value) {
      if (!other.canEnter(gameRef)) {
        position = _lastValidPosition;
        gameRef.startDialogue([
          DialogueLine(
            speaker: 'James',
            text: other.lockMessage ?? "I don't need to go that way right now.",
          ),
        ]);
        return;
      }
      gameRef.loadMap(other.targetMap, spawnX: other.spawnX, spawnY: other.spawnY);
    } else if (other is InteractableZone) {
      if (other.autoTrigger && !other.hasTriggered) {
        other.hasTriggered = true;
        gameRef.startDialogue(DialogueRepository.getDialogue(other.dialogueId));
      } else {
        gameRef.nearbyPrompt.value = other;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is WallHitbox) {
      position = _lastValidPosition;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other == gameRef.nearbyPrompt.value) {
      gameRef.nearbyPrompt.value = null;
    }
  }
}