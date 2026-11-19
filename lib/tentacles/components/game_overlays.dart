import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../dialogue/dialogue_model.dart';
import '../morseless_game.dart';


class MorselessGameScreen extends StatefulWidget {
  const MorselessGameScreen({super.key});

  @override
  State<MorselessGameScreen> createState() => _MorselessGameScreenState();
}

class _MorselessGameScreenState extends State<MorselessGameScreen> {
  late final MorselessGame _game;

  @override
  void initState() {
    super.initState();
    _game = MorselessGame();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<MorselessGame>(
          game: _game,
          overlayBuilderMap: {
            'TransitionOverlay': (context, game) {
              return ValueListenableBuilder<bool>(
                valueListenable: game.isTransitioning,
                builder: (context, fadingOut, _) {
                  return AnimatedOpacity(
                    opacity: fadingOut ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(color: Colors.black),
                  );
                },
              );
            },
            'DialogueOverlay': (context, game) {
              return ValueListenableBuilder<DialogueLine?>(
                valueListenable: game.activeDialogue,
                builder: (context, line, _) {
                  if (line == null) return const SizedBox.shrink();
                  final hasOptions = line.options != null && line.options!.isNotEmpty;

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasOptions)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.92),
                                border: Border.all(color: Colors.white70, width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: line.options!.map((option) {
                                  return InkWell(
                                    onTap: () {
                                      game.advanceDialogue(
                                        branchDialogueId: option.nextDialogueId,
                                        optionFlag: option.setFlag,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        '> ${option.text}',
                                        style: const TextStyle(
                                          color: Colors.amberAccent,
                                          fontFamily: 'Courier',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          GestureDetector(
                            onTap: hasOptions ? null : () => game.advanceDialogue(),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.92),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.speaker.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontFamily: 'Courier',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    line.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Courier',
                                      fontSize: 17,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (!hasOptions)
                                    const Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        '▼',
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            'JumpscareOverlay': (context, game) {
              return ValueListenableBuilder<String?>(
                valueListenable: game.activeJumpscare,
                builder: (context, assetName, _) {
                  if (assetName == null) return const SizedBox.shrink();
                  if (assetName == 'FLASH_FALLBACK') {
                    return Container(color: Colors.red.withOpacity(0.85));
                  }
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: SizedBox(
                        width: 650,
                        height: 500,
                        child: SpriteAnimationWidget.asset(
                          path: assetName,
                          data: SpriteAnimationData.sequenced(
                            amount: 24,
                            stepTime: 0.025,
                            textureSize: Vector2(325, 250),
                            loop: false,
                          ),
                          images: game.images,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          },
        ),
      ),
    );
  }
}