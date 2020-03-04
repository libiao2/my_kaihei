import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUserNameScreen extends StatefulWidget {
  _EditUserNameState createState() => _EditUserNameState();
}

class _EditUserNameState extends State<EditUserNameScreen> {
  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Provide<UserInfoStore>(
        builder: (context, child, userInfoStore){
          _inputController.text = userInfoStore.userInfo.nickname;
          return Material(
            child: Column(
              children: <Widget>[
                AppBarWidget(isShowBack: true, centerText: Strings.pleaseInputNickname, rightText: Strings.save, callback: (){
                  updateUserNickName(userInfoStore);
                },),
                Container(
                  height: ScreenUtil().setHeight(60),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          cursorColor: ColorUtil.black,
                          autofocus: true,
                          maxLength: 15,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              hintText: userInfoStore.userInfo.nickname,
                              hintStyle: TextStyle(
                                  color: Color.fromRGBO(207, 207, 207, 1),
                                  fontSize: ScreenUtil.getInstance().setSp(14)),
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none)),
//                  onChanged: _onChanged,
                        ),
                      )
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(242, 242, 242, 1),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                )
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  //修改昵称
  void updateUserNickName(UserInfoStore userInfoStore){
    String nickName = _inputController.text;
    if (nickName == null || nickName == ""){
      toast("昵称不能为空！");
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return NetLoadingDialog(
            outsideDismiss: false,
            loadingText: "修改昵称中...",
          );
        });

    var data = {
      'nickname': nickName,
    };

    request("post", allUrl["nickname_exist"], data).then((result){
      if(result["code"] == 0){
        if (result["data"] != null){
          if (result["data"]["exist"]){
            toast("昵称已存在");
            Navigator.of(context).pop();
          } else {
            request('post', allUrl['user_information'], data).then((val) async {
              Navigator.of(context).pop();
              if (val['code'] == 0) {
                //修改昵称成功
                SharedPreferences prefs = await SharedPreferences.getInstance();
                userInfoStore.userInfo.nickname = nickName;
                Provide.value<UserInfoStore>(context).updateUserInfo();
                Constants.userInfo.nickname = nickName;
                prefs.setString("userInfo", json.encode(Constants.userInfo.toJson()));

                Fluttertoast.showToast(
                    msg: '昵称修改成功！',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0);

                Navigator.pop(context);
              }
            });
          }
        } else {
          toast("返回参数异常");
          Navigator.of(context).pop();
        }
      } else {
        toast(result["msg"]);
        Navigator.of(context).pop();
      }
    });
  }
}
