import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/voice_call_state_event.dart';
import 'package:premades_nn/plugin/FloatWindow.dart';
import 'package:premades_nn/type/VoiceStatusType.dart';
import 'package:premades_nn/utils/AudioPlayerUtil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/SocketHelper.dart';

class SendVoiceCallScreen extends StatefulWidget {
  int type; //1:发起方  2：接收方 3：开始语音

  final int nnId; //用户id
  final String userName; //用户名称
  final String avatar; // 用户头像

  int time = 0; //点击悬浮框回到通话页面，初始化通话时间

  SendVoiceCallScreen(
      {Key key, this.type, this.nnId, this.avatar, this.userName, this.time})
      : super(key: key);

  @override
  _SendVoiceCallState createState() => _SendVoiceCallState();
}

///1发起请求，2对方未在线，3不是好友关系，4对方忙碌中(正在使用语音通话)， 5主动取消语音通话，
/// 6接收者同意接听，7接收者拒绝，8已在其他端处理请求，9挂断，10网络异常中断，11超时无应答
class _SendVoiceCallState extends State<SendVoiceCallScreen> {
  String connectStatus = "正在等待对方接收通话...";

//  bool isOnCall = false;

  StreamSubscription<VoiceCallStateEvent> _subscription;

  Timer _timer; //通话计时
  int time = 0;
  String timeStr = "00:00:00";

  @override
  void initState() {
    super.initState();

    Constants.isOnCalling = true;

    if (widget.type == 1){
      Constants.startCountdownTimer((){
        if (Constants.isOnCalling){
          Navigator.pop(context);
        } else {
          FloatWindow.userNnId = null;
          FloatWindow.instance.close();
        }

        AudioPlayerUtil.instance.voiceCallPlayStop();
        if (!Constants.isSendError){
          SocketHelper.sendVoiceCall(
              widget.nnId, VoiceStatusType.CANCAL);
        }
      });
    } else {
      if (Constants.timer != null){
        Constants.timer.cancel();
      }
      Constants.time = 0;
    }

    if (widget.time != null && widget.time != 0 && widget.type == 3) {
      time = widget.time;
      startCountdownTimer();
    }

    _subscription =
        Constants.eventBus.on<VoiceCallStateEvent>().listen((event) {

      switch (event.type) {
        case -1:
//          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: event.errorMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
//        case VoiceStatusType.BUSY:
//          Navigator.pop(context);
//          Fluttertoast.showToast(
//              msg: "用户正在通话中！",
//              toastLength: Toast.LENGTH_SHORT,
//              gravity: ToastGravity.CENTER,
//              timeInSecForIos: 1,
//              backgroundColor: Colors.black54,
//              textColor: Colors.white,
//              fontSize: 16.0
//          );
//          break;
        case VoiceStatusType.CANCAL:
          Navigator.pop(context);
          break;
        case VoiceStatusType.HANDLE_ON_OTHER:
          Navigator.pop(context);
          break;
        case VoiceStatusType.HANG_UP:
          AgoraRtcEngine.leaveChannel();
          // AgoraRtcEngine.preUid = null;
          // AgoraRtcEngine.preChannelId = null;
          Navigator.pop(context);
          toast("语音通话结束！");
          break;
//        case VoiceStatusType.NOT_FRIEND:
//          Navigator.pop(context);
//          Fluttertoast.showToast(
//              msg: "该用户不是你的好友！",
//              toastLength: Toast.LENGTH_SHORT,
//              gravity: ToastGravity.CENTER,
//              timeInSecForIos: 1,
//              backgroundColor: Colors.black54,
//              textColor: Colors.white,
//              fontSize: 16.0
//          );
//          break;
        case VoiceStatusType.NETWORK_ERROR:
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "网络异常中断！",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
        case VoiceStatusType.REFUSED:
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "用户拒绝语音通话！",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
        case VoiceStatusType.OK:
          AgoraRtcEngine.joinChannel(null, '10000', null, Constants.userInfo.nnId);

          toast("童话页面"+Constants.generateMd5(
              widget.nnId.toString() +
              Constants.userInfo.nnId.toString()));

          startCountdownTimer();
          setState(() {
            widget.type = 3;
          });
          break;

        case VoiceStatusType.REPONSE_TIME_OUT:
          Navigator.pop(context);
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (_subscription != null) {
      _subscription.cancel();
    }

    if (_timer != null) {
      _timer.cancel();
    }

    Constants.isOnCalling = false;

    Constants.isCancle = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 1) {
      //主动拨打语音通话
      connectStatus = "正在等待对方接收通话...";
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.network(
                widget.avatar,
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(
                  color: ColorUtil.blackTran,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    child: InkWell(
                      onTap: () {
                        FloatWindow.userNnId = widget.nnId;
                        FloatWindow.instance.show(
                            floatType: FloatWindowType.voiceCall,
                            voiceCallType: 1,
                            time: time,
                            isStartTime: false,
                            nnId: widget.nnId,
                            nickName: widget.userName,
                            imageUrl: widget.avatar);
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            MediaQueryData.fromWindow(window).padding.top +
                                ScreenUtil().setWidth(10),
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setWidth(10)),
                        width: ScreenUtil().setWidth(25),
                        height: ScreenUtil().setWidth(25),
                        child: Image.asset(
                          "images/icon_narrow.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        child: Container(
                            width: ScreenUtil().setWidth(80),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipOval(
                                child: Image.network(
                                  widget.avatar,
                                ),
                              ),
                            ))),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                      child: Text(widget.userName,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Text(connectStatus,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(200)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            //因为不在线，通话中，等原因造成websocket没接通 ，不调用取消方法
                            if (!Constants.isSendError) {
                              SocketHelper.sendVoiceCall(
                                  widget.nnId, VoiceStatusType.CANCAL);
                            }

                            Navigator.pop(context);
                            AudioPlayerUtil.instance.voiceCallPlayStop();

                            if (Constants.timer != null){
                              Constants.timer.cancel();
                            }
                            Constants.time = 0;
                          },
                          child: Image.asset(
                            "images/btn_refuse.png",
                            width: ScreenUtil().setWidth(60),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ],
        ),
      );
    } else if (widget.type == 2) {
      //被动接听语音通话
      connectStatus = "向您发起通话...";
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.network(
                widget.avatar,
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(
                  color: ColorUtil.blackTran,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    child: InkWell(
                      onTap: () {
                        FloatWindow.userNnId = widget.nnId;
                        FloatWindow.instance.show(
                            floatType: FloatWindowType.voiceCall,
                            voiceCallType: 2,
                            time: time,
                            isStartTime: false,
                            nnId: widget.nnId,
                            nickName: widget.userName,
                            imageUrl: widget.avatar);

                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            MediaQueryData.fromWindow(window).padding.top +
                                ScreenUtil().setWidth(10),
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setWidth(10)),
                        width: ScreenUtil().setWidth(25),
                        height: ScreenUtil().setWidth(25),
                        child: Image.asset(
                          "images/icon_narrow.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: Container(
                              width: ScreenUtil().setWidth(80),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipOval(
                                  child: Image.network(
                                    widget.avatar,
                                    fit: BoxFit.fitWidth,
                                    width: ScreenUtil().setWidth(80),
                                  ),
                                ),
                              ))),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                        child: Text(widget.userName,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                        child: Text(connectStatus,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(200)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                AudioPlayerUtil.instance.voiceCallPlayStop();

                                SocketHelper.sendVoiceCall(
                                    widget.nnId, VoiceStatusType.OK);
                                AgoraRtcEngine.joinChannel(null, '10000', null, Constants.userInfo.nnId);
                                toast(Constants.generateMd5(
                                    Constants.userInfo.nnId.toString() +
                                        widget.nnId.toString()));

                                startCountdownTimer();

                                setState(() {
                                  widget.type = 3;
                                });
                              },
                              child: Image.asset(
                                "images/btn_get.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                FloatWindow.userNnId = null;
                                SocketHelper.sendVoiceCall(
                                    widget.nnId, VoiceStatusType.REFUSED);
                                AudioPlayerUtil.instance.voiceCallPlayStop();
                                Navigator.pop(context);
                                setState(() {
                                  widget.type = 2;
                                });
                              },
                              child: Image.asset(
                                "images/btn_refuse.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (widget.type == 3) {
      //开启语音通话
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.network(
                widget.avatar,
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(
                  color: ColorUtil.blackTran,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    child: InkWell(
                      onTap: () {
                        FloatWindow.userNnId = widget.nnId;
                        FloatWindow.instance.show(
                            floatType: FloatWindowType.voiceCall,
                            voiceCallType: 3,
                            time: time,
                            isStartTime: true,
                            nnId: widget.nnId,
                            nickName: widget.userName,
                            imageUrl: widget.avatar);
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            MediaQueryData.fromWindow(window).padding.top +
                                ScreenUtil().setWidth(10),
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setWidth(10)),
                        width: ScreenUtil().setWidth(25),
                        height: ScreenUtil().setWidth(25),
                        child: Image.asset(
                          "images/icon_narrow.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                              child: Container(
                                  width: ScreenUtil().setWidth(80),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipOval(
                                      child: Image.network(
                                        widget.avatar,
                                      ),
                                    ),
                                  ))),
                          Container(
                            child: Container(
                                width: ScreenUtil().setWidth(80),
                                child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipOval(
                                      child: Image.network(
                                        Constants.userInfo.avatar,
                                        fit: BoxFit.fitWidth,
                                        width: ScreenUtil().setWidth(80),
                                      ),
                                    ))),
                          ),
                        ],
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                        child: Text("正在通话",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                        child: Text(timeStr,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(200)),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              FloatWindow.userNnId = null;

                              AgoraRtcEngine.leaveChannel();
                              // AgoraRtcEngine.preUid = null;
                              // AgoraRtcEngine.preChannelId = null;

                              SocketHelper.sendVoiceCall(
                                  widget.nnId, VoiceStatusType.HANG_UP);
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              "images/btn_refuse.png",
                              width: ScreenUtil().setWidth(60),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  ///开启通话计时
  void startCountdownTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time++;
      int hour = (time / 3600).floor();
      int minute = ((time - hour * 3600) / 60).floor();
      int second = time - hour * 3600 - minute * 60;
      String hourStr;
      String minuteStr;
      String secondStr;
      if (hour < 10 && hour > 0) {
        hourStr = "0${hour}";
      } else if (hour == 0) {
        hourStr = "00";
      } else {
        hourStr = hour.toString();
      }

      if (minute < 10 && minute > 0) {
        minuteStr = "0${minute}";
      } else if (minute == 0) {
        minuteStr = "00";
      } else {
        minuteStr = minute.toString();
      }

      if (second < 10 && second > 0) {
        secondStr = "0${second}";
      } else if (second == 0) {
        secondStr = "00";
      } else {
        secondStr = second.toString();
      }
      setState(() {
        timeStr = hourStr + ":" + minuteStr + ":" + secondStr;
      });
    });
  }
}
