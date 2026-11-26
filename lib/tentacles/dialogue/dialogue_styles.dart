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
      iconAsset: 'assets/images/alex_head.png', //just alex
      fallbackIcon: Icons.person,
      accentColor: Colors.lightBlueAccent,
    ),
    'boss': SpeakerStyle(
      backgroundColor: Color(0xEB1C1508),
      iconAsset: 'assets/images/Adam_head.png', //regular adam
      fallbackIcon: Icons.business_center,
      accentColor: Colors.amber,
    ),
    'hadel': SpeakerStyle(
      backgroundColor: Color(0xEB0B1A12),
      iconAsset: 'assets/images/hadel_head.png', //bob w brown hair
      fallbackIcon: Icons.person_outline,
      accentColor: Colors.tealAccent,
    ),
    'chan': SpeakerStyle(
      backgroundColor: Color(0xEB0B1A12),
      iconAsset: 'assets/images/Chan_head.png', //chan, adam with black hair
      fallbackIcon: Icons.person_outline,
      accentColor: Colors.tealAccent,
    ),
    'sara': SpeakerStyle(
      backgroundColor: Color(0xEB0B1A12),
      iconAsset: 'assets/images/Sara.png', //amelia
      fallbackIcon: Icons.person_outline,
      accentColor: Colors.tealAccent,
    ),
    'hamza': SpeakerStyle(
      backgroundColor: Color(0xEB0B1A12),
      iconAsset: 'assets/images/hamza_head.png', //bob
      fallbackIcon: Icons.person_outline,
      accentColor: Colors.tealAccent,
    ),
    'mitchell': SpeakerStyle(
      backgroundColor: Color(0xEB0B1A12),
      iconAsset: 'assets/images/Mitchell_head.png', //amelia high contrast
      fallbackIcon: Icons.person_outline,
      accentColor: Colors.tealAccent,
    ),
    'receptionist': SpeakerStyle(
      backgroundColor: Color(0xEB170D1F),
      iconAsset: 'assets/images/recep_head.png',  //amelia blonde
      fallbackIcon: Icons.support_agent,
      accentColor: Colors.purpleAccent,
    ),
    'man with bat': SpeakerStyle(
      backgroundColor: Color(0xEB1F0606),
      iconAsset: 'assets/images/bad_person_head.png', //alex black
      fallbackIcon: Icons.warning_amber_rounded,
      accentColor: Colors.red,
    ),
    'mother': SpeakerStyle(
      backgroundColor: Color(0xEB1A1118),
      iconAsset: 'assets/images/mother_head.png', //amelia black
      fallbackIcon: Icons.favorite_border,
      accentColor: Colors.pinkAccent,
    ),
    'banker': SpeakerStyle(
      backgroundColor: Color(0xEB0D1710),
      iconAsset: 'assets/images/banker_head.png', //bob black asian
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