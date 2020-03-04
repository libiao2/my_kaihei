import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/SendVerificationCodeWidget.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/VerificationCodeType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'change_phone_success_screen.dart';

class ChangePhoneScreen extends StatefulWidget {
  _ChangePhoneScreenState createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {

  TextEditingController _verificationController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Provide<UserInfoStore>(builder: (context, child, userInfoStore) {
      return Material(
        child: Column(
          children: <Widget>[
            AppBarWidget(isShowBack: true, centerText: Strings.updatePhone,),

            //输入手机号---发送验证码
            Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(50),
                    left: ScreenUtil().setHeight(20),
                    right: ScreenUtil().setHeight(20)),
                height: ScreenUtil().setHeight(65),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: ColorUtil.greyHint, width: 1))),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        cursorColor: ColorUtil.black,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: Strings.accountInputHint,
                            labelStyle: TextStyle(
                                color: ColorUtil.greyHint,
                                fontSize: ScreenUtil().setSp(18))),
                        autofocus: false,
                      ),
                    ),

                    //发送验证码
                    SendVerificationCodeWidget(
                      accountController: _phoneController,
                      verificationCodeType: VerificationCodeType.bindPhone,
                    ),
                  ],
                )),

            //验证码
            Container(
              margin: EdgeInsets.only(left: ScreenUtil().setHeight(20), right: ScreenUtil().setHeight(20)),
              alignment: Alignment.centerLeft,
              height: ScreenUtil().setHeight(65),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: ColorUtil.greyHint, width: 1))),
              child: TextField(
                controller: _verificationController,
                cursorColor: ColorUtil.black,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[0-9]")),
                ],
                decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: Strings.verificationInputHint,
                    labelStyle: TextStyle(
                        color: ColorUtil.greyHint,
                        fontSize: ScreenUtil().setSp(18))),
                autofocus: false,
              ),
            ),

            //确定
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
                      next(userInfoStore);
                    },
                    child: new Container(
                      height: 45.0,
                      //设置child 居中
                      alignment: Alignment(0, 0),
                      child: Text(
                        "确定",
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
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  //解绑原来手机号，绑定新手机号
  void next(UserInfoStore userInfoStore) {
    String _phone = _phoneController.text;
    String verificationCode = _verificationController.text;

    if (_phone == null || !Constants.phoneIsOk(_phone)) {
      toast(Strings.phoneError);
      return;
    }

    if(verificationCode == null || verificationCode == ""){
      toast(Strings.verificationCodeError);
      return;
    }


      NetLoadingDialog.showLoadingDialog(context, "绑定手机中...");
      //绑定新手机
      var data = {
        "mobile": _phone,
        "country_code": 86,
        "smscode": verificationCode,
        "smscode_key" : Constants.smscodeKey
      };

      request('post', allUrl['change_phone'], data).then((val) {
        Navigator.of(context).pop();
        if (val['code'] == 0) {

          //更新存储数据
          userInfoStore.userInfo.mobile = _phone;
          Constants.userInfo.mobile = _phone;

          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (content) {
            return ChangePhoneSuccessScreen();
          }));
        } else {
          toast(val["msg"]);
        }
      });
  }


  @override
  void dispose() {
    super.dispose();
  }
}
