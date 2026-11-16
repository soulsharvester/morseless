import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morseless/tentacles/dialogue/dialogue_model.dart';
import 'package:morseless/tentacles/dialogue/dialogue_repository.dart';
import 'package:morseless/tentacles/components/world_components.dart';

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

    await loadMap('darkness.tmx', spawnX: 160, spawnY: 160);
  }

  Future<void> loadMap(String mapFileName, {required double spawnX, required double spawnY}) async {
    isTransitioning.value = true;
    overlays.add('TransitionOverlay');
    await Future.delayed(const Duration(milliseconds: 350));

    try {
      final loadedMap = await TiledComponent.load(mapFileName, Vector2.all(32));

      world.removeAll(world.children);
      currentMap = loadedMap;
      await world.add(currentMap!);

      _parseCollisions();
      _parsePortals();
      _parseInteractables();
    } catch (e) {
      debugPrint('⚠️ Map "$mapFileName" not found yet ($e). Loading fallback test room.');
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

  void _parsePortals() {
    final group = currentMap?.tileMap.getLayer<ObjectGroup>('Portals');
    if (group == null) return;
    for (final obj in group.objects) {
      world.add(PortalZone(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
        targetMap: obj.properties.getValue<String>('targetMap') ?? '',
        spawnX: (obj.properties.getValue<num>('spawnX') ?? 100).toDouble(),
        spawnY: (obj.properties.getValue<num>('spawnY') ?? 100).toDouble(),
        isLocked: obj.properties.getValue<bool>('locked') ?? false,
        lockMessage: obj.properties.getValue<String>('lockMessage'),
        minScene: obj.properties.getValue<int>('minScene'),
        maxScene: obj.properties.getValue<int>('maxScene'),
      ));
    }
  }

  void _parseInteractables() {
    final group = currentMap?.tileMap.getLayer<ObjectGroup>('Interactables');
    if (group == null) return;
    for (final obj in group.objects) {
      world.add(InteractableZone(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
        dialogueId: obj.properties.getValue<String>('dialogueId') ?? '',
        autoTrigger: obj.properties.getValue<bool>('autoTrigger') ?? false,
      ));
    }
  }


  void startDialogue(List<DialogueLine> lines) {
    if (lines.isEmpty) return;
    _dialogueQueue = List.from(lines);
    player.canMove = false;
    overlays.add('DialogueOverlay');
    advanceDialogue();
  }

  void advanceDialogue({String? branchDialogueId, String? optionFlag}) {
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

    if (line.setFlag != null) storyFlags.add(line.setFlag!);
    if (line.setScene != null) currentScene = line.setScene!;

    activeDialogue.value = line;

    if (line.triggerJumpscare) {
      triggerJumpscare(imageAsset: line.jumpscareAsset, audioAsset: line.audioAsset);
    }

    if (line.autoTeleport != null) {
      final dest = line.autoTeleport!;
      loadMap(dest.mapName, spawnX: dest.spawnX, spawnY: dest.spawnY);
    }
  }

  Future<void> triggerJumpscare({String? imageAsset, String? audioAsset}) async {
    if (audioAsset != null) {
      try {
        await FlameAudio.play(audioAsset);
      } catch (_) {
        debugPrint('⚠️ Audio "$audioAsset" not added yet — skipping audio.');
      }
    }

    String? validAsset;
    if (imageAsset != null) {
      try {
        await rootBundle.load(imageAsset);
        validAsset = imageAsset;
      } catch (_) {
        debugPrint('⚠️ Jumpscare image "$imageAsset" not added yet — using flash fallback.');
        validAsset = 'FLASH_FALLBACK';
      }
    } else {
      validAsset = 'FLASH_FALLBACK';
    }

    activeJumpscare.value = validAsset;
    overlays.add('JumpscareOverlay');
    await Future.delayed(const Duration(milliseconds: 1100));
    overlays.remove('JumpscareOverlay');
    activeJumpscare.value = null;
  }
}