import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 屏幕适配
import 'package:permission_handler/permission_handler.dart';
import 'package:premades_nn/model/user_info_entity.dart';
import 'package:premades_nn/page/login/login_screen.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/provide/roomData.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/ImageUtil.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 存储数据（键值对）
import 'package:sharesdk_plugin/sharesdk_plugin.dart';
import '../../bottom_navigation_widget.dart';
import '../../page/room/room_screen.dart';
import '../../components/toast.dart';

class FirstScreen extends StatefulWidget {
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  //是否登录成功
  bool _tokenIsOk = false;

  //版本号
  String _version = "";

  //状态控制  0:启动页    1:引导页
  int _status;

  //引导页图片
  List<String> _guideImageList = [
    "images/guide_1.png",
    "images/guide_2.png",
    "images/guide_3.png",
    "images/guide_4.png",
    "images/guide_5.png",
  ];

  void _onEvent(Object event) {
    
    var info = event;
    Map<String, dynamic> resMap = Map<String, dynamic>.from(info);
    var roomInfo = Map<String, dynamic>.from(resMap['params']);
    var room_no = int.parse((roomInfo['startPage'].split("?"))[1]);
    print('HHHHHHHHHHHHHHHHHHHHHHHHHHHH$room_no');
    SocketHelper.joinRoom(room_no, 0, context, (isOk, msg){
      if(isOk) {
        print('11111111111111111');
        // 删除聊天内容
        // Provide.value<StoreData>(context).deleteRoomchat();
        // print('222222222222222222');
        // Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
        // Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
        // Provide.value<StoreData>(context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
        // Provide.value<StoreData>(context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
        // Provide.value<StoreData>(context).saveHomeRoomImg(null);
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomScreen(
              room_no: room_no,
              isOnLine: false,
            ),
          ),
        );
      } else {
        toast(msg);
      }
    });
  }

  void _onError(Object event) {
    print('*********************************************************${event}');
  }

  //引导页组件
  List<Widget> _guideWidgetList = new List();

  void initState() {
    super.initState();

    SharesdkPlugin.addRestoreReceiver(_onEvent, _onError);

    //跳转控制
     pageJumpControl();

    //获取版本号
    // PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    //   setState(() {
    //     _version = "版本号：" + packageInfo.version;
    //   });
    // });
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    Constants.screenHeight = MediaQuery.of(context).size.height;
    Constants.statusBarHeight = MediaQuery.of(context).padding.top;
    return Material(
//      child: BottomNavigationWidget(),
       child: Stack(
         children: <Widget>[
           Offstage(
             offstage: _status != 0,
             child: buildSplashBg(),
           ),
           Offstage(
             offstage: _status != 1,
             child: _guideWidgetList.length == 0
                 ? Container()
                 : PageView(children: _guideWidgetList),
           ),
           // _buildAdWidget(),
         ],
       ),
    );
  }

  ///跳转控制
   void pageJumpControl() {
     SharedPreferences.getInstance().then((sp) {
       bool isFirst = sp.getBool("isFirst");
       String loginToken = sp.getString("loginToken");
       if (isFirst == null || isFirst == true) {
         Constants.isFirst = true;
         initGuideData();
         setState(() {
           _status = 1;
         });
         sp.setBool("isFirst", false);
       } else {
         Constants.isFirst = false;
         setState(() {
           _status = 0;
         });

         if (loginToken == null || loginToken == ""){
           //未登录
           Future.delayed(Duration(seconds: 2), (){
             Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                return LoginScreen();
//               return HomeScreen();
             }), (route) => route == null);
           });
         } else {

           Constants.token = loginToken;
           Constants.gateway = sp.getString("gateway");

           ///根据token获取用户信息
           userInfo();

           Future.delayed(Duration(seconds: 2), (){
             if (_tokenIsOk){
               Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                   settings: RouteSettings(name: "home"),
                   builder: (context){
                 return BottomNavigationWidget();
               }), (route) => route == null);
             } else {
               Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                  return LoginScreen();
//                 return HomeScreen();
               }), (route) => route == null);
             }
           });
         }
       }
     });
   }

  ///引导页
   void initGuideData() {
     for (int i = 0, length = _guideImageList.length; i < length; i++) {
       if (i == length - 1) {
         _guideWidgetList.add(new Stack(
           children: <Widget>[
             new Image.asset(
               "images/guide_5.png",
               fit: BoxFit.cover,
               width: ScreenUtil().width,
               height: ScreenUtil().height,
             ),
             new Align(
               alignment: Alignment.bottomCenter,
               child: new Container(
                 margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(200)),
                 child: new RaisedButton(
                   textColor: Colors.white,
                   color: Colors.indigoAccent,
                   child: Text(
                     '立即体验',
                     style: new TextStyle(fontSize: 16.0),
                   ),
                   onPressed: () {
                     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                       return LoginScreen();
                     }), (route) => route == null);
                   },
                 ),
               ),
             ),
           ],
         ));
       } else {
         _guideWidgetList.add(new Image.asset(
           _guideImageList[i],
           fit: BoxFit.cover,
           width: ScreenUtil().width,
           height: ScreenUtil().height,
         ));
       }
     }
   }

  ///启动页
   Widget buildSplashBg() {
     return Scaffold(
       body: Container(
         width: ScreenUtil().width,
         height: ScreenUtil().height,
         child: Stack(
           alignment: Alignment.topCenter,
           children: <Widget>[
             Container(
               margin: EdgeInsets.only(top: ScreenUtil().setHeight(160)),
               height: 190,
               width: 150,
               decoration: BoxDecoration(
                 image: new DecorationImage(
                     image: AssetImage("images/flash_page.png"),
                     fit: BoxFit.fill),
               ),
             ),
//             Container(
//               margin: EdgeInsets.only(top: ScreenUtil().setHeight(1200)),
//               child: Text(
//                 _version,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             )
           ],
         ),
       ),
     );
   }


  ///获取用户信息
   void userInfo() {
     request('post', allUrl['user_info'], null).then((val) {
       if (val != null && val['code'] == 0) {
         _tokenIsOk = true;
         save(val['data']);
       } else {
         _tokenIsOk = false;
       }
     });
   }

   ///存储用户信息
   Future save(obj) async {

     Provide.value<UserInfoStore>(context).setUserInfo(obj);

     Constants.userInfo = UserInfoEntity.fromJson(obj);
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString('userInfo',  json.encode(obj));
     String picName = Constants.userInfo.avatar.substring(Constants.userInfo.avatar.lastIndexOf("/") + 1, Constants.userInfo.avatar.lastIndexOf("."));
     requestPermission(Constants.userInfo.avatar, picName);
   }

   ///权限申请 存储头像
   Future requestPermission(String avatar, String picName) async {
     // 申请权限
     Map<PermissionGroup, PermissionStatus> permissions =
     await PermissionHandler().requestPermissions([PermissionGroup.storage]);
     // 申请结果
     PermissionStatus permission = await PermissionHandler()
         .checkPermissionStatus(PermissionGroup.storage);
     if (permission == PermissionStatus.granted) {
       print("权限申请通过");
       ImageUtil.fetchImage(avatar, picName);
     } else {
       print("权限申请被拒绝");
     }
   }

  @override
  void dispose() {
    super.dispose();
  }
}
