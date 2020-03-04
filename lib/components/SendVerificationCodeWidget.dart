import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_geetest/flutter_geetest.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';

class SendVerificationCodeWidget extends StatefulWidget {
  final TextEditingController accountController;

  final int verificationCodeType;

  final String bindToken;//第三方登录绑定手机发送验证码需要参数

  bool isCheckPhone = false;

  //第三方绑定判断是否需要输入密码
  Function(int) mCallback;


  SendVerificationCodeWidget(
      {this.accountController, this.verificationCodeType, this.isCheckPhone, this.mCallback, this.bindToken});

  @override
  SendVerificationCodeWidgetState createState() =>
      SendVerificationCodeWidgetState();
}

class SendVerificationCodeWidgetState extends State<SendVerificationCodeWidget> {

  int _allTime = 0; // 点击发送验证码60s倒计时

  Timer _timer;

  String _verificationText = Strings.sendVerificationCode;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          if (widget.accountController == null){
            geetest();
          } else {
            if (widget.accountController.text == null || !Constants.phoneIsOk(widget.accountController.text)){
              toast(Strings.phoneError);
              return;
            }

            if (widget.isCheckPhone != null && widget.isCheckPhone){
              checkRegister(widget.accountController.text);
            } else {
              geetest();
            }
          }
        },
        child: Container(
          alignment: Alignment.centerLeft,
          height: ScreenUtil().setHeight(65),
          margin: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: ScreenUtil().setWidth(1),
                color: ColorUtil.greyBG
              )
            )
          ),
          child: Text(_verificationText,
              style: TextStyle(
                  color: ColorUtil.black, fontSize: ScreenUtil().setSp(16))),
        ));
  }

  void geetest(){
    // FlutterGeetest.launchGeetest(
    //     mobile: widget.accountController != null?widget.accountController.text:Constants.userInfo.mobile,
    //     type: widget.verificationCodeType,
    //     bindToken: widget.bindToken,
    //     api1: allUrl["geestFirst"] + DateTime.now().millisecondsSinceEpoch.toString(),
    //     api2: allUrl['send']
    // ).then((data){
    //   print("及验证返回值 $data");
    //   if (data != null && data["code"] != null){
    //     if (data["code"] == 0){
    //       if (data["data"] != null){
    //         Constants.smscodeKey = data["data"]["smscode_key"];
    //         if (widget.mCallback != null){
    //           widget.mCallback(data["data"]["bind_status"]);
    //         }
    //       }
    //       if (_allTime == 0) {
    //         _allTime = 60;
    //         startCountdownTimer();
    //       }
    //     } else {
    //       toast(data["msg"]);
    //     }
    //   } else {
    //     toast("极验证失败");
    //   }
    // });
  }

    //检查手机是否注册
  void checkRegister(phone) {
    if (!Constants.phoneIsOk(phone)) {
      Fluttertoast.showToast(
          msg: Strings.phoneError,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    var formData = {"mobile": phone};
    request("post", allUrl["checkRegister"], formData).then((value) {
      if (value["code"] == 0 && value["data"] != null && !value["data"]["register"]) {
        geetest();
      } else {
        toast("手机号校验失败");
      }
    });
  }

  ///开始计时器
  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);
    var callback = (timer) => {
          setState(() {
            if (_allTime < 1) {
              _timer.cancel();
              _verificationText = Strings.sendVerificationCode;
            } else {
              _allTime = _allTime - 1;
              if (_allTime == 0) {
                _verificationText = Strings.sendVerificationCode;
              } else {
                _verificationText = '$_allTime ${Strings.verificationCodeTime}';
              }
            }
          })
        };
    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}
