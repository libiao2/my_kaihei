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

class EditUserSignatureScreen extends StatefulWidget {
  _EditUserSignatureScreenState createState() =>
      _EditUserSignatureScreenState();
}

class _EditUserSignatureScreenState extends State<EditUserSignatureScreen> {
  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Provide<UserInfoStore>(builder: (context, child, userInfoStore) {
      _inputController.text = userInfoStore.userInfo.intro;
      return Material(
          child: Column(children: <Widget>[
        AppBarWidget(
          isShowBack: true,
          centerText: Strings.pleaseInputIntro,
          rightText: Strings.save,
          callback: () {
            updateUserSignature(userInfoStore);
          },
        ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      cursorColor: ColorUtil.black,
                      autofocus: true,
                      maxLength: 20,
                      maxLines: 2,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          hintText: userInfoStore.userInfo.intro,
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(207, 207, 207, 1),
                              fontSize: ScreenUtil.getInstance().setSp(14)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none)),
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
      ])
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  //修改个性签名
  void updateUserSignature(UserInfoStore userInfoStore) {
    String signature = _inputController.text;
    if (signature == null || signature == "") {
      Fluttertoast.showToast(
          msg: '个性签名不能为空！',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return NetLoadingDialog(
            outsideDismiss: false,
            loadingText: "修改个性签名中...",
          );
        });

    var data = {
      'intro': signature,
    };

    request('post', allUrl['user_information'], data).then((val) async {
      Navigator.of(context).pop();
      if (val['code'] == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Constants.userInfo.intro = signature;
        userInfoStore.userInfo.intro = signature;
        Provide.value<UserInfoStore>(context).updateUserInfo();
        prefs.setString("userInfo", json.encode(Constants.userInfo.toJson()));

        toast("个性签名修改成功！");
        Navigator.pop(context);
      }
    });
  }
}
