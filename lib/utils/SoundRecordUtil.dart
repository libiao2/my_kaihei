import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';

import 'Constants.dart';

class SoundRecordUtil{

  static FlutterSound _flutterSound;
  static StreamSubscription _recorderSubscription;
  static StreamSubscription _dbPeakSubscription;
  static StreamSubscription _playerSubscription;

  static Timer _timer;
  static int time = 0;

  static void initSoundRecord(){
    _flutterSound = new FlutterSound();
    _flutterSound.setSubscriptionDuration(0.01);
    _flutterSound.setDbPeakLevelUpdate(0.8);
    _flutterSound.setDbLevelEnabled(true);
  }


  static Future<String> startRecorder(Function callback) async {
    String path;
    try {
      //开始计时
      _timer = Timer.periodic(Duration(seconds: 1), (timer){
        time++;
        callback(time);
      });

      String dirPath = await Constants.createRecordPath();
      String filePath = dirPath + "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".wav";

      path = await _flutterSound.startRecorder(filePath);
      print("数据$path");

      _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {

      });
    } catch (err) {
      print('startRecorder error: $err');
    }

    return path;
  }

  static Future<int> stopRecorder() async {

    if (_timer != null){
      _timer.cancel();
    }

    try {
      String result = await _flutterSound.stopRecorder();
      print('停止录音返回结果: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }

    int result = time;
    time = 0;
    return result;
  }

  static void startPlayer() async {
    String path = await _flutterSound.startPlayer(null);
    File file= await new File(path);
    List contents = await file.readAsBytesSync();

    // return print("file文件：$contents");
    await _flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
//          slider_current_position = e.currentPosition;
//          max_duration = e.duration;
//
//          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
//              e.currentPosition.toInt(),
//              isUtc: true);
//          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
//          this.setState(() {
//            this._isPlaying = true;
//            this._playerTxt = txt.substring(0, 8);
//          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  static void stopPlayer() async {
    try {
      String result = await _flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

    } catch (err) {
      print('error: $err');
    }
  }
}