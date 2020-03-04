import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/page/login/forget_password_screen.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';

import 'change_password_screen.dart';
import 'change_phone_success_screen.dart';

class SecurityScreen extends StatefulWidget {
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String data = "";

  String _showPhone = ""; //登录手机


  @override
  Widget build(BuildContext context) {

    return Provide<UserInfoStore>(
        builder: (context, child, userInfoStore){

          _showPhone = userInfoStore.userInfo.mobile.replaceAll(userInfoStore.userInfo.mobile.substring(3, 7), "****");

          return Material(
            color: ColorUtil.greyBG,
            child: Column(
              children: <Widget>[
                AppBarWidget(isShowBack: true, centerText: Strings.security,),
                Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ForgetPasswordScreen(1);
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
                            Text("修改密码",
                                style: TextStyle(fontSize: 15, color: Colors.black)),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ChangePasswordScreen();
                        }));
                      },
                      child: Container(
                        color: ColorUtil.white,
                        margin: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
                        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0.0),
                        height: ScreenUtil().setHeight(50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("手机绑定",
                                style: TextStyle(fontSize: 15, color: Colors.black)),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Offstage(
                                    offstage: false,
                                    child: Text(_showPhone,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey)),
                                  ),
                                ),
                                Icon(
                                  Icons.navigate_next,
                                  color: Colors.grey,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

//            InkWell(
//              onTap: () {},
//              child: Container(
//                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
//                height: 50.0,
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Text("QQ绑定",
//                        style: TextStyle(fontSize: 15, color: Colors.black)),
//                    Row(
//                      children: <Widget>[
//                        Container(
//                          margin: EdgeInsets.only(right: 10),
//                          child: Offstage(
//                            offstage: false,
//                            child: Text("已绑定",
//                                style: TextStyle(
//                                    fontSize: 15, color: Colors.grey)),
//                          ),
//                        ),
//                        Icon(
//                          Icons.navigate_next,
//                          color: Colors.grey,
//                        ),
//                      ],
//                    )
//                  ],
//                ),
//              ),
//            ),
//            Divider(
//              height: 0.0,
//              indent: 0.0,
//              color: Colors.grey,
//            ),
//            InkWell(
//              onTap: () {},
//              child: Container(
//                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
//                height: 50.0,
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Text("微信绑定",
//                        style: TextStyle(fontSize: 15, color: Colors.black)),
//                    Row(
//                      children: <Widget>[
//                        Container(
//                          margin: EdgeInsets.only(right: 10),
//                          child: Offstage(
//                            offstage: false,
//                            child: Text("已绑定",
//                                style: TextStyle(
//                                    fontSize: 15, color: Colors.grey)),
//                          ),
//                        ),
//                        Icon(
//                          Icons.navigate_next,
//                          color: Colors.grey,
//                        ),
//                      ],
//                    )
//                  ],
//                ),
//              ),
//            ),
//            Divider(
//              height: 0.0,
//              indent: 0.0,
//              color: Colors.grey,
//            ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

//    _showPhone = Constants.userInfo.mobile.replaceAll(Constants.userInfo.mobile.substring(3, 7), "****");
//
//    //注册事件监听
//    _phoneSubscription  = Constants.eventBus.on<PhoneChangeEvent>().listen((event) {
//      print("event.phone= " + event.phone);
//      _phone = event.phone;
//      setState(() {
//        _showPhone = _phone.replaceAll(_phone.substring(3, 7), "****");
//        print("_showPhone = " + _showPhone);
//      });
//    });
  }

  @override
  void dispose() {
    super.dispose();
    //注销事件监听
//    _phoneSubscription.cancel();
  }
}
