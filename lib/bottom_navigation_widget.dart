import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:premades_nn/event/relogin_event.dart';
import 'package:premades_nn/page/login/login_screen.dart';
import 'package:premades_nn/page/news/send_voice_call_screen.dart';
import 'package:premades_nn/plugin/FloatWindow.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/VoiceStatusType.dart';
import 'package:premades_nn/utils/AndroidBackTop.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Constants.dart' as prefix0;
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/PermissionHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './page/home/home_screen.dart';
import './page/self_center/self_center_screen.dart';
import 'event/float_window_event.dart';
import 'event/system_notice_event.dart';
import 'event/update_message_helper_event.dart';
import 'event/update_screen_event.dart';
import 'event/update_unread_event.dart';
import 'event/voice_call_state_event.dart';
import 'page/news/news_screen.dart';
import './components/download_progress_dialog.dart';

class BottomNavigationWidget extends StatefulWidget {
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationWidget> with WidgetsBindingObserver{
  int indexClick = 0;
  var myPage;

  static int unReadMessageNum = 0;

   StreamSubscription<UpdateUnreadEvent> _subscription;

  final List tabPage = [
    HomeScreen(),
    NewsScreen(),
    SelfCenterScreen()
  ];

  //网络监听相关
  Stream<ConnectivityResult> connectChangeListener() async* {
    final Connectivity connectivity = Connectivity();
    await for (ConnectivityResult result
    in connectivity.onConnectivityChanged) {
      yield result;
    }
  }

  //网络监听
  StreamSubscription<ConnectivityResult> connectivitySubscription;

  //语音通话
  StreamSubscription<VoiceCallStateEvent> _voiceCallSubscription;

  //设备被挤掉
  StreamSubscription<ReloginEvent> _reloginSubscription;

  //悬浮窗点击监听
  StreamSubscription<FloatWindowEvent> _floatWindowSubscription;

  //删除好友更新总未读数
  StreamSubscription<DeleteFriendSuccessEvent> _deleteFriendSubscription;

  //消息助手 监听
  StreamSubscription<UpdateMessageHelperEvevt> _messageHelperSubscription;

  //系统公告
  StreamSubscription<SystemNoticeEvent> _systemNoticeSubscription;


  /// 获取存储路径
  Future<String> _apkLocalPath() async {
    //获取根目录地址
    final dir = await getExternalStorageDirectory();
    //自定义目录路径(可多级)
    String path = dir.path+'/appUpdateDemo';
    var directory = await new Directory(path).create(recursive: true);
    return directory.path;
  }


   Future<void> showUpdate(String version, String data, String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('发现新版本'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(version),
                Text(''),
                Text('更新内容'),
                Text(data),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              textColor: ColorUtil.grey,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确认'),
              textColor: ColorUtil.nnBlue,
              onPressed: () => doUpdate(version, url),
            ),
          ],
        );
      },
    );
  }


  ///检查是否有权限
  checkPermission() async {
    //检查是否已有读写内存权限
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    //判断如果还没拥有读写权限就申请获取权限
    if (status != PermissionStatus.granted) {
      var map = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      if (map[PermissionGroup.storage] != PermissionStatus.granted) {
        return false;
      }
    }
  }


  void doUpdate(String version, String url) async {
    //关闭更新内容提示框
    Navigator.of(context).pop();

    //获取权限
    var per = await checkPermission();
    if (per != null && !per) {
      return null;
    }

    //开始更新
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: DownloadProgressDialog(version, url),
    );
  }


  ///检查是否有更新
  checkUpdate() async {
    
    //获取当前版本
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    //获取服务器上最新版本
    request('post', allUrl['appVersion'], {"version": version}).then((val) {
      print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv$val');
      if (val['code'] == 0) {
        if (val['data'] != null) {
          // 如果等于null数据库没有存储版本信息
          if (version != val['data']['version_no']) {
            /// 现在版本号和线上版本号不一样
            if (val['data']['must']) {
              /// 必须更新
              doUpdate(val['data']['version_no'], val['data']['download_url']);
            } else {
              showUpdate(val['data']['version_no'], val['data']['remark'],
                  val['data']['download_url']);
            }
          }
        }
      }
    });
  }

  @override
  void initState() {

    /// 检查版本
    checkUpdate();
    WidgetsBinding.instance.addObserver(this);

    myPage = tabPage[indexClick];
    super.initState();

     loadUnReadMessageNum();

    //消息助手
    _messageHelperSubscription =
        Constants.eventBus.on<UpdateMessageHelperEvevt>().listen((event) {
          if (!Constants.isOnMessageScreen){
            if (event.status == 1) {
              Constants.systemMessageCount++;
              Constants.systemMessageLastContent = "${event.nickName}请求添加您为好友";
            } else if (event.status == 2) {
              Constants.systemMessageLastContent = "${event.nickName}已成为您的好友";
            } else if (event.status == 5){
              Constants.systemMessageLastContent = "";
            }

            setState(() {
              unReadMessageNum++;
            });
          }
        });

    //重新登录
    _reloginSubscription = Constants.eventBus.on<ReloginEvent>().listen((event){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
        return LoginScreen();
      }), (check) => false);
    });

     //未读消息
    _subscription = Constants.eventBus.on<UpdateUnreadEvent>().listen((event) {
      if (event.num != null && unReadMessageNum >= event.num){
        setState(() {
          unReadMessageNum = unReadMessageNum - event.num;
        });
      }
    });

    //socket 初始化  登陆验证  心跳包发送
     SocketHelper.initWebSocketChannel();

    //网络监听
    connectivitySubscription = connectChangeListener().listen(
          (ConnectivityResult connectivityResult) {
//        if (!mounted) {
//          return;
//        }
        print("connectivityResult = " + connectivityResult.toString());
        if (Constants.connected == false && connectivityResult != ConnectivityResult.none){
          SocketHelper.initWebSocketChannel();
        }
        Constants.connected = connectivityResult != ConnectivityResult.none;
      },
    );

    //语音通话
    _voiceCallSubscription = Constants.eventBus.on<VoiceCallStateEvent>().listen((event){
      switch(event.type){
        case VoiceStatusType.SEND_REQUEST:
          Constants.isOnCalling = true;
          PermissionHelper.checkPermission(context, "语音通话需要麦克风权限，是否前往打开应用权限？", PermissionGroup.microphone, (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return SendVoiceCallScreen(type: 2, nnId: event.nnId, userName: event.nickName, avatar: event.avatar);
            }));
          });
          break;

        case VoiceStatusType.OK:
          if (!Constants.isOnCalling){
            AgoraRtcEngine.joinChannel(null, '10000', null, Constants.userInfo.nnId);
          }
          break;
        case VoiceStatusType.CANCAL:
          Constants.isCancle = true;
          break;
      }
    });

    //悬浮窗
    _floatWindowSubscription = Constants.eventBus.on<FloatWindowEvent>().listen((event){
        if (event.floatType == FloatWindowType.voiceCall){
          FloatWindow.userNnId = null;
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return SendVoiceCallScreen(nnId: event.nnId, userName: event.nickname, avatar: event.avatar, type: event.voiceCallType, time: event.time,);
          }));
        } else if (event.floatType == FloatWindowType.room){

        }
    });

    //删除好友 更新总的未读数
    _deleteFriendSubscription = Constants.eventBus.on<DeleteFriendSuccessEvent>().listen((event) async {
      await Future.delayed(Duration(milliseconds: 500), (){
        loadUnReadMessageNum();
      });

    });

    //系统公告
    _systemNoticeSubscription =
        Constants.eventBus.on<SystemNoticeEvent>().listen((event) {
          if (!Constants.isOnMessageScreen){
            Constants.systemNoticeCount++;
            Constants.systemNoticeLastContent = event.title;
          }
        });

    PermissionHandler().requestPermissions([PermissionGroup.storage, PermissionGroup.camera, PermissionGroup.microphone]).then((permissions){
      permissions.forEach((key, value){
        if (key == PermissionGroup.storage){
          print("存储权限");
        } else if (key == PermissionGroup.camera){
          print("相机权限");
        } else if (key == PermissionGroup.microphone){
          print("麦克风权限");
        }
      });
    });


    if (Constants.keyBoardHeight == null){
      SharedPreferences.getInstance().then((sp){
        Constants.keyBoardHeight = sp.getDouble("keyBoardHeight");
        Constants.screenHeight = sp.getDouble("screenHeight");
        Constants.statusBarHeight = sp.getDouble("statusBarHeight");
      });
    }

    _initAgoraRtcEngine();//声网初始化
  }

  List<Widget> list = List();

  @override
  Widget build(BuildContext context) {

    Constants.mainContext = context;

    return WillPopScope(
      onWillPop: () async {
        print("onWillPop");
        AndroidBackTop.backDeskTop();  //设置为返回不退出app
//        AgoraRtcEngine.leaveChannel();
//        AgoraRtcEngine.joinChannelService(null, AgoraRtcEngine.preChannelId, null, AgoraRtcEngine.preUid);
        return false;  //一定要return false
      },
      child: Scaffold(
        body: myPage,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: Container(
                  width: 28.0,
                  height: 25.0,
                  child: indexClick == 0 ? Image.asset('images/icon_game_choose.png') : Image.asset('images/icon_game_normal.png'),
                ),
              ),
              title: Text(
                '主页',
                style: TextStyle(color: Colors.black),
              ),
            ),
            BottomNavigationBarItem(
              icon: Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Container(
                      width: 30.0,
                      height: 25.0,
                      child: indexClick == 1 ? Image.asset('images/icon_message_choose.png') : Image.asset('images/icon_message_normal.png'),
                    ),
                  ),
                  Offstage(
                    offstage: unReadMessageNum == 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                      child: Text(unReadMessageNum > 99 ? "99+" : unReadMessageNum.toString(),
                        style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(10)),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                          BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ],
              ),
              title: Text(
                '消息',
                style: TextStyle(color: Colors.black),
              ),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  child: indexClick == 2 ? Image.asset('images/icon_mine_choose.png') : Image.asset('images/icon_mine_normal.png'),
                ),
              ),
              title: Text(
                '我的',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: indexClick,
          onTap: (int index) {
            setState(() {
              indexClick = index;
              myPage = tabPage[indexClick];
            });
          },
        ),
      ),
    );
  }

   void loadUnReadMessageNum() {
     request("post", allUrl["unreadMessageNum"], null).then((result) {
       if (result["code"] == 0 && result["data"] != null ) {
         int userMessageCount = result["data"]["user_message_count"] == null?0:result["data"]["user_message_count"];
         int systemMessageCount = result["data"]["system_message_count"] == null?0:result["data"]["system_message_count"];
         int systemNoticeCount = result["data"]["system_notice_count"] == null?0:result["data"]["system_notice_count"];
         Constants.systemMessageCount = systemMessageCount;
         Constants.systemNoticeLastContent = result["data"]["newest_system_notice_title"];
         Constants.systemNoticeCount = systemNoticeCount;
         if (result["data"]["newest_system_message"] != null &&
             result["data"]["newest_system_message"]["nickname"] != null &&
             result["data"]["newest_system_message"]["status"] != null){
            if (result["data"]["newest_system_message"]["status"] == 1){
              Constants.systemMessageLastContent = result["data"]["newest_system_message"]["nickname"] + "请求添加您为好友";
            } else if (result["data"]["newest_system_message"]["status"] == 2){
              Constants.systemMessageLastContent = result["data"]["newest_system_message"]["nickname"] + "已成为您的好友";
            }
         }


         setState(() {
           unReadMessageNum = userMessageCount + systemMessageCount + systemNoticeCount;
         });
       }
     });
   }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }

    if (connectivitySubscription != null) {
      connectivitySubscription.cancel();
    }

    if (_voiceCallSubscription != null){
      _voiceCallSubscription.cancel();
    }

    if (_reloginSubscription != null){
      _reloginSubscription.cancel();
    }

    if (_floatWindowSubscription != null){
      _floatWindowSubscription.cancel();
    }

    if (_deleteFriendSubscription != null){
      _deleteFriendSubscription.cancel();
    }

    if (_messageHelperSubscription != null){
      _messageHelperSubscription.cancel();
    }

    //关闭数据库
    DBHelper.close();

    WidgetsBinding.instance.removeObserver(this);
  }



  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("AppLifecycleState = ${state.toString()}");
    Constants.appState = state;
  }

  /// Create agora sdk instance and initialze
  void _initAgoraRtcEngine() {
    AgoraRtcEngine.create(Constants.APP_ID);
    AgoraRtcEngine.enableAudio(); // 启用音频模块

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      // join channel success
      print('加入成功！！！！！！！！！！！！！！！$uid, $channel');
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      // there's a new user joining this channel
      print('别人加入房间！！！！！！！！！！！！！$uid');
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // there's an existing user leaving this channel
      print('离开房间！！！！！！！！！！！！！');
    };
  }
}
