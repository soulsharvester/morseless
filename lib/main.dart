import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morseless/tentacles/components/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MorselessApp());
}

class MorselessApp extends StatelessWidget {
  const MorselessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morseless',
      home: StartScreen(),
    );
  }
}