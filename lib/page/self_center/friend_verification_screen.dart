import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/loading_state.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendVerificationScreen extends StatefulWidget {
  _FriendVerificationScreenState createState() => _FriendVerificationScreenState();
}

class _FriendVerificationScreenState extends LoadingState<FriendVerificationScreen> {
  String radio = "1";

  void updateFriendVerifivayion() {
    NetLoadingDialog.showLoadingDialog(context, "更新添加好友验证类型中...");
    var formData = {
      "friend_verification_type" : int.parse(radio)
    };
    request("post", allUrl["updateUserExtend"], formData).then((result) async {
      Navigator.of(context).pop();
      if (result["code"] == 0){
        Fluttertoast.showToast(
            msg: "更新添加好友验证类型成功！",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        Constants.userInfo.friendVerificationType = int.parse(radio);
        prefs.setString("userInfo", json.encode(Constants.userInfo.toJson()));
      }
    });
  }

  @override
  void initLoadingState() {
    initData();
    radio = Constants.userInfo.friendVerificationType.toString();
  }

  @override
  Widget loadingFailureWidget() {
    return null;
  }

  @override
  Widget loadingSuccessWidget() {

    return Material(
      color: ColorUtil.greyBG,
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true, centerText: Strings.friendVerification, rightText: Strings.save, callback: (){
            updateFriendVerifivayion();
          },),
          Container(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      radio = "1";
                    });
                  },
                  child: Container(
                    color: ColorUtil.white,
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio(
                          groupValue: radio,
                          activeColor: ColorUtil.nnBlue,
                          value: '1',
                          onChanged: (String val) {
                            setState(() {
                              radio = val;
                            });
                          },
                        ),
                        Text("允许任何人添加",
                            style: TextStyle(fontSize: 14, color: Colors.black)),
                      ],
                    ),
                  ),

                ),
                InkWell(
                    onTap: () {
                      radio = "2";
                      setState(() {

                      });
                    },
                    child: Container(
                      color: ColorUtil.white,
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            groupValue: radio,
                            activeColor: ColorUtil.nnBlue,
                            value: '2',
                            onChanged: (String val) {
                              setState(() {
                                radio = val;
                              });
                            },
                          ),
                          Text("需要验证身份",
                              style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      )),
                    ),


                InkWell(
                  onTap: () {
                    setState(() {
                      radio = "3";
                    });
                  },
                  child: Container(
                    color: ColorUtil.white,
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio(
                          groupValue: radio,
                          activeColor: ColorUtil.nnBlue,
                          value: '3',
                          onChanged: (String val) {
                            setState(() {
                              radio = val;
                            });
                          },
                        ),
                        Text("拒绝任何人添加",
                            style: TextStyle(fontSize: 14, color: Colors.black)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget loadingWidget() {
    return null;
  }

  void initData() {
    request("post", allUrl["userExtendInfo"], null).then((val){
      if (val["code"] == 0){
        radio = val["data"]["friend_verification_type"].toString();
        loadingSuccess();
      } else {
        loadingFailure("网络异常，请稍后再试");
      }
    });
  }
}
