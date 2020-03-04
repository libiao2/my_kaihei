import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/page/news/share_room_screen.dart';
import '../../../components/toast.dart';
import 'package:sharesdk_plugin/sharesdk_plugin.dart';

List shareList = [
    {
      'title': 'QQ好友',
      'img': 'images/qq@3x.png'
    },
    {
      'title': '微信好友',
      'img': 'images/wechat@3x.png'
    },
    {
      'title': 'QQ空间',
      'img': 'images/qzone@3x.png'
    },
    {
      'title': '朋友圈',
      'img': 'images/firend@3x.png'
    },
    {
      'title': 'NN好友',
      'img': 'images/nn@3x.png'
    }
  ];


shareQQ (roomNo) {
  ShareSDKRegister register = ShareSDKRegister();
  register.setupQQ("101839286", "532f43f9d525bcbaeb9f862d06a9404c");
  SharesdkPlugin.regist(register);

   SSDKMap params = SSDKMap()
      ..setQQ(
          "天涯何处无芳草，组队开黑好不好",
          "来NN，游戏开黑，就差你了！",
          "http://test-svr.nn.com:9002?${roomNo}",
          null,
          null,
          null,
          null,
          "",
          "https://static.nn.com/image/app/100.png",
          'https://static.nn.com/image/app/100.png',
          null,
          "http://test-svr.nn.com:9002?${roomNo}",
          null,
          null,
          SSDKContentTypes.webpage,
          ShareSDKPlatforms.qq);
    SharesdkPlugin.share(
        ShareSDKPlatforms.qq, params, (SSDKResponseState state, Map userdata,
        Map contentEntity, SSDKError error) {
      // toast(error.rawData);
    });
}

shareWechat(i, roomNo) {
  ShareSDKRegister register = ShareSDKRegister();
  register.setupWechat("wx9e2b4c96801cc1be", "fe4694fc557d2bc3c3353861cc29225c", "https://ax6f.t4m.cn/");
  SharesdkPlugin.regist(register);
  var a = null;
  if(i == 0) {
    a = ShareSDKPlatforms.wechatSession;
  } else {
    a = ShareSDKPlatforms.wechatTimeline;
  }
  SSDKMap params = SSDKMap()
      ..setWechat(
          "来NN，游戏开黑，就差你了！",
          "天涯何处无芳草，组队开黑好不好",
          'https://www.baidu.com',
          "https://static.nn.com/image/app/100.png",
          [
            "https://static.nn.com/image/app/100.png",
          ],
          null,
          null,
          "https://static.nn.com/image/app/100.png",
          null,
          null,
          null,
          null,
          SSDKContentTypes.webpage,
          a);

    SharesdkPlugin.share(
        a, params, (SSDKResponseState state,
        Map userdata, Map contentEntity, SSDKError error) {
      // showAlert(state, error.rawData, context);
      print('kkkkkkkkkkkkkkkkkkkkkk${error.rawData}');
    });
}

shareQzone(roomNo){
  ShareSDKRegister register = ShareSDKRegister();
  register.setupQQ("101839286", "532f43f9d525bcbaeb9f862d06a9404c");
  SharesdkPlugin.regist(register);

   SSDKMap params = SSDKMap()
      ..setQQ(
          "来NN，游戏开黑，就差你了！",
          "天涯何处无芳草，组队开黑好不好",
          "http://test-svr.nn.com:9002?${roomNo}",
          null,
          "https://static.nn.com/image/app/100.png",
          null,
          null,
          null,
          "https://static.nn.com/image/app/100.png",
          "https://static.nn.com/image/app/100.png",
          null,
          "http://test-svr.nn.com:9002?${roomNo}",
          null,
          null,
          SSDKContentTypes.webpage,
          ShareSDKPlatforms.qZone);
    SharesdkPlugin.share(
        ShareSDKPlatforms.qZone, params, (SSDKResponseState state, Map userdata,
        Map contentEntity, SSDKError error) {
      // toast('${error.rawData}');
      print('uuuuuuuuuuuuuuuuuuu${error.rawData}');
    });
}

Widget shareSheet(context, {int roomNo}) {

  double height;
  if (roomNo == null){
    height = 180;
  } else {
    height = 260;
  }

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: height,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: 50.0,
              child: Text('邀请好友', style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(30.0),
                  right: ScreenUtil().setWidth(30.0)
                ),
                child: Wrap(
                  //水平间距
                  spacing: ScreenUtil().setWidth(10.0),
                  //垂直间距
                  runSpacing: ScreenUtil().setHeight(15.0),
                  //对齐方式
                  alignment: WrapAlignment.start,
                  children: onItem(context, roomNo),
                ),
              )
            ),
            Container(
              color: Color.fromRGBO(233, 233, 233, 1.0),
              height: 6,
            ),
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: Text('取消'),
              )
            )
          ],
        ),
      );
    }
  );
}

List<Widget> onItem(context, int roomNo) {
  List<Widget> data = [];
  shareList.forEach((res){
    if (res['title'] != "NN好友" || res['title'] == "NN好友" && roomNo != null){
      data.add(
          InkWell(
              onTap: () {
                switch(res['title']) {
                  case 'NN好友':
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ShareRoomScreen(roomNo: roomNo);
                    }));
                    break;
                  case 'QQ好友':
                    shareQQ(roomNo);
                    break;
                  case '微信好友':
                    shareWechat(0, roomNo);
                    break;
                  case 'QQ空间':
                    shareQzone(roomNo);
                    break;
                  case '朋友圈':
                    shareWechat(1, roomNo);
                    break;
                  default:
                }
              },
              child: Container(
                width: ScreenUtil().setWidth(71.0),
                margin: EdgeInsets.only(
                  bottom: 8.0,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Image.asset(res['img'],
                          height: 35.0,
                          width: 35.0,
                        ),
                        SizedBox(height: 6,),
                        Text(res['title'], style: TextStyle(fontSize: 12.0, color: Colors.black),)
                      ],
                    )
                  ],
                ),
              )
          )
      );
    } else {

    }
  });
  return data;
}