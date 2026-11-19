import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morseless/tentacles/dialogue/dialogue_model.dart';
import 'package:morseless/tentacles/dialogue/dialogue_repository.dart';
import 'package:morseless/tentacles/components/world_components.dart';

import 'components/player_components.dart';

class MorselessGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  TiledComponent? currentMap;
  late PlayerComponent player;

  int currentScene = 1;
  final Set<String> storyFlags = {};

  final ValueNotifier<bool> isTransitioning = ValueNotifier(false);
  final ValueNotifier<DialogueLine?> activeDialogue = ValueNotifier(null);
  final ValueNotifier<String?> activeJumpscare = ValueNotifier(null);
  final ValueNotifier<InteractableZone?> nearbyPrompt = ValueNotifier(null);

  List<DialogueLine> _dialogueQueue = [];

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    await Future.wait([
      images.load('Jumpscare.png'),
      FlameAudio.audioCache.load('jumpscare.wav'),
    ]);
    startSceneOneSequence();
  }

  Future<void> loadMap(String mapFileName, {required double spawnX, required double spawnY}) async {
    isTransitioning.value = true;
    overlays.add('TransitionOverlay');
    await Future.delayed(const Duration(milliseconds: 350));

    try {
      final fileName = mapFileName.endsWith('.tmx') ? mapFileName : '$mapFileName.tmx';
      final loadedMap = await TiledComponent.load(fileName, Vector2.all(32));

      world.removeAll(world.children);
      currentMap = loadedMap;
      await world.add(currentMap!);

      _parseCollisions();
      _parsePortals();
      _parseInteractables();
    } catch (e) {
      debugPrint('Map "$mapFileName" not found yet ($e). Loading fallback test room.');
      world.removeAll(world.children);
      await world.add(RectangleComponent(
        size: Vector2(640, 480),
        paint: Paint()..color = const Color(0xFF1A1A1D),
      ));
    }

    player = PlayerComponent(position: Vector2(spawnX, spawnY));
    await world.add(player);
    camera.follow(player);

    await Future.delayed(const Duration(milliseconds: 150));
    isTransitioning.value = false;
    await Future.delayed(const Duration(milliseconds: 350));
    overlays.remove('TransitionOverlay');
  }

  void _parseCollisions() {
    final group = currentMap?.tileMap.getLayer<ObjectGroup>('Collisions');
    if (group == null) return;
    for (final obj in group.objects) {
      world.add(WallHitbox(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
      ));
    }
  }

  Future<void> _showDialogueAndWait(String dialogueId) async {
    final lines = DialogueRepository.getDialogue(dialogueId);
    if (lines.isEmpty) return;

    final completer = Completer<void>();
    startDialogue(lines);

    void listener() {
      if (activeDialogue.value == null && !completer.isCompleted) {
        activeDialogue.removeListener(listener);
        completer.complete();
      }
    }

    activeDialogue.addListener(listener);
    await completer.future;
  }

  Future<void> startSceneOneSequence() async {
    await loadMap('begin.tmx', spawnX: 616, spawnY: 454);
    await Future.delayed(const Duration(seconds: 5));
    for (int i = 1; i <= 6; i++) {
      await _showDialogueAndWait('scene1_$i');
      await Future.delayed(const Duration(seconds: 2));
    }
    await _showDialogueAndWait('scene1_7');
    await Future.delayed(const Duration(milliseconds: 700));
    currentScene = 2;
    await loadMap('office_place.tmx', spawnX: 160, spawnY: 128);
    await _showDialogueAndWait('scene1_wake_office');
  }

  void _parsePortals() {
    final group = currentMap?.tileMap.getLayer<ObjectGroup>('Portals');
    if (group == null) return;

    for (final obj in group.objects) {
      final portal = PortalZone(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
        targetMap: obj.properties.getValue<String>('targetMap') ?? '',
        spawnX: (obj.properties.getValue<num>('spawnX') ?? 100).toDouble(),
        spawnY: (obj.properties.getValue<num>('spawnY') ?? 100).toDouble(),
        isLocked: obj.properties.getValue<bool>('locked') ?? false,
        lockMessage: obj.properties.getValue<String>('lockMessage'),
        minScene: obj.properties.getValue<int>('minScene'),
        maxScene: obj.properties.getValue<int>('maxScene'),
      );

      if (portal.isLocked && storyFlags.contains('has_basement_key')) {
        portal.isLocked = false;
      }

      world.add(portal);
    }
  }

  void _parseInteractables() {
    final group = currentMap?.tileMap.getLayer<ObjectGroup>('Interactables');
    if (group == null) return;

    for (final obj in group.objects) {
      final activeScene = obj.properties.getValue<int>('activeScene') ?? 0;
      if (activeScene > 0 && currentScene != activeScene) continue;

      final dialogueId = obj.properties.getValue<String>('dialogueId') ?? '';
      final autoTrigger = obj.properties.getValue<bool>('autoTrigger') ?? false;
      final spriteName = obj.properties.getValue<String>('sprite') ?? '';

      world.add(
        InteractableZone(
          dialogueId: dialogueId,
          autoTrigger: autoTrigger,
          position: Vector2(obj.x - 6, obj.y - 6),
          size: Vector2(obj.width + 12, obj.height + 12),
        ),
      );

      if (spriteName.trim().isNotEmpty) {
        world.add(
          NpcComponent(
            spriteAsset: spriteName.trim(),
            position: Vector2(obj.x, obj.y - 16),
          ),
        );
        world.add(
          WallHitbox(
            position: Vector2(obj.x + 4, obj.y + 16),
            size: Vector2(16, 14),
          ),
        );
      }
    }
  }


  void startDialogue(List<DialogueLine> lines) {
    if (lines.isEmpty) return;
    _dialogueQueue = List.from(lines);
    player.canMove = false;
    overlays.add('DialogueOverlay');
    advanceDialogue();
  }

  Future<void> advanceDialogue({String? branchDialogueId, String? optionFlag}) async {
    if (optionFlag != null) storyFlags.add(optionFlag);

    if (branchDialogueId != null) {
      _dialogueQueue = DialogueRepository.getDialogue(branchDialogueId);
    }

    if (_dialogueQueue.isEmpty) {
      activeDialogue.value = null;
      overlays.remove('DialogueOverlay');
      player.canMove = true;
      return;
    }

    final line = _dialogueQueue.removeAt(0);

    if (line.setFlag != null)
      storyFlags.add(line.setFlag!);
      if (line.setFlag == 'has_basement_key') {
        for (final portal in world.children.whereType<PortalZone>()) {
          portal.isLocked = false;
      }
    }
    if (line.setScene != null) currentScene = line.setScene!;

    if (line.triggerJumpscare) {
      await triggerJumpscare(
      imageAsset: line.jumpscareAsset,
      audioAsset: line.audioAsset,
      );
    }

    activeDialogue.value = line;

    if (line.autoTeleport != null) {
      final dest = line.autoTeleport!;
      loadMap(dest.mapName, spawnX: dest.spawnX, spawnY: dest.spawnY);
    }
  }

  Future<void> triggerJumpscare({String? imageAsset, String? audioAsset}) async {
    String validAsset = 'FLASH_FALLBACK';
    if (imageAsset != null) {
      try {
        final cleanName = imageAsset.replaceFirst('assets/images/', '');
        await images.load(cleanName);
        validAsset = cleanName;
      } catch (_) {
        validAsset = 'FLASH_FALLBACK';
      }
    }
    activeJumpscare.value = validAsset;
    overlays.add('JumpscareOverlay');

    if (audioAsset != null) {
      try {
        await FlameAudio.play(audioAsset);
      } catch (_) {
        debugPrint('Audio "$audioAsset" failed to play.');
      }
    }
    await Future.delayed(const Duration(milliseconds: 650));
    overlays.remove('JumpscareOverlay');
    activeJumpscare.value = null;
  }
}

class NpcComponent extends SpriteAnimationComponent with HasGameRef<MorselessGame> {
  final String spriteAsset;

  NpcComponent({
    required this.spriteAsset,
    required super.position,
  }) : super(size: Vector2(24, 48));

  @override
  Future<void> onLoad() async {
    try {
      final sheet = await gameRef.images.load(spriteAsset);
      animation = SpriteAnimation.fromFrameData(
        sheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.18,
          textureSize: Vector2(16, 32),
          texturePosition: Vector2(16 * 18, 0),
        ),
      );
    } catch (e) {
      debugPrint('Could not load NPC sprite $spriteAsset: $e');
    }
  }
}