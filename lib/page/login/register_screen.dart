import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/ClickButton.dart';
import 'package:premades_nn/components/SendVerificationCodeWidget.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/page/login/widget/MyTextField.dart';
import 'package:premades_nn/page/login/widget/ProtocolWidget.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/VerificationCodeType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/StringUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

import 'agreement_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  TextEditingController accountController = TextEditingController();
  TextEditingController verificationController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //用户协议是否选中
  bool isCheck = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Constants.statusBarHeight = MediaQueryData.fromWindow(window).padding.top;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Material(
        color: ColorUtil.white,
        child: Column(
          children: <Widget>[
            AppBarWidget(
              isShowBack: true,
              rightWidget: InkWell(
                onTap: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: ScreenUtil().setHeight(10)),
                  height: ScreenUtil().setHeight(50),
                  child: Row(
                    children: <Widget>[
                      Text(
                        Strings.haveAccount,
                        style: TextStyle(
                            color: ColorUtil.grey,
                            fontSize: ScreenUtil().setSp(14)),
                      ),
                      Text(
                        Strings.login,
                        style: TextStyle(
                            color: ColorUtil.blue,
                            fontSize: ScreenUtil().setSp(14)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30),
                  ScreenUtil().setWidth(40), ScreenUtil().setWidth(30), 0),
              child: Column(
                children: <Widget>[
                  //输入手机号---发送验证码
                  Container(
                      alignment: Alignment.centerLeft,
                      height: ScreenUtil().setHeight(65),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: accountController,
                              obscureText: false,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[0-9]")),
                              ],
                              textInputType: TextInputType.number,
                              hintNormal: Strings.accountInputHint,
                              hintClick: Strings.phone,
                            ),
                          ),

                          //发送验证码
                          SendVerificationCodeWidget(
                            accountController: accountController,
                            verificationCodeType: VerificationCodeType.register,
                          ),
                        ],
                      )),

                  //验证码
                  Container(
                    alignment: Alignment.centerLeft,
                    height: ScreenUtil().setHeight(65),
                    child: MyTextField(
                      controller: verificationController,
                      obscureText: false,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[0-9]")),
                      ],
                      textInputType: TextInputType.number,
                      hintNormal: Strings.verificationInputHint,
                      hintClick: Strings.verification,
                    ),
                  ),

                  //密码登录
                  Container(
                    alignment: Alignment.centerLeft,
                    height: ScreenUtil().setHeight(65),
                    child: MyTextField(
                      controller: verificationController,
                      obscureText: true,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[0-9a-zA-Z]")),
                      ],
                      textInputType: TextInputType.text,
                      hintNormal: Strings.passwordInputHint,
                      hintClick: Strings.password,
                    ),
                  ),

                  //协议
                  ProtocolWidget(
                    isCheck: isCheck,
                    callback: (result) {
                      isCheck = result;
                    },
                  ),

                  //登录
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
                    child: ClickButton(
                        text: Strings.register,
                        width: ScreenUtil().setWidth(100),
                        height: ScreenUtil().setHeight(50),
                        clickCallback: () {
                          onRegister();
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future onRegister() async {
    String account = accountController.text;
    String verificationCode = verificationController.text;
    String password = passwordController.text;

    if (account == null || !Constants.phoneIsOk(account)) {
      toast(Strings.phoneError);
      return;
    }

    String verificationResult = StringUtil.passWordVerification(password);
    if (verificationResult != Strings.SUCCESS) {
      toast(verificationResult);
      return;
    }

    if (verificationCode == null || verificationCode == "") {
      toast(Strings.verificationCodeError);
      return;
    }

    if (!isCheck) {
      toast(Strings.agreeUserAgreement);
      return;
    }

    var data = {
      'mobile': accountController.text,
      'country_code': 86,
      'smscode': verificationController.text,
      'smscode_key': Constants.smscodeKey,
      'password': Constants.generateMd5(passwordController.text),
      'type': VerificationCodeType.register,
    };

    request('post', allUrl['register'], data).then((val) {
      if (val["code"] == 0) {
        toast(Strings.registerSuccess);
        Navigator.pop(context);
      } else {
        toast(val["msg"]);
      }
    });
  }
}
