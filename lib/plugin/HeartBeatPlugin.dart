import 'package:flutter/services.dart';
import 'package:premades_nn/utils/SocketHelper.dart';

class HeartBeatPlugin{
  static HeartBeatPlugin _instance;

  static HeartBeatPlugin get instance => _getInstance();

  static MethodChannel heartBeatChannel = const MethodChannel("heart_beat");

  HeartBeatPlugin._internal(){
    heartBeatChannel.setMethodCallHandler((handler) {
      switch (handler.method) {
        case "sendHeartBeat":
          SocketHelper.heartbeat();
          break;
      }
      return;
    });
  }

  static HeartBeatPlugin _getInstance(){
    if (_instance == null) {
      _instance = HeartBeatPlugin._internal();
    }
    return _instance;
  }

  void start(){
    print("HeartBeatPlugin start 被调用");
    try {
      heartBeatChannel.invokeMethod("start", null);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  void close(){
    try {
      heartBeatChannel.invokeMethod("close", null);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}