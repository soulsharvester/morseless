import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:morseless/tentacles/morseless_game.dart';
import 'package:flutter/foundation.dart';

class MorselessDialogueExec extends MorselessGame {
  static final Vector2 bossDeskPosition = Vector2(1133, 506);
  bool _receptionDialoguePending = false;
  static final Vector2 receptionistPosition = Vector2(873, 261);


  static const String bossIdleAsset = 'Characters/Adam_idle_anim_16x16.png';
  static const String bossWalkAsset = 'Characters/Adam_run_16x16.png';
  static final Vector2 characterFrameSize = Vector2(16, 32);
  static final Vector2 characterRenderSize = Vector2(24, 48);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = MorselessGame.defaultZoom;
    await Future.wait([
      images.load('Jumpscare.png'),
      images.load('office.png'),
      images.load(bossIdleAsset),
      images.load(bossWalkAsset),
      images.load('receptiongrid.png'),
      FlameAudio.audioCache.load('jumpscare.wav'),
    ]);
    startSceneOneSequence();
  }

  @override
  Future<void> startSceneOneSequence() async {
    await loadMap('begin.tmx', spawnX: 616, spawnY: 454);
    await Future.delayed(const Duration(seconds: 5));
    for (int i = 1; i <= 6; i++) {
      await showDialogueAndWait('scene1_$i');
      await Future.delayed(const Duration(seconds: 2));
    }
    await showDialogueAndWait('scene1_7');
    await Future.delayed(const Duration(milliseconds: 700));
    currentScene = 2;
    await loadMap('office_place.tmx', spawnX: 297, spawnY: 351);
    await _runSceneTwoOfficeCutsceneAndWalk();

  }

  Future<void> _runSceneTwoOfficeCutsceneAndWalk() async {
    isCutsceneActive = true;
    player.canMove = false;
    player.moveDirection = Vector2.zero();

    final officeSheet = await images.load('office.png');
    final officeAnim = SpriteAnimation.fromFrameData(
      officeSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.16,
        textureSize: Vector2(
          officeSheet.width / 6,
          officeSheet.height.toDouble(),
        ),
        loop: true,
      ),
    );

    activeCutsceneAnimation.value = officeAnim;
    activeCutsceneCharacter.value = await _createBossCutsceneAnimation(
      texturePosition: Vector2(16 * 18, 0),
    );
    overlays.add('CutsceneOverlay');

    await showDialogueAndWait('scene1_wake_office');
    await showDialogueAndWait('scene2_boss');

    activeCutsceneCharacter.value = null;
    activeCutsceneAnimation.value = null;
    overlays.remove('CutsceneOverlay');

    final walkingBoss = NpcComponent(
      spriteAsset: bossWalkAsset,
      position: Vector2(140, 600),
      amount: 6,
      stepTime: 0.11,
      frameSize: characterFrameSize,
      texturePosition: Vector2(16 * 12, 0),
    );

    await world.add(walkingBoss);
    _walkComponentTo(walkingBoss, bossDeskPosition, speed: 65.0);
    walkingBoss.removeFromParent();

    await spawnNpc(
      spriteAsset: bossIdleAsset,
      position: bossDeskPosition,
      dialogueId: 'scene2_boss',
      amount: 6,
      stepTime: 0.16,
      frameSize: characterFrameSize,
      texturePosition: Vector2(16 * 18, 0),
    );

    isCutsceneActive = false;
    player.canMove = true;
  }

  @override
  Future<void> spawnNpcsForMap(String mapName) async {
    await super.spawnNpcsForMap(mapName);
    if (mapName == 'reception.tmx' &&
        storyFlags.contains('entered_reception_first_time')) {
      await _spawnReceptionist();
    }
  }

  @override
  Future<void> onMapLoaded(String mapFileName) async {
    if (mapFileName == 'reception.tmx' &&
        !storyFlags.contains('entered_reception_first_time')) {
      storyFlags.add('entered_reception_first_time');

      await _spawnReceptionist();
      _receptionDialoguePending = true;

      await playReceptionEntryJumpscare(
        sheetAsset: 'receptiongrid.png',
        audioAsset: 'jumpscare_1.wav',
        frameCount: 48,
        columns: 8,
        stepTime: 0.03,
        frameSize: Vector2(800, 640),
      );
    }
  }

  @override
  Future<void> onMapReady(String mapFileName) async {
    if (!_receptionDialoguePending) return;
    _receptionDialoguePending = false;

    player.canMove = false;
    await Future.delayed(const Duration(milliseconds: 1200));
    await showDialogueAndWait('scene3_receptionist');
  }

  Future<void> _spawnReceptionist() => spawnNpc(
    spriteAsset: 'recep.png',
    position: receptionistPosition,
    dialogueId: 'scene3_receptionist',
  );

  Future<void> playReceptionEntryJumpscare({
    required String sheetAsset,
    String? audioAsset,
    int frameCount = 48,
    int columns = 8,
    double stepTime = 0.03,
    required Vector2 frameSize,
  }) async {
    try {
      final sheet = await images.load(sheetAsset);
      debugPrint('Jumpscare sheet loaded: ${sheet.width} x ${sheet.height}');

      final anim = SpriteAnimation.fromFrameData(
        sheet,
        SpriteAnimationData.sequenced(
          amount: frameCount,
          amountPerRow: columns,
          stepTime: stepTime,
          textureSize: frameSize,
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

      final totalMs = (frameCount * stepTime * 1000).round();
      await Future.delayed(Duration(milliseconds: totalMs));
    } catch (e) {
      debugPrint('Failed to load reception jumpscare sheet "$sheetAsset": $e');
    } finally {
      overlays.remove('ReceptionJumpscareOverlay');
      activeJumpscareAnimation.value = null;
    }
  }

  Future<SpriteAnimation> _createBossCutsceneAnimation({
    required Vector2 texturePosition,
  }) async {
    final sheet = await images.load(bossIdleAsset);
    return SpriteAnimation.fromFrameData(
      sheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.16,
        textureSize: characterFrameSize,
        texturePosition: texturePosition,
      ),
    );
  }

  Future<void> _walkComponentTo(
      PositionComponent target,
      Vector2 destination, {
        required double speed,
      }) async {
    final completer = Completer<void>();
    late TimerComponent walker;

    walker = TimerComponent(
      period: 1 / 60,
      repeat: true,
      onTick: () {
        if (!target.isMounted) {
          walker.removeFromParent();
          if (!completer.isCompleted) completer.complete();
          return;
        }

        final delta = destination - target.position;
        final distance = delta.length;
        final step = speed * (1 / 60);

        if (distance <= step) {
          target.position = destination.clone();
          walker.removeFromParent();
          if (!completer.isCompleted) completer.complete();
          return;
        }

        target.position += delta.normalized() * step;
      },
    );

    await world.add(walker);
    await completer.future;
  }
}