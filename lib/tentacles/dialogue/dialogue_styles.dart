import 'package:flutter/material.dart';

class SpeakerStyle {
  final Color backgroundColor;
  final String? iconAsset;
  final IconData fallbackIcon;
  final Color accentColor;

  const SpeakerStyle({
    required this.backgroundColor,
    this.iconAsset,
    this.fallbackIcon = Icons.person,
    this.accentColor = Colors.redAccent,
  });
}

class DialogueStyles {
  static const SpeakerStyle defaultStyle = SpeakerStyle(
    backgroundColor: Color(0xEB000000),
    fallbackIcon: Icons.chat_bubble_outline,
    accentColor: Colors.redAccent,
  );

  static const Map<String, SpeakerStyle> bySpeaker = {
    'unknown': SpeakerStyle(
      backgroundColor: Color(0xEB1A0508),
      iconAsset: 'assets/images/icons/unknown.png',
      fallbackIcon: Icons.visibility_off,
      accentColor: Colors.redAccent,
    ),
    'james': SpeakerStyle(
      backgroundColor: Color(0xEB09121C),
      iconAsset: 'assets/images/alex_head.png',
      fallbackIcon: Icons.person,
      accentColor: Colors.lightBlueAccent,
    ),
    'boss': SpeakerStyle(
      backgroundColor: Color(0xEB1C1508),
      iconAsset: 'assets/images/icons/boss.png',
      fallbackIcon: Icons.business_center,
      accentColor: Colors.amber,
    ),
    'hadel': SpeakerStyle(
      backgroundColor: Color(0xEB0B1A12),
      iconAsset: 'assets/images/icons/hadel.png',
      fallbackIcon: Icons.person_outline,
      accentColor: Colors.tealAccent,
    ),
    'receptionist': SpeakerStyle(
      backgroundColor: Color(0xEB170D1F),
      iconAsset: 'assets/images/icons/receptionist.png',
      fallbackIcon: Icons.support_agent,
      accentColor: Colors.purpleAccent,
    ),
    'man with bat': SpeakerStyle(
      backgroundColor: Color(0xEB1F0606),
      iconAsset: 'assets/images/icons/man_with_bat.png',
      fallbackIcon: Icons.warning_amber_rounded,
      accentColor: Colors.red,
    ),
    'mother': SpeakerStyle(
      backgroundColor: Color(0xEB1A1118),
      iconAsset: 'assets/images/icons/mother.png',
      fallbackIcon: Icons.favorite_border,
      accentColor: Colors.pinkAccent,
    ),
    'banker': SpeakerStyle(
      backgroundColor: Color(0xEB0D1710),
      iconAsset: 'assets/images/icons/banker.png',
      fallbackIcon: Icons.account_balance,
      accentColor: Colors.greenAccent,
    ),
    'narrator': SpeakerStyle(
      backgroundColor: Color(0xEB101014),
      iconAsset: 'assets/images/icons/narrator.png',
      fallbackIcon: Icons.auto_stories,
      accentColor: Colors.white70,
    ),
  };

  static SpeakerStyle forSpeaker(String speaker) {
    return bySpeaker[speaker.trim().toLowerCase()] ?? defaultStyle;
  }
}