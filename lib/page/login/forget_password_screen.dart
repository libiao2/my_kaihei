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
import 'package:premades_nn/plugin/FloatWindow.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/VerificationCodeType.dart';
import 'package:premades_nn/utils/AudioPlayerUtil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/StringUtil.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'agreement_screen.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {

  int type; //0:忘记密码  1：修改密码


  ForgetPasswordScreen(this.type);

  @override
  ForgetPasswordScreenState createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController accountController = TextEditingController();
  TextEditingController verificationController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String title;
  String _showPhone;

  @override
  void initState() {
    super.initState();

    if (widget.type == 1) {
      _showPhone = Constants.userInfo.mobile.replaceAll(
          Constants.userInfo.mobile.substring(3, 7), "****");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Constants.statusBarHeight = MediaQueryData
        .fromWindow(window)
        .padding
        .top;


    if (widget.type == 0) {
      title = Strings.forgetPassword;
    } else if (widget.type == 1) {
      title = Strings.updatePassword;
    }

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
              centerText: title,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30),
                  ScreenUtil().setWidth(40), ScreenUtil().setWidth(30), 0),
              child: Column(
                children: <Widget>[

                  widget.type == 1 ?
                  Container(
                    child: Column(
                      children: <Widget>[
                        //验证码
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text("验证码将发送至：" + _showPhone,
                              style: TextStyle()),
                        ),

                        Container(
                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(
                                20)),
                            alignment: Alignment.centerLeft,
                            height: ScreenUtil().setHeight(65),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: MyTextField(
                                    controller: verificationController,
                                    obscureText: false,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(
                                          RegExp("[0-9]")),
                                    ],
                                    textInputType: TextInputType.number,
                                    hintNormal: Strings.verificationInputHint,
                                    hintClick: Strings.verification,
                                  ),
                                ),

                                //发送验证码
                                SendVerificationCodeWidget(
                                  verificationCodeType: VerificationCodeType
                                      .fotgetPassword,
                                ),
                              ],
                            )),
                      ],
                    ),
                  )
                      :
                  Column(
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
                                    WhitelistingTextInputFormatter(
                                        RegExp("[0-9]")),
                                  ],
                                  textInputType: TextInputType.number,
                                  hintNormal: Strings.accountInputHint,
                                  hintClick: Strings.phone,
                                ),
                              ),

                              //发送验证码
                              SendVerificationCodeWidget(
                                accountController: accountController,
                                verificationCodeType: VerificationCodeType
                                    .fotgetPassword,
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
                    ],
                  ),

                  //密码登录
                  Container(
                    alignment: Alignment.centerLeft,
                    height: ScreenUtil().setHeight(65),
                    child: MyTextField(
                      controller: passwordController,
                      obscureText: true,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[0-9a-zA-Z]")),
                      ],
                      textInputType: TextInputType.number,
                      hintNormal: Strings.passwordInputHint,
                      hintClick: Strings.password,
                    ),
                  ),


                  Container(
                    alignment: Alignment.topRight,
                    child: ClickButton(
                        text: Strings.sure,
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(40)),
                        width: ScreenUtil().setWidth(100),
                        height: ScreenUtil().setHeight(50),
                        clickCallback: () {
                          onUpdatePassword();
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///修改密码
  Future onUpdatePassword() async {
    String account = accountController.text;
    String verificationCode = verificationController.text;
    String password = passwordController.text;

    if (widget.type == 0 &&
        (account == null || !Constants.phoneIsOk(account))) {
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

    String mobile;
    if (widget.type == 1) {
      mobile = Constants.userInfo.mobile;
    } else if (widget.type == 0) {
      mobile = accountController.text;
    }

    var data = {
      'mobile': mobile,
      'country_code': 86,
      'smscode': verificationController.text,
      'smscode_key': Constants.smscodeKey,
      'password': Constants.generateMd5(passwordController.text),
      'type': VerificationCodeType.fotgetPassword,
    };

    request('post', allUrl['passwordReset'], data).then((val) async {
      if (val["code"] == 0) {
        toast(Strings.updatePasswordSuccess);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('loginToken', null);
        prefs.setString('userInfo', null);
        prefs.setString('gateway', null);
        SocketHelper.closeChannel();

        AudioPlayerUtil.instance.voiceCallPlayStop();
        FloatWindow.instance.close();

        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }), (check) => false);
      } else {
        toast(val["msg"]);
      }
    });
  }
}
