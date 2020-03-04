import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/CustomDialog.dart';
import 'package:premades_nn/page/login/login_screen.dart';
import 'package:premades_nn/page/self_center/contact_us_screen.dart';
import 'package:premades_nn/plugin/FloatWindow.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/utils/AudioPlayerUtil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about_us.dart';
import 'friend_verification_screen.dart';

class SettingScreen extends StatefulWidget {
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Provide<UserInfoStore>(
        builder: (context, child, userInfoStore){
          return Material(
            color: ColorUtil.greyBG,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    AppBarWidget(isShowBack: true, centerText: Strings.settingCenter,),
                    Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return FriendVerificationScreen();
                            }));
                          },
                          child: Container(
                            color: ColorUtil.white,
                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            height: ScreenUtil().setHeight(50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("好友验证",
                                    style: TextStyle(fontSize: 15, color: Colors.black)),
                                Image.asset(
                                  "images/icon_arrow.png",
                                  width: ScreenUtil().setWidth(8),
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            clearCache();
                          },
                          child: Container(
                            color: ColorUtil.white,
                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            height: ScreenUtil().setHeight(50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("清除缓存",
                                    style: TextStyle(fontSize: 15, color: Colors.black)),
                                Image.asset(
                                  "images/icon_arrow.png",
                                  width: ScreenUtil().setWidth(8),
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return ContactUsScreen();
                            }));
                          },
                          child: Container(
                            color: ColorUtil.white,
                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            height: ScreenUtil().setHeight(50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("联系我们",
                                    style: TextStyle(fontSize: 15, color: Colors.black)),
                                Image.asset(
                                  "images/icon_arrow.png",
                                  width: ScreenUtil().setWidth(8),
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return AbountUsScreen();
                            }));
                          },
                          child: Container(
                            color: ColorUtil.white,
                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            height: ScreenUtil().setHeight(50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("关于",
                                    style: TextStyle(fontSize: 15, color: Colors.black)),
                                Image.asset(
                                  "images/icon_arrow.png",
                                  width: ScreenUtil().setWidth(8),
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 5, color: Color.fromRGBO(242, 242, 242, 1.0)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Container(
                  child: Material(
                    child: new Ink(
                      decoration: new BoxDecoration(

                      ),
                      child: InkWell(
                        onTap: () {
                          clearUserInfo();
                        },
                        child: Container(
                          color: ColorUtil.white,
                          height: ScreenUtil().setHeight(50),
                          //设置child 居中
                          alignment: Alignment(0, 0),
                          child: Text(
                            "退出登录",
                            style: TextStyle(color: Colors.red, fontSize: ScreenUtil().setSp(14)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  Future clearUserInfo() async {

    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: "是否确认退出登录？",
          confirmCallback: () {
            Constants.clearCache(context).then((val) async {

              SocketHelper.closeChannel();

              AudioPlayerUtil.instance.voiceCallPlayStop();
              FloatWindow.instance.close();

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('loginToken', null);
              prefs.setString('userInfo', null);
              prefs.setString('gateway', null);

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                return LoginScreen();
              }), (check) => false);
            });
          },
        ));


  }

  void clearCache() {
    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: "清楚缓存会删除用户本地数据,确认清除缓存吗？",
          confirmCallback: () {
            Constants.clearCache(context).then((val){
              Fluttertoast.showToast(
                  msg: '缓存清除成功！',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
          },
        ));
  }
}
