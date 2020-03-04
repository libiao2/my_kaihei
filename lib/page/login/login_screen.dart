import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:premades_nn/bottom_navigation_widget.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/ClickButton.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/SendVerificationCodeWidget.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/verification_code_event.dart';
import 'package:premades_nn/model/user_info_entity.dart';
import 'package:premades_nn/page/login/register_screen.dart';
import 'package:premades_nn/page/login/widget/MyTextField.dart';
import 'package:premades_nn/page/login/widget/ProtocolWidget.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/OtherLoginType.dart';
import 'package:premades_nn/type/VerificationCodeType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/EncryptHelper.dart';
import 'package:premades_nn/utils/ImageUtil.dart';
import 'package:premades_nn/utils/StringUtil.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharesdk_plugin/sharesdk_defines.dart';
import 'package:sharesdk_plugin/sharesdk_interface.dart';

import 'agreement_screen.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _phonePasswordController = TextEditingController();
  TextEditingController _emailNNController = TextEditingController();
  TextEditingController _emailNNPasswordController = TextEditingController();

  //登录模式 0：邮箱nn号登录    1：手机号登录
  int loginType = 1;

  //用户协议是否选中
  bool isCheck = true;

  //极验证结果监听
  StreamSubscription<VerificationCodeEvent> _subscription;

  bool isLoginKeyBoard = false;

  int leigodLoginType = 0; //0手机登录，1邮箱账号登录

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    double keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyBoardHeight != null && keyBoardHeight != 0.0 && isLoginKeyBoard) {
      SharedPreferences.getInstance().then((sp) {
        double screenHeight = MediaQuery.of(context).size.height;
        double statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
        sp.setDouble("keyBoardHeight", keyBoardHeight);
        sp.setDouble("screenHeight", screenHeight);
        sp.setDouble("statusBarHeight", statusBarHeight);
        Constants.keyBoardHeight = keyBoardHeight;
        Constants.screenHeight = screenHeight;
        Constants.statusBarHeight = statusBarHeight;
      });
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
                isShowBack: false,
                rightText: Strings.forgetPassword,
                callback: jumpToForgetPassword,
              ),
              Expanded(
                child:  Container(
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30),
                      ScreenUtil().setWidth(40), ScreenUtil().setWidth(30), 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          //您好
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Strings.hello,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ScreenUtil().setSp(36)),
                            ),
                          ),

                          //欢迎...注册
                          Container(
                              margin: EdgeInsets.only(top: ScreenUtil().setHeight(7)),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    Strings.welcomeToNN,
                                    style: TextStyle(
                                        color: ColorUtil.grey,
                                        fontSize: ScreenUtil().setSp(18)),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      jumpToRegister();
                                    },
                                    child: Text(
                                      Strings.register,
                                      style: TextStyle(
                                          color: ColorUtil.blue,
                                          fontSize: ScreenUtil().setSp(18)),
                                    ),
                                  ),
                                ],
                              )),

                          //手机号登录
                          Offstage(
                            offstage: loginType == 0,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(50)),
                                  height: ScreenUtil().setHeight(65),
                                  child: MyTextField(
                                    controller: _phoneController,
                                    obscureText: false,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(RegExp("[0-9]")),
                                    ],
                                    textInputType: TextInputType.number,
                                    hintNormal: Strings.accountInputHint,
                                    hintClick: Strings.phone,
                                    callBack: () {
                                      isLoginKeyBoard = true;
                                    },
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: ScreenUtil().setHeight(65),
                                  child: MyTextField(
                                    textInputType: TextInputType.text,
                                    obscureText: true,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(RegExp("[0-9a-zA-Z]")),
                                    ],
                                    controller: _phonePasswordController,
                                    hintNormal: Strings.passwordInputHint,
                                    hintClick: Strings.password,
                                    callBack: () {
                                      isLoginKeyBoard = false;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //邮箱NN号登录
                          Offstage(
                            offstage: loginType == 1,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(50)),
                                  height: ScreenUtil().setHeight(65),
                                  child: MyTextField(
                                    controller: _emailNNController,
                                    obscureText: false,
                                    textInputType: TextInputType.text,
                                    hintNormal: Strings.inputEmailNN,
                                    hintClick: Strings.emailOrNN,
                                    callBack: () {
                                      isLoginKeyBoard = true;
                                    },
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: ScreenUtil().setHeight(65),
                                  child: MyTextField(
                                    controller: _emailNNPasswordController,
                                    obscureText: true,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(RegExp("[0-9a-zA-Z]")),
                                    ],
                                    textInputType: TextInputType.text,
                                    hintNormal: Strings.passwordInputHint,
                                    hintClick: Strings.password,
                                    callBack: () {
                                      isLoginKeyBoard = false;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //协议
                          ProtocolWidget(
                            isCheck: isCheck,
                            callback: (result) {
                              isCheck = result;
                            },
                          ),

                          //登录类型---登录
                          Container(
                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.center,
                                    height: ScreenUtil().setHeight(50),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (loginType == 0){
                                            loginType = 1;
                                            _emailNNController.text = "";
                                            _emailNNPasswordController.text = "";
                                          } else {
                                            loginType = 0;
                                            _phoneController.text = "";
                                            _phonePasswordController.text = "";
                                          }
                                        });
                                      },
                                      child: Text(
                                        loginType == 0
                                            ? Strings.passwordLogin
                                            : Strings.emailLogin,
                                        style: TextStyle(
                                            color: ColorUtil.grey,
                                            fontSize: ScreenUtil().setSp(14)),
                                      ),
                                    )),
                                ClickButton(
                                    text: Strings.login,
                                    width: ScreenUtil().setWidth(100),
                                    height: ScreenUtil().setHeight(50),
                                    clickCallback: () {
                                      onLogin();
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),

                      //第三方登录
                      Container(
                        margin: EdgeInsets.only(left: ScreenUtil().setWidth(50), right: ScreenUtil().setWidth(50), bottom: ScreenUtil().setWidth(30)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: InkWell(
                                onTap: () {
                                  wxLogin();
                                },
                                child: Container(
                                  width: ScreenUtil().setWidth(32),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.asset(
                                      "images/icon_wx_login.png",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: InkWell(
                                onTap: () {
                                  qqLogin();
                                },
                                child: Image.asset(
                                  "images/icon_qq_login.png",
                                  width: ScreenUtil().setWidth(32),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Container(
                              child: InkWell(
                                onTap: () {
                                  sinaLogin();
                                },
                                child: Image.asset(
                                  "images/icon_login_weibo.png",
                                  width: ScreenUtil().setWidth(32),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  ///跳转忘记密码
  void jumpToForgetPassword() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ForgetPasswordScreen(0);
    }));
  }

  ///跳转注册
  void jumpToRegister() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RegisterScreen();
    }));
  }

  ///登录
  Future onLogin() async {
    String phone = _phoneController.text;
    String phonePwd = _phonePasswordController.text;
    String emailNN = _emailNNController.text;
    String emailNNPwd = _emailNNPasswordController.text;

    if (!isCheck) {
      toast(Strings.agreeUserAgreement);
      return;
    }

    if (loginType == 0) {
      emailNNLogin(emailNN, emailNNPwd);
    } else if (loginType == 1) {
      phoneLogin(phone, phonePwd);
    }
  }

  ///邮箱NN登录
  void emailNNLogin(String emailNN, String emailNNPwd) {
    if (emailNN == null ||
        !Constants.isEmail(emailNN) && !Constants.isNNID(emailNN)) {
      toast(Strings.emailNNError);
      return;
    }

    if (emailNNPwd == null || emailNNPwd == "") {
      toast(Strings.passwordError);
      return;
    }

    var data = {
      'email': emailNN,
      'country_code': 86,
      'password': Constants.generateMd5(emailNNPwd),
    };

    NetLoadingDialog.showLoadingDialog(context, Strings.logining);
    request('post', allUrl['accountLogin'], data).then((val) {
      if (val['code'] == 0) {
        if (Constants.isNNID(emailNN)) {
          saveAndJump(val);
        } else {
          if (val['data'] != null &&
              val['data']['need_bind_mobile'] != null &&
              val['data']['need_bind_mobile']) {
            NetLoadingDialog.dismiss(context);
            showBottomWidget(val['data']['bind_token'], true);
          } else {
            saveAndJump(val);
          }
        }
      } else {
        NetLoadingDialog.dismiss(context);
        toast(val["msg"]);
      }
    });
  }

  ///手机号登录
  void phoneLogin(String phone, String phonePwd) {
    if (phone == null || !Constants.phoneIsOk(phone)) {
      toast(Strings.phoneError);
      return;
    }

    if (phonePwd == null || phonePwd == "") {
      toast(Strings.passwordError);
      return;
    }

    var data = {
      'mobile': phone,
      'country_code': 86,
      'password': Constants.generateMd5(phonePwd),
    };
    NetLoadingDialog.showLoadingDialog(context, Strings.logining);
    request('post', allUrl['accountLogin'], data).then((val) {
      if (val['code'] == 0) {
        saveAndJump(val);
      } else {
        NetLoadingDialog.dismiss(context);
        toast(val["msg"]);
      }
    });
  }

  ///保存个人信息并跳转到首页
  void saveAndJump(val) {
    SharedPreferences.getInstance().then((sp) {
      sp.setString('loginToken', val['data']['token']);
      sp.setString('gateway', val['data']['gateway']);
      print("登录成功！ gateway=" + val['data']['gateway']);
      Constants.token = val['data']['token'];
      Constants.gateway = val['data']['gateway'];

      //登陆完成-查询用户详情
      request('post', allUrl['user_info'], null).then((val) {
        NetLoadingDialog.dismiss(context);
        if (val['code'] == 0) {
          save(val['data']);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => BottomNavigationWidget()),
              (route) => route == null);
        } else {
          toast(val["msg"]);
        }
      });
    });
  }

  ///存储用户个人信息
  Future save(obj) async {
    Provide.value<UserInfoStore>(context).setUserInfo(obj);
    Constants.userInfo = UserInfoEntity.fromJson(obj);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userInfo', json.encode(obj));

    String picName = Constants.userInfo.avatar.substring(
        Constants.userInfo.avatar.lastIndexOf("/") + 1,
        Constants.userInfo.avatar.lastIndexOf("."));
    requestPermission(Constants.userInfo.avatar, picName);
  }

  ///保存头像 需要的存储权限
  Future requestPermission(String avatar, String picName) async {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((permission) {
      if (permission == PermissionStatus.granted) {
        ImageUtil.fetchImage(avatar, picName);
      }
    });
  }

  ///新浪登录
  Future sinaLogin() async {
    SharesdkPlugin.getUserInfo(ShareSDKPlatforms.sina,
        (SSDKResponseState state, Map user, SSDKError error) {
      Map userInfo = jsonDecode(user["dbInfo"]);
      checkIsNeedBindPhone(
          OtherLoginType.SINA, userInfo["userID"], userInfo["userID"]);
    });
  }

  ///微信登录
  Future wxLogin() async {
    SharesdkPlugin.getUserInfo(ShareSDKPlatforms.wechatSession,
        (SSDKResponseState state, Map user, SSDKError error) {
      Map userInfo = jsonDecode(user["dbInfo"]);
      checkIsNeedBindPhone(
          OtherLoginType.WECHAT, userInfo["unionid"], userInfo["openid"]);
    });
  }

  ///QQ登录
  Future qqLogin() async {
    SharesdkPlugin.getUserInfo(ShareSDKPlatforms.qq,
        (SSDKResponseState state, Map user, SSDKError error) {
      Map userInfo = jsonDecode(user["dbInfo"]);
      checkIsNeedBindPhone(
          OtherLoginType.QQ, userInfo["userID"], userInfo["unionid"]);
    });
  }

  ///检查是否需要绑定手机
  Future checkIsNeedBindPhone(
      int loginType, String openID, String unionID) async {
    var formData = {"type": loginType, "open_id": openID, "union_id": unionID};

    NetLoadingDialog.showLoadingDialog(context, Strings.loading);

    String encryptData = await EncryptHelper.encodeLong(formData);

    print("参数：$formData");
    request("post", allUrl["oauthLogin"], encryptData).then((value) {
      NetLoadingDialog.dismiss(context);
      if (value["code"] == 0) {
        if (value["data"]["need_bind_mobile"] != null &&
            value["data"]["need_bind_mobile"]) {
          showBottomWidget(value["data"]["bind_token"], false);
        } else {
          saveAndJump(value);
        }
      } else {
        toast(value["msg"]);
      }
    });
  }

  TextEditingController _otherLoginPhoneController = TextEditingController();
  TextEditingController _otherLoginCodeController = TextEditingController();
  TextEditingController _otherLoginPwdController = TextEditingController();

  ///第三方登录绑定手机---界面
  void showBottomWidget(String bindToken, bool isEmailLogin) {
    bool isNeedPwd = false;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: BoxDecoration(
                  color: ColorUtil.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              top: ScreenUtil().setHeight(15),
                              left: ScreenUtil().setHeight(30)),
                          child: Text(
                            Strings.bindPhone,
                            style: TextStyle(
                                color: ColorUtil.black,
                                fontSize: ScreenUtil().setSp(18)),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              top: ScreenUtil().setHeight(15),
                              right: ScreenUtil().setHeight(15)),
                          width: ScreenUtil().setHeight(25),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset("images/icon_close.png"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(30),
                        ScreenUtil().setWidth(50),
                        ScreenUtil().setWidth(30),
                        0),
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
                                    controller: _otherLoginPhoneController,
                                    obscureText: false,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(RegExp("[0-9]")),
                                    ],
                                    textInputType: TextInputType.text,
                                    hintNormal: Strings.accountInputHint,
                                    hintClick: Strings.phone,
                                    callBack: () {
                                      isLoginKeyBoard = true;
                                    },
                                  ),
                                ),

                                //发送验证码
                                SendVerificationCodeWidget(
                                  accountController: _otherLoginPhoneController,
                                  verificationCodeType: isEmailLogin
                                      ? VerificationCodeType.bindPhone
                                      : VerificationCodeType
                                          .otherLoginBindPhone,
                                  bindToken: bindToken,
                                  mCallback: (bindStates) {
                                    setDialogState(() {
                                      if (bindStates == 3 || bindStates == 0) {
                                        isNeedPwd = false;
                                      } else if (bindStates == 4) {
                                        isNeedPwd = true;
                                      }
                                    });
                                  },
                                ),
                              ],
                            )),

                        //验证码
                        Container(
                          alignment: Alignment.centerLeft,
                          height: ScreenUtil().setHeight(65),
                          child: MyTextField(
                            controller: _otherLoginCodeController,
                            obscureText: false,
                            inputFormatters: [
                              WhitelistingTextInputFormatter(RegExp("[0-9]")),
                            ],
                            textInputType: TextInputType.number,
                            hintNormal: Strings.verificationInputHint,
                            hintClick: Strings.verification,
                            callBack: () {
                              isLoginKeyBoard = false;
                            },
                          ),
                        ),

                        //密码
                        Offstage(
                          offstage: !isNeedPwd,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            height: ScreenUtil().setHeight(65),
                            child: MyTextField(
                              controller: _otherLoginPwdController,
                              obscureText: true,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[0-9a-zA-Z]")),
                              ],
                              textInputType: TextInputType.text,
                              hintNormal: Strings.passwordInputHint,
                              hintClick: Strings.password,
                              callBack: () {
                                isLoginKeyBoard = false;
                              },
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.topRight,
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setHeight(85)),
                          child: ClickButton(
                              text: Strings.bind,
                              width: ScreenUtil().setWidth(100),
                              height: ScreenUtil().setHeight(50),
                              clickCallback: () {
                                onOtherLoginRegister(isNeedPwd, bindToken);
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///第三方登录绑定手机
  void onOtherLoginRegister(bool isNeedPwd, String token) {
    String account = _otherLoginPhoneController.text;
    String verificationCode = _otherLoginCodeController.text;
    String password = _otherLoginPwdController.text;

    if (account == null || !Constants.phoneIsOk(account)) {
      toast(Strings.phoneError);
      return;
    }

    if (verificationCode == null || verificationCode == "") {
      toast(Strings.verificationCodeError);
      return;
    }

    if (isNeedPwd) {
      String verificationResult = StringUtil.passWordVerification(password);
      if (verificationResult != Strings.SUCCESS) {
        toast(verificationResult);
        return;
      }
    }

    NetLoadingDialog.showLoadingDialog(context, "提交中...");
    var data = {
      'token': token,
      'mobile': account,
      'country_code': 86,
      'smscode': verificationCode,
      'smscode_key': Constants.smscodeKey,
      'password': Constants.generateMd5(password),
      'register_type': VerificationCodeType.bindPhone,
    };

    request('post', allUrl['oauthBindPhone'], data).then((val) {
      NetLoadingDialog.dismiss(context);
      if (val["code"] == 0) {
        saveAndJump(val);
      } else {
        toast(val["msg"]);
      }
    });
  }
}
