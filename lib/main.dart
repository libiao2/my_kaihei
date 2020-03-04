import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:premades_nn/page/login/login_screen.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provide/provide.dart';
import 'package:sharesdk_plugin/sharesdk_interface.dart';
import 'package:sharesdk_plugin/sharesdk_register.dart';
import './provide/storeData.dart';
import './provide/roomData.dart';
import './page/first_page/first_page.dart';
import './components/component_index.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main(){
  var storeData = StoreData();
  var roomData = RoomData();
  var userInfoStore = UserInfoStore();
  var providers = Providers();
  providers
  ..provide(Provider<RoomData>.value(roomData))
  ..provide(Provider<StoreData>.value(storeData));
  providers..provide(Provider<UserInfoStore>.value(userInfoStore));

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  runApp(ProviderNode(child:MyApp(), providers:providers));

  // 强制竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
  //   statusBarColor: ColorUtil.nnBlue,
  // ));

}

class MyApp extends StatefulWidget {

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp>{

  @override
  void initState() {
    super.initState();

    //通知栏 初始化
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);


    //shareSDK初始化
    ShareSDKRegister register = ShareSDKRegister();
    register.setupWechat(
        "wx9e2b4c96801cc1be", "fe4694fc557d2bc3c3353861cc29225c", "http://baidu.com");
    register.setupQQ("101839286", "532f43f9d525bcbaeb9f862d06a9404c");
    SharesdkPlugin.regist(register);

     if (Platform.isAndroid) {
   // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前       MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor:    Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
    //payload 可作为通知的一个标记，区分点击的通知。
    if(payload != null && payload == "message") {
      await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        child: MaterialApp(
            title: 'nn开黑',
            theme: ThemeData(
                platform: TargetPlatform.iOS,
                // 左右滑动返回上一个页面
                primaryColor: ColorUtil.nnBlue,
                primaryIconTheme: IconThemeData(color: ColorUtil.nnBlue),
                // 头部返回箭头颜色
                primaryTextTheme: TextTheme(
                  // 主题头部文字颜色
                    title: TextStyle(color: ColorUtil.nnBlue, fontSize: 16.0))),
            navigatorKey: navigatorKey,
            localizationsDelegates: [
              // 这行是关键
              RefreshLocalizations.delegate,
              // 語言包
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalEasyRefreshLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('zh', 'CN')],
            home: FirstScreen()
        ));
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.popUntil(context, ModalRoute.withName("home"));
            },
          )
        ],
      ),
    );
  }
}
