import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/page/login/agreement_screen.dart';
import 'package:premades_nn/page/login/privacy_protocol_screen.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

class AbountUsScreen extends StatefulWidget {
  _AbountUsScreenState createState() => _AbountUsScreenState();
}

class _AbountUsScreenState extends State<AbountUsScreen> {

  String version = "";

  @override
  Widget build(BuildContext context) {


    return Material(
      color: ColorUtil.white,
      child: Column(children: <Widget>[
        AppBarWidget(
          isShowBack: true,
          centerText: Strings.aboutUs,
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment(0.0, 0.0),
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                    child: Image.asset(
                      'images/mascot.png', //图片的路径
                      width: ScreenUtil().setWidth(75), //图片控件的宽度
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Container(
                      alignment: Alignment(0.0, 0.0),
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Text(Strings.NN,
                          style:
                          TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black, fontWeight: FontWeight.w500))
                  ),
                  Container(
                      alignment: Alignment(0.0, 0.0),
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Text(version,
                          style:
                          TextStyle(fontSize: ScreenUtil().setSp(15), color: ColorUtil.grey))
                  ),

                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                    width: ScreenUtil().setWidth(128),
                    height: ScreenUtil().setWidth(45),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        gradient: LinearGradient(
                            colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter
                        )
                    ),
                    child: Text(Strings.checkNewVersion, style: TextStyle(color: ColorUtil.white, fontSize: ScreenUtil().setSp(15)),),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return AgreementScreen();
                          }));
                        },
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                          child: Text("服务协议", style: TextStyle(color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),),
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(40),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return PrivacyProtocol();
                          }));
                        },
                        child: Container(

                          child: Text("隐私政策", style: TextStyle(color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),),
                        ),
                      ),
                    ],
                  ),


                  Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(20)),
                    child: Text(Strings.copyright, style: TextStyle(color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),),
                  ),
                ],
              ),
            ],
          ),
        ),


      ],),
    );

  }

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = "版本号：" + packageInfo.version;
        print("version = " + version);
      });
    });
  }
}
