import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

class OnlineServerScreen extends StatefulWidget{

  @override
  _OnlineServerScreenState createState() => _OnlineServerScreenState();

}

class _OnlineServerScreenState extends State<OnlineServerScreen>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (_) => WebviewScaffold(
          url: "http://uchat.im-cc.com/webchat_new/static/html/index.html?ht=cxFmDV",
          appBar: AppBar(
            backgroundColor: ColorUtil.white,
            centerTitle: true,
            leading:
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Image.asset("images/go_back.png", width: 20, height: 20,),

                ),

            title: Text(Strings.onlineServer,style: TextStyle(color: ColorUtil.black, fontSize: ScreenUtil().setSp(16)),),
          ),
        ),
      },
    );

//    return Material(
//      child: Column(
//        children: <Widget>[
//          AppBarWidget(isShowBack: true, centerText: Strings.onlineServer,),
//
//        ],
//      ),
//    );
  }

}