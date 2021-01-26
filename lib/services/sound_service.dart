import 'package:audioplayers/audio_cache.dart';

class SoundService {
  static AudioCache player = AudioCache();

  static void playCorrect() {
    player.play('sounds/correct_sound.mp3');
  }

  static void playWrong() {
    player.play('sounds/wrong_sound.mp3');
  }

  static void playSuccess() {
    player.play('sounds/success_sound.mp3');
  }

  static void playSuccessDiploma() {
    player.play('sounds/success_diploma_sound.mp3');
  }
}
