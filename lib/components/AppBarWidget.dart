import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';

class AppBarWidget extends StatelessWidget {
  final bool isShowBack;
  final String centerText;
  final String rightText;
  final Function callback;
  final Color bgColor;

  Widget rightWidget;

  AppBarWidget(
      {this.centerText, this.callback, this.rightText, this.isShowBack, this.rightWidget, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor == null?ColorUtil.white:bgColor,
      child: Container(
        margin: EdgeInsets.only(top: MediaQueryData.fromWindow(window).padding.top),
        height: ScreenUtil().setHeight(50),
        child: Row(
          children: <Widget>[
            Offstage(
              offstage: !isShowBack,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: ScreenUtil().setHeight(50),
                  width: ScreenUtil().setHeight(50),
                  child: Image.asset(
                    "images/go_back.png",
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: isShowBack,
              child: Container(
                margin: EdgeInsets.only(left: ScreenUtil().setHeight(50)),
              ),
            ),
            Expanded(
              child: Offstage(
                offstage: centerText == null,
                child: Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setHeight(30)),
                  alignment: Alignment.center,
                  child: Text(
                    centerText == null ? "" : centerText,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: rightText != null,
              child: Container(
                margin: EdgeInsets.only(right: ScreenUtil().setHeight(70)),
              ),
            ),
            Offstage(
                offstage: rightText == null,
                child: InkWell(
                  onTap: () {
                    if (callback != null) {
                      callback();
                    }
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 10),
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setHeight(70),
                    child: Text(
                      rightText == null ? "" : rightText,
                      style: TextStyle(
                          color: ColorUtil.grey, fontSize: ScreenUtil().setSp(14)),
                    ),
                  ),
                )
            ),

            Offstage(
                offstage: rightWidget == null,
                child: rightWidget
            ),
          ],
        ),
      ),
    );
  }
}
