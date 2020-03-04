import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:premades_nn/page/news/chat_message.dart';

class AudioPlayerUtil{

  static int messageId;

  static ChatMessage chatMessage;

  static AudioPlayerUtil _instance;

  static AudioPlayerUtil get instance => _getInstance();

  static AudioPlayer _audioPlayer;

  static AudioCache _audioCache;

  AudioPlayerUtil._internal(){
    _audioPlayer = AudioPlayer();
    _audioCache = AudioCache(fixedPlayer: AudioPlayer());
  }

  static AudioPlayerUtil _getInstance() {
    if (_instance == null) {
      _instance = new AudioPlayerUtil._internal();
    }
    return _instance;
  }

  void playAudio(String url, Function callback) async {

    int isPlaying = await _audioPlayer.isPlaying();
    if (isPlaying == 1){
      await _audioPlayer.stop();
    }

    await _audioPlayer.play(url);

    _audioPlayer.onPlayerStateChanged.listen((state){
      print("state = ${state.toString()}");
      if (state == AudioPlayerState.COMPLETED ||
            state == AudioPlayerState.STOPPED){
        callback();
      }
    });
  }

  void voiceCallPlay() async {
    await _audioCache.loop("audio/voice_call.mp3");
  }

  void voiceCallPlayStop() async {
    if (_audioCache != null){
      await _audioCache.stop();
    }
  }

  void stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<int> isPlaying() async{
    int isPlaying = await _audioPlayer.isPlaying();
    return isPlaying;
  }
}