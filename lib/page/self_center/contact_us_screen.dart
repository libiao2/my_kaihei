import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorUtil.white,
      child: Column(
        children: <Widget>[
          AppBarWidget(
            isShowBack: true,
            centerText: Strings.contactUs,
          ),
          Container(
            color: ColorUtil.greyBG,
            height: ScreenUtil().setHeight(10),
          ),
          Container(
            margin: EdgeInsets.all(ScreenUtil().setWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                  child: Text(
                    "雷神（武汉）信息技术有限公司",
                    style: TextStyle(
                        color: ColorUtil.black,
                        fontSize: ScreenUtil().setSp(20)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                  child: Text("商务合作：陈先生",
                      style: TextStyle(
                          color: ColorUtil.grey,
                          fontSize: ScreenUtil().setSp(15))),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                  child: Text("QQ：3004634704",
                      style: TextStyle(
                          color: ColorUtil.grey,
                          fontSize: ScreenUtil().setSp(15))),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                  child: Text("邮箱：chenchong@nn.com",
                      style: TextStyle(
                          color: ColorUtil.grey,
                          fontSize: ScreenUtil().setSp(15))),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                  child: Text("投诉客服QQ：1462019251",
                      style: TextStyle(
                          color: ColorUtil.grey,
                          fontSize: ScreenUtil().setSp(15))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
