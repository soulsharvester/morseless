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

enum PlayerAnimState {
  idleRight,
  idleUp,
  idleLeft,
  idleDown,
  walkRight,
  walkUp,
  walkLeft,
  walkDown,
}

enum FacingDirection { right, up, left, down }

class PlayerComponent extends SpriteAnimationGroupComponent<PlayerAnimState>
    with HasGameRef<MorselessGame>, CollisionCallbacks, KeyboardHandler {
  bool canMove = true;
  final double speed = 115.0;
  Vector2 moveDirection = Vector2.zero();
  Vector2 _lastValidPosition = Vector2.zero();
  FacingDirection facing = FacingDirection.down;

  static final Vector2 frameSize = Vector2(16, 32);

  PlayerComponent({required super.position}) : super(size: Vector2(24, 48));

  @override
  Future<void> onLoad() async {
    try {
      final idleSheet = await gameRef.images.load('Characters/Alex_idle_anim_16x16.png');
      final runSheet = await gameRef.images.load('Characters/Alex_run_16x16.png');

      animations = {
        PlayerAnimState.idleRight: SpriteAnimation.fromFrameData(
          idleSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.16,
            textureSize: frameSize,
            texturePosition: Vector2(0, 0),
          ),
        ),
        PlayerAnimState.idleUp: SpriteAnimation.fromFrameData(
          idleSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.16,
            textureSize: frameSize,
            texturePosition: Vector2(16 * 6, 0),
          ),
        ),
        PlayerAnimState.idleLeft: SpriteAnimation.fromFrameData(
          idleSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.16,
            textureSize: frameSize,
            texturePosition: Vector2(16 * 12, 0),
          ),
        ),
        PlayerAnimState.idleDown: SpriteAnimation.fromFrameData(
          idleSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.16,
            textureSize: frameSize,
            texturePosition: Vector2(16 * 18, 0),
          ),
        ),

        PlayerAnimState.walkRight: SpriteAnimation.fromFrameData(
          runSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.11,
            textureSize: frameSize,
            texturePosition: Vector2(0, 0),
          ),
        ),
        PlayerAnimState.walkUp: SpriteAnimation.fromFrameData(
          runSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.11,
            textureSize: frameSize,
            texturePosition: Vector2(16 * 6, 0),
          ),
        ),
        PlayerAnimState.walkLeft: SpriteAnimation.fromFrameData(
          runSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.11,
            textureSize: frameSize,
            texturePosition: Vector2(16 * 12, 0),
          ),
        ),
        PlayerAnimState.walkDown: SpriteAnimation.fromFrameData(
          runSheet,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.11,
            textureSize: frameSize,
            texturePosition: Vector2(16 * 18, 0),
          ),
        ),
      };

      current = PlayerAnimState.idleDown;
    } catch (e) {
      debugPrint('Failed to load Alex spritesheets ($e). Using fallback box.');
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.blueGrey.shade200,
      ));
    }

    add(RectangleHitbox(
      size: Vector2(16, 14),
      position: Vector2(4, 34),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!canMove || moveDirection == Vector2.zero()) {
      _setIdleAnimation();
      return;
    }

    if (moveDirection.x > 0) {
      facing = FacingDirection.right;
      if (animations != null) current = PlayerAnimState.walkRight;
    } else if (moveDirection.x < 0) {
      facing = FacingDirection.left;
      if (animations != null) current = PlayerAnimState.walkLeft;
    } else if (moveDirection.y < 0) {
      facing = FacingDirection.up;
      if (animations != null) current = PlayerAnimState.walkUp;
    } else if (moveDirection.y > 0) {
      facing = FacingDirection.down;
      if (animations != null) current = PlayerAnimState.walkDown;
    }

    _lastValidPosition = position.clone();
    position += moveDirection.normalized() * speed * dt;
  }

  void _setIdleAnimation() {
    if (animations == null) return;
    switch (facing) {
      case FacingDirection.right:
        current = PlayerAnimState.idleRight;
        break;
      case FacingDirection.up:
        current = PlayerAnimState.idleUp;
        break;
      case FacingDirection.left:
        current = PlayerAnimState.idleLeft;
        break;
      case FacingDirection.down:
        current = PlayerAnimState.idleDown;
        break;
    }
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