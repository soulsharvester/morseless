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
  final ValueNotifier<SpriteAnimation?> activeJumpscareAnimation = ValueNotifier(null);
  final ValueNotifier<DialogueLine?> activeDialogue = ValueNotifier(null);
  final ValueNotifier<String?> activeJumpscare = ValueNotifier(null);
  final ValueNotifier<InteractableZone?> nearbyPrompt = ValueNotifier(null);
  final ValueNotifier<SpriteAnimation?> activeCutsceneAnimation = ValueNotifier(null);
  final ValueNotifier<SpriteAnimation?> activeCutsceneCharacter = ValueNotifier(null);

  List<DialogueLine> _dialogueQueue = [];
  static const double defaultZoom = 3.0;

  Future<void> onMapLoaded(String mapFileName) async {}
  Future<void> onMapReady(String mapFileName) async {}

  Future<void> loadMap(String mapFileName, {required double spawnX, required double spawnY}) async {
    isTransitioning.value = true;
    overlays.add('TransitionOverlay');
    await Future.delayed(const Duration(milliseconds: 350));

    final fileName = mapFileName.endsWith('.tmx') ? mapFileName : '$mapFileName.tmx';
    try {
      final loadedMap = await TiledComponent.load(fileName, Vector2.all(32));

      world.removeAll(world.children);
      currentMap = loadedMap;
      await world.add(currentMap!);

      _parseCollisions();
      _parsePortals();
      _parseInteractables();
      await spawnNpcsForMap(fileName);
      await onMapLoaded(fileName);
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
    camera.viewfinder.zoom = defaultZoom;

    await Future.delayed(const Duration(milliseconds: 150));
    isTransitioning.value = false;
    await Future.delayed(const Duration(milliseconds: 350));
    overlays.remove('TransitionOverlay');
    await onMapReady(fileName);
  }

  Future<void> spawnNpcsForMap(String mapName) async {
    world.children.whereType<NpcComponent>().forEach((npc) => npc.removeFromParent());

    if (mapName == 'office_place.tmx') {
      //Sara
      await spawnNpc(
        spriteAsset: 'Characters/Amelia_idle_anim_16x16.png',
        position: Vector2(873, 261),
        dialogueId: 'scene2_sara',
      );
      //Hamza
      await spawnNpc(
        spriteAsset: 'Characters/Bob_idle_anim_16x16.png',
        position: Vector2(941, 757),
        dialogueId: 'scene2_hamza',
      );
      //Chan
      await spawnNpc(
        spriteAsset: 'Chan.png',
        position: Vector2(120, 260),
        dialogueId: 'scene2_chan',
      );
      //Mitchell
      await spawnNpc(
        spriteAsset: 'Mitchell.png',
        position: Vector2(335, 750),
        dialogueId: 'scene2_mitchell',
      );
    }
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

  Future<void> showDialogueAndWait(String dialogueId) async {
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

  Future<void> spawnGridNpc({
    required String spriteAsset,
    required Vector2 position,
    required String dialogueId,
    required int startCol,
    required int startRow,
    int gridCols = 12,
    int gridRows = 8,
    int amount = 3,
    double stepTime = 0.22,
    bool autoTrigger = false,
  }) async {
    await world.addAll([
      NpcComponent(
        spriteAsset: spriteAsset,
        position: position,
        amount: amount,
        stepTime: stepTime,
      ),
      WallHitbox(
        position: Vector2(position.x - 8, position.y),
        size: Vector2(24, 30),
      ),
      InteractableZone(
        dialogueId: dialogueId,
        autoTrigger: autoTrigger,
        position: Vector2(position.x - 18, position.y - 18),
        size: Vector2(36, 36),
      ),
    ]);
  }

  Future<void> _playReceptionEntryJumpscare({
    required String sheetAsset,
    String? audioAsset,
    int frameCount = 48,
    double stepTime = 0.08,
    Vector2? frameSize,
  }) async {
    try {
      final sheet = await images.load(sheetAsset);
      final resolvedFrameSize = frameSize ??
          Vector2(
            sheet.width / frameCount,
            sheet.height.toDouble(),
          );

      final anim = SpriteAnimation.fromFrameData(
        sheet,
        SpriteAnimationData.sequenced(
          amount: frameCount,
          amountPerRow: 8,
          stepTime: stepTime,
          textureSize: resolvedFrameSize,
          loop: false,
        ),
      );

      activeJumpscareAnimation.value = anim;
      overlays.add('ReceptionJumpscareOverlay');

      if (audioAsset != null && audioAsset.isNotEmpty) {
        try {
          await FlameAudio.play(audioAsset);
        } catch (_) {
          debugPrint('Audio "$audioAsset" failed to play.');
        }
      }

      final totalDurationMs = (frameCount * stepTime * 1000).round().clamp(250, 5000);
      await Future.delayed(Duration(milliseconds: totalDurationMs));
    } catch (e) {
      debugPrint('Failed to load reception jumpscare sheet "$sheetAsset": $e');
    } finally {
      overlays.remove('ReceptionJumpscareOverlay');
      activeJumpscareAnimation.value = null;
    }
  }

  Future<void> spawnNpc({
    required String spriteAsset,
    required Vector2 position,
    required String dialogueId,
    int amount = 6,
    double stepTime = 0.16,
    Vector2? frameSize,
    Vector2? texturePosition,
    bool autoTrigger = false,
  }) async {
    await world.addAll([
      NpcComponent(
        spriteAsset: spriteAsset,
        position: position,
        amount: amount,
        stepTime: stepTime,
        frameSize: frameSize,
        texturePosition: texturePosition,
      ),
      WallHitbox(
        position: Vector2(position.x - 8, position.y + 10),
        size: Vector2(16, 14),
      ),
      InteractableZone(
        dialogueId: dialogueId,
        autoTrigger: autoTrigger,
        position: Vector2(position.x - 24, position.y - 6),
        size: Vector2(48, 46),
      ),
    ]);
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

  bool isCutsceneActive = false;

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
      if (!isCutsceneActive) {
        player.canMove = true;
      }
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
    await Future.delayed(const Duration(milliseconds: 250));
    overlays.remove('JumpscareOverlay');
    activeJumpscare.value = null;
  }
}

class NpcComponent extends SpriteAnimationComponent with HasGameRef<MorselessGame> {
  final String spriteAsset;
  final int amount;
  final double stepTime;
  final Vector2 frameSize;
  final Vector2 texturePosition;
  final bool loop;

  NpcComponent({
    required this.spriteAsset,
    required super.position,
    this.amount = 6,
    this.stepTime = 0.16,
    Vector2? frameSize,
    Vector2? texturePosition,
    this.loop = true,
  })  : frameSize = frameSize ?? Vector2(16, 32),
        texturePosition = texturePosition ?? Vector2(16 * 18, 0),
        super(size: Vector2(24, 48), anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    try {
      final sheet = await gameRef.images.load(spriteAsset);
      animation = SpriteAnimation.fromFrameData(
        sheet,
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: texturePosition,
          loop: loop,
        ),
      );
    } catch (e) {
      debugPrint('Could not load NPC sprite $spriteAsset: $e');
    }
  }
}