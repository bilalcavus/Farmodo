import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

final class PlayerConfig {
  
  final player = AudioPlayer();

  void configAudioPlayer(){
    player.setReleaseMode(ReleaseMode.stop);
    player.setVolume(1.0);
    if (Platform.isAndroid) {
      player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    }
  }
   
  Future<void> playCompletionSound() async {
    try {
      await player.stop();
      await player.play(AssetSource('sounds/complete_sound.mp3'));
      debugPrint('✅ Sound played successfully');
    } catch (e) {
      debugPrint('❌ Sound play error: $e');
    }
  }
}