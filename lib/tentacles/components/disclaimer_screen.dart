import 'dart:async';
import 'package:flutter/material.dart';
import 'game_overlays.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  static const String disclaimerAsset = 'assets/images/disclaimer.png';

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  Timer? _autoProceedTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _autoProceedTimer = Timer(const Duration(milliseconds: 4500), _enterGame);
  }

  void _enterGame() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _autoProceedTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MorselessGameScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _autoProceedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _enterGame,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              DisclaimerScreen.disclaimerAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CONTENT WARNING',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Courier',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'This game depicts themes of severe paranoia, hallucinations, psychological distress, and disturbing imagery.\n\n[Tap anywhere to continue]',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Courier',
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}