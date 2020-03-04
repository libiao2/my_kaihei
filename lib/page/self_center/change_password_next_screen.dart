import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';

class ChangePasswordNextScreen extends StatefulWidget {

  String verificationCode;

  String phone;

  _ChangePasswordNextScreenState createState() =>
      _ChangePasswordNextScreenState();

  ChangePasswordNextScreen({Key key, this.verificationCode, this.phone}) : super(key : key);
}



class _ChangePasswordNextScreenState extends State<ChangePasswordNextScreen> {

  TextEditingController _pwdInputController = TextEditingController();
  bool isShowPwd = true;

  TextEditingController _pwdRepeatInputController = TextEditingController();
  bool isShowPwdRepeat = true;

  String seeImage = "images/see.jpg";
  String noSeeImage = "images/no_see.jpg";

  String pwdImage  = "images/no_see.jpg";
  String pwdRepeatImage = "images/no_see.jpg";


  @override
  Widget build(BuildContext context) {

    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true, centerText: Strings.confirmPassword,),
          SingleChildScrollView(child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 10, color: Color.fromRGBO(242, 242, 242, 1.0)),
                ),
              ),
              Container(
                  height: ScreenUtil().setHeight(45),
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _pwdInputController,
                          autofocus: false,
                          cursorColor: ColorUtil.black,
                          obscureText: isShowPwd,
                          maxLines: 1,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "设置您的登录密码",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (isShowPwd){
                            isShowPwd = false;
                            pwdImage = seeImage;
                          } else {
                            isShowPwd = true;
                            pwdImage = noSeeImage;
                          }
                          setState(() {
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Image.asset(
                            pwdImage, //图片的路径
                            width: 20.0, //图片控件的宽度
                            height: 20.0, //图片控件的高度
                            fit: BoxFit.cover, //告诉引用图片的控件，图像应尽可能小，但覆盖整个控件。
                          ),
                        ),
                      ),
                    ],
                  )),
              Container(
                  height: ScreenUtil().setHeight(45),
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _pwdRepeatInputController,
                          autofocus: false,
                          cursorColor: ColorUtil.black,
                          maxLines: 1,
                          obscureText: isShowPwdRepeat,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "请再次输入密码",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (isShowPwdRepeat){
                            isShowPwdRepeat = false;
                            pwdRepeatImage = seeImage;
                          } else {
                            isShowPwdRepeat = true;
                            pwdRepeatImage = noSeeImage;
                          }
                          setState(() {
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Image.asset(
                            pwdRepeatImage, //图片的路径
                            width: 20.0, //图片控件的宽度
                            height: 20.0, //图片控件的高度
                            fit: BoxFit.cover, //告诉引用图片的控件，图像应尽可能小，但覆盖整个控件。
                          ),
                        ),
                      ),
                    ],
                  )),
              Container(
                margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("密码需为6-12位数字+字母组成", style: TextStyle(fontSize: 14, color: Colors.grey),),
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 20.0),
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
                        height: ScreenUtil().setHeight(45),
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
          ))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void next() {
    String pwd = _pwdInputController.text;
    String pwdRepeat = _pwdRepeatInputController.text;


    if (pwd == null || pwd == "" || pwdRepeat == null || pwdRepeat == ""){
      Fluttertoast.showToast(
          msg: "密码不能为空！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    if (pwd != pwdRepeat){
      Fluttertoast.showToast(
          msg: "两次输入密码不一致，请重新输入！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    NetLoadingDialog.showLoadingDialog(context, "修改密码中...");

    var data = {
      'mobile': widget.phone,
      'country_code': 86,
      'code': widget.verificationCode,
      "password": Constants.generateMd5(pwd)
    };

    request('post', allUrl['passwordReset'], data).then((val) {
      Navigator.of(context).pop();
      if (val['code'] == 0) {
        Fluttertoast.showToast(
            msg: "密码修改成功！",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    });
  }
}
