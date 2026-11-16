import 'package:flutter/foundation.dart';

class DialogueOption {
  final String text;
  final String? nextDialogueId;
  final String? setFlag;

  DialogueOption({
    required this.text,
    this.nextDialogueId,
    this.setFlag,
  });
}

class DialogueLine {
  final String speaker;
  final String text;
  final List<DialogueOption>? options;
  final bool triggerJumpscare;
  final String? jumpscareAsset;
  final String? audioAsset;
  final String? setFlag;
  final int? setScene;
  final MapTransitionTarget? autoTeleport;

  DialogueLine({
    required this.speaker,
    required this.text,
    this.options,
    this.triggerJumpscare = false,
    this.jumpscareAsset,
    this.audioAsset,
    this.setFlag,
    this.setScene,
    this.autoTeleport,
  });
}

class MapTransitionTarget {
  final String mapName;
  final double spawnX;
  final double spawnY;

  const MapTransitionTarget(this.mapName, this.spawnX, this.spawnY);
}