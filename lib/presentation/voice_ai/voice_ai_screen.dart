import 'package:flutter/material.dart';
import 'voice_ai_overlay.dart';

class VoiceAIScreen extends StatelessWidget {
  const VoiceAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VoiceAIOverlay(
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}