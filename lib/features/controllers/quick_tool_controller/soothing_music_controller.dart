import 'package:daily_mate/utils/constants/image_strings.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class SoothingMusicController extends GetxController {
  final player = AudioPlayer();

  var isPlaying = false.obs;
  var currentTrack = ''.obs;
  var currentDuration = Duration.zero.obs; // current playback duration
  var totalDuration = Duration.zero.obs;   // total track duration

  final tracks = <Map<String, dynamic>>[
    {
      "title": "Meditation Flow",
      "file": "assets/soothing_sounds/meditation.mp3",
      "image": TImages.meditationImage,
    },
    {
      "title": "Deep Focus",
      "file": "assets/soothing_sounds/focus.mp3",
      "image": TImages.focusImage,
    },
    {
      "title": "Motivation",
      "file": "assets/soothing_sounds/motivation.mp3",
      "image": TImages.motivationImage,
    },
    {
      "title": "Take a Nap",
      "file": "assets/soothing_sounds/sleep.mp3",
      "image": TImages.sleepImage,
    },
  ];

  @override
  void onInit() {
    super.onInit();

    // Listen to player state
    player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });

    // Listen to track duration
    player.durationStream.listen((duration) {
      totalDuration.value = duration ?? Duration.zero;
    });

    // Listen to current position
    player.positionStream.listen((pos) {
      currentDuration.value = pos;
    });

    // Listen to track changes
    player.sequenceStateStream.listen((state) {
      if (state.currentSource?.tag != null) {
        currentTrack.value = state.currentSource!.tag as String;
      }
    });
  }

  Future<void> playTrack(String assetPath) async {
    if (currentTrack.value == assetPath) {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    } else {
      await player.setAudioSource(AudioSource.asset(assetPath, tag: assetPath));
      await player.play();
    }
  }

  String getDurationString(Duration duration) {
    final min = duration.inMinutes;
    final sec = duration.inSeconds % 60;
    return "$min:${sec.toString().padLeft(2, '0')} min";
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
