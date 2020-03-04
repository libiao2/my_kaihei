import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

class ChangePhoneSuccessScreen extends StatefulWidget {
  _ChangePhoneSuccessScreenState createState() => _ChangePhoneSuccessScreenState();
}

class _ChangePhoneSuccessScreenState extends State<ChangePhoneSuccessScreen> {

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true, centerText: Strings.updatePhone,),

          Container(
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(100),
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                'images/icon_success.png', //图片的路径
              ),
            ),
          ),
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
              child: Text("您已成功绑定手机号",
                  style:
                  TextStyle(fontSize: 18, color: ColorUtil.nnBlue))
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
            child: Material(
              child: new Ink(
                decoration: new BoxDecoration(
                  color: ColorUtil.nnBlue,
                  borderRadius:
                  new BorderRadius.all(new Radius.circular(22.0)),
                ),
                child: new InkWell(
                  borderRadius: new BorderRadius.circular(22.0),
                  onTap: () {
                    back();
                  },
                  child: new Container(
                    height: 40.0,
                    //设置child 居中
                    alignment: Alignment(0, 0),
                    child: Text(
                      "返回",
                      style: TextStyle(
                          color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

//    return Scaffold(
//      appBar: AppBar(
//        centerTitle: true,
//        title: Text('绑定手机号'),
//      ),
//      body: Column(
//        children: <Widget>[
//          Container(
//            alignment: Alignment.center,
//            margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
//            child: AspectRatio(
//              aspectRatio: 1,
//              child: Image.asset(
//                'images/icon_success.png', //图片的路径
//                width: ScreenUtil().setWidth(150), //图片控件的宽度
//              ),
//            ),
//          ),
//          Container(
//              alignment: Alignment.center,
//              margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
//              child: Text("您已成功绑定手机号",
//                  style:
//                  TextStyle(fontSize: 18, color: ColorUtil.nnBlue))
//          ),
//          Container(
//            margin: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
//            child: Material(
//              child: new Ink(
//                decoration: new BoxDecoration(
//                  color: ColorUtil.nnBlue,
//                  borderRadius:
//                  new BorderRadius.all(new Radius.circular(22.0)),
//                ),
//                child: new InkWell(
//                  borderRadius: new BorderRadius.circular(22.0),
//                  onTap: () {
//                    back();
//                  },
//                  child: new Container(
//                    height: 40.0,
//                    //设置child 居中
//                    alignment: Alignment(0, 0),
//                    child: Text(
//                      "返回",
//                      style: TextStyle(
//                          color: Colors.white, fontSize: 16.0),
//                    ),
//                  ),
//                ),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
  }

  @override
  void initState() {
    super.initState();
  }

  void back() {
    Navigator.popUntil(context, ModalRoute.withName("securityCenter"));
  }
}
