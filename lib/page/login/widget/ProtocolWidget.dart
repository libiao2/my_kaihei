import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

import '../agreement_screen.dart';
import '../privacy_protocol_screen.dart';

class ProtocolWidget extends StatefulWidget{

  bool isCheck = false;

  Function(bool) callback;

  ProtocolWidget({this.isCheck, this.callback});

  @override
  _ProtocolWidgetState createState() => _ProtocolWidgetState();
}

class _ProtocolWidgetState extends State<ProtocolWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
        height: ScreenUtil().setHeight(20),
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  widget.isCheck = !widget.isCheck;
                  if (widget.callback != null){
                    widget.callback(widget.isCheck);
                  }
                });
              },
              child: Container(
                width: ScreenUtil().setHeight(20),
                padding: EdgeInsets.all(ScreenUtil().setHeight(2)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: widget.isCheck
                      ? Image.asset(
                    "images/icon_check.png",
                    height: ScreenUtil().setHeight(15),
                    fit: BoxFit.fill,
                  )
                      : Image.asset(
                    "images/icon_uncheck.png",
                    height: ScreenUtil().setHeight(15),
                    fit: BoxFit.fill,
                  ),
                ),
                decoration: BoxDecoration(
                  color: ColorUtil.white
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
              child: Text(
                Strings.agree,
                style: TextStyle(
                    color: ColorUtil.grey,
                    fontSize: ScreenUtil().setSp(13)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return AgreementScreen();
                }));
              },
              child: Container(
                child: Text(
                  Strings.userAgreement,
                  style: TextStyle(
                      color: ColorUtil.blue,
                      fontSize: ScreenUtil().setSp(13)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(2)),
              child: Text(
                Strings.and,
                style: TextStyle(
                    color: ColorUtil.grey,
                    fontSize: ScreenUtil().setSp(13)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return PrivacyProtocol();
                }));
              },
              child: Container(
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(2)),
                child: Text(
                  Strings.privacyProtocol2,
                  style: TextStyle(
                      color: ColorUtil.blue,
                      fontSize: ScreenUtil().setSp(13)),
                ),
              ),
            )
          ],
        ),
      );
  }

}