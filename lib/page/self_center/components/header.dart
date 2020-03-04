import 'package:flutter/material.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import '../../../provide/storeData.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../my_infomation.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Image headImg;
    if (Constants.headImgFile == null) {
      headImg = Image.network(
        Constants.userInfo.avatar,
        width: ScreenUtil().setWidth(66),
        fit: BoxFit.fitWidth,
      );
    } else {
      headImg = Image.file(
        Constants.headImgFile,
        width: ScreenUtil().setWidth(66),
        fit: BoxFit.fitWidth,
      );
    }

    return Provide<UserInfoStore>(builder: (context, child, userInfoStore) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setHeight(15.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      settings: RouteSettings(name: "myInformation"),
                      builder: (context) {
                        return MyInformationScreen();
                      }));
                },
                child: Image.asset(
                  'images/icon_more.png',
                  width: 16,
                  height: 16,
                ),
              ),
              decoration: BoxDecoration(color: Colors.transparent),
            ),

            Row(
              children: <Widget>[
                //头像
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(73),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipOval(
                            child: Image.network(
                              userInfoStore.userInfo.avatar,
                            ),
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(5)),
                      child: userInfoStore.userInfo.gender == 1
                          ? Image.asset(
                              "images/icon_boy.png",
                              width: ScreenUtil().setWidth(16),
                              fit: BoxFit.fitWidth,
                            )
                          : Image.asset(
                              "images/icon_girl.png",
                              width: ScreenUtil().setWidth(16),
                              fit: BoxFit.fitWidth,
                            ),
                    ),
                  ],
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(15.0),
                ),

                Expanded(
                  child: Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(userInfoStore.userInfo.nickname,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(20),
                            fontWeight: FontWeight.w500,
                          )),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: ScreenUtil().setHeight(4)),
                        height: ScreenUtil().setHeight(20),
                        width: ScreenUtil().setWidth(100),
                        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(5),
                            0, ScreenUtil().setWidth(5), 0),
                        child: Text(
                          "NN:${userInfoStore.userInfo.nnId}",
                          style: TextStyle(
                              color: ColorUtil.nnBlue,
                              fontSize: ScreenUtil().setSp(12)),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border:
                                Border.all(color: ColorUtil.blue, width: 1)),
                      ),
                      addressAndConstellation(userInfoStore),
                    ],
                  )),
                ),
              ],
            ),

            //个性签名
            Offstage(
              offstage: userInfoStore.userInfo.intro == "",
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Strings.intro,
                      style: TextStyle(
                          color: ColorUtil.black,
                          fontSize: ScreenUtil().setSp(18),
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Text(
                        userInfoStore.userInfo.intro,
                        style: TextStyle(
                            color: ColorUtil.black,
                            fontSize: ScreenUtil().setSp(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  ///地址和星座
  Widget addressAndConstellation(UserInfoStore userInfoStore) {
    String content = "";
    if (userInfoStore.userInfo.region1 != null &&
        userInfoStore.userInfo.region1 != "") {
      content += userInfoStore.userInfo.region1;
    }

    if (userInfoStore.userInfo.region2 != null &&
        userInfoStore.userInfo.region2 != "" &&
        content != "") {
      content += " " + userInfoStore.userInfo.region2;
    }

    if (userInfoStore.userInfo.birthday != null &&
        userInfoStore.userInfo.birthday != "") {
      String constellation =
          Constants.getConstellation(userInfoStore.userInfo.birthday);
      if (content == "") {
        content = constellation;
      } else {
        content += "丨" + constellation;
      }
    }

    return Offstage(
      offstage: content == "",
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setHeight(4)),
        child: Text(
          content,
          style: TextStyle(
              color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),
        ),
      ),
    );
  }
}
