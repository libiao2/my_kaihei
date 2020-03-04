import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:premades_nn/event/AuthorizationEvent.dart';
import 'package:premades_nn/event/float_window_event.dart';
import 'package:premades_nn/utils/Constants.dart';

class FloatWindow {

  static int userNnId;

  static FloatWindow _instance;

  static FloatWindow get instance => _getInstance();

  static MethodChannel floatWindowChannel = const MethodChannel("float_window_btn");

  FloatWindow._internal(){
    floatWindowChannel.setMethodCallHandler((handler) {
      switch (handler.method) {
        case "onClick":
          var result = handler.arguments;
          if (Constants.appState == null || Constants.appState != AppLifecycleState.paused){
            FloatWindow.instance.close();
            Constants.eventBus.fire(FloatWindowEvent(floatType: result["floatType"], time: result["startTime"], roomNo: result["roomNo"],
              nnId: result["nnId"], nickname: result["nickname"], avatar: result["imageUrl"], voiceCallType: result["voiceCallType"],));
          }
          break;

        case "authFailure":
          Constants.eventBus.fire(AuthorizationEvent(type: AuthorizationType.FAILURE));
          break;

        case "authSuccess":
          Constants.eventBus.fire(AuthorizationEvent(type: AuthorizationType.SUCCESS));
          break;
      }
      return;
    });
  }

  static FloatWindow _getInstance(){
    if (_instance == null) {
      _instance = FloatWindow._internal();
    }
    return _instance;
  }

  void show({int floatType, int nnId, int roomNo, String nickName, String imageUrl, int time, bool isStartTime, int voiceCallType}){
    Map<String, dynamic> args = {
      'floatType': floatType,
      'voiceCallType': voiceCallType,
      'isStartTime': isStartTime,
      'time': time,
      'nnId': nnId,
      'roomNo': roomNo,
      'nickName': nickName,
      'imageUrl': imageUrl,
    };

    try {
      floatWindowChannel.invokeMethod("showFloatWindow", args);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  ///关闭悬浮窗
  void close(){
    try {
      floatWindowChannel.invokeMethod("close", null);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  ///修改语音通话状态
  void startVoiceCall(){
    try {
      floatWindowChannel.invokeMethod("startVoiceCall", null);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  ///修改语音通话状态
  void startTime(){
    try {
      floatWindowChannel.invokeMethod("startTime", null);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}



class FloatWindowType{
  static const int voiceCall = 0;
  static const int room = 1;
}