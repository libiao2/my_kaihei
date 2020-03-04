import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/SendVerificationCodeWidget.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/verification_code_event.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/VerificationCodeType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';

import 'change_password_next_screen.dart';
import 'change_phone_screen.dart';

class ChangePasswordScreen extends StatefulWidget {

  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();

}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  String _showPhone = ""; //登录手机

  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Provide<UserInfoStore>(
        builder: (context, child, userInfoStore){
          return Material(
            child: Column(
              children: <Widget>[
                AppBarWidget(isShowBack: true, centerText: Strings.updatePhone,),
                Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 5, color: Color.fromRGBO(242, 242, 242, 1.0)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: ScreenUtil().setHeight(20)),
                            alignment: Alignment.topLeft,
                            child: Text("验证码将发送至：" + _showPhone, style: TextStyle()),
                          ),
                          //输入手机号---发送验证码
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(ScreenUtil().setHeight(20),
                                  ScreenUtil().setHeight(10),
                                  ScreenUtil().setHeight(20),
                                  ScreenUtil().setHeight(10)),
                              height: ScreenUtil().setHeight(65),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: ColorUtil.greyHint, width: 1))),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _inputController,
                                      cursorColor: ColorUtil.black,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter(RegExp("[0-9]")),
                                      ],
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: Strings.verificationInputHint,
                                          labelStyle: TextStyle(
                                              color: ColorUtil.greyHint,
                                              fontSize: ScreenUtil().setSp(18))),
                                      autofocus: false,
                                    ),
                                  ),

                                  //发送验证码
                                  SendVerificationCodeWidget(
                                    verificationCodeType: VerificationCodeType.unBindPhone,
                                  ),
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(20),
                                ScreenUtil().setWidth(100),
                                ScreenUtil().setWidth(20),
                                ScreenUtil().setWidth(20)),
                            child: Material(
                              child: new Ink(
                                decoration: new BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter
                                  ),
                                  borderRadius:
                                  new BorderRadius.all(new Radius.circular(22.0)),
                                ),
                                child: new InkWell(
                                  borderRadius: new BorderRadius.circular(22.0),
                                  onTap: () {
                                    next();
                                  },
                                  child: new Container(
                                    height: 45.0,
                                    //设置child 居中
                                    alignment: Alignment(0, 0),
                                    child: Text(
                                      "下一步",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _showPhone = Constants.userInfo.mobile.replaceAll(Constants.userInfo.mobile.substring(3, 7), "****");

  }

  @override
  void dispose() {
    super.dispose();
  }

  Future next() async {
    String verificationCode = _inputController.text;
    if (verificationCode != null && verificationCode != "") {

      //解绑手机号
      NetLoadingDialog.showLoadingDialog(context, "Loading");
      var data = {
        "smscode": _inputController.text,
        "smscode_key":Constants.smscodeKey
      };
      request('post', allUrl['untying_phone'], data).then((val) {
        Navigator.of(context).pop();
        if (val['code'] == 0) {
          //解绑成功-跳转绑定手机号页面
          Navigator.of(context).push(MaterialPageRoute(builder: (content) {
            return ChangePhoneScreen();
          }));
        } else {
          toast(val['msg']);
        }
      });

    } else {
      Fluttertoast.showToast(
          msg: '请输入验证码！',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
