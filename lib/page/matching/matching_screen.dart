import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provide/provide.dart';
import '../../service/service.dart';
import '../../service/service_url.dart';
import '../room/room_screen.dart';
import '../../components/toast.dart';
import '../../provide/roomData.dart';

class MatchingScreen extends StatefulWidget{
  final data;
  MatchingScreen({ this.data });
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>{
  static Timer _timer;
  final timeout = const Duration(seconds: 1);
  double opacityLevel = 0.0;

  List imgList = [];
  var otherImg = null;
  int len = 0;

  void _changeImg() {
    _timer = Timer.periodic(timeout, (timer) {
      setState(() {
        otherImg = imgList[len]['avatar'];
        opacityLevel = opacityLevel == 0.0 ? 1.0 : 0.0;
        len = len + 1;
        if(len == imgList.length) {
          len = 0;
        }
      });
    });
  }

  void _getUserList() {
    request('post', allUrl['lookUser'], null).then((val) {
      if (val['code'] == 0) {
        setState(() {
          imgList = val['data']['list'];
        });
        _changeImg();
      }
    });
  }

  void _goMatch() {
    SocketHelper.matchStart(
      widget.data['game_id'],
      widget.data['area_id'],
      widget.data['level_id'],
      widget.data['mode_id'],
      context,
      _successCallback);
  }

  void _successCallback(isOk, content){
    if(isOk) {
      SocketHelper.joinRoom(content, 1, context, (joinOk, res){
        if(joinOk) {
          // 删除聊天内容
          Provide.value<StoreData>(context).deleteRoomchat();
          Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
          Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
          Provide.value<StoreData>(context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
      Provide.value<StoreData>(context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
          Provide.value<StoreData>(context).saveHomeRoomImg(null);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => RoomScreen(
              room_no: content,
              isOnLine: Provide.value<RoomData>(context).isOnLine,
            ))
          );
        } else {
          toast(res);
          Navigator.pop(context);
          Provide.value<StoreData>(context).matchingErrBack(true); //匹配失败退回首页
        }
      });
      
    } else {
      toast(content);
      Navigator.pop(context);
      Provide.value<StoreData>(context).matchingErrBack(true); //匹配失败退回首页
    }
  }

  void _cancelCallBack(isOk, msg) {
    if(isOk) {
      Navigator.pop(context);
    } else {
      toast(msg);
    }
  }

  @override
  void initState() {
    _goMatch();
    _getUserList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null){
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top); //计算状态栏的高度
    return Provide<StoreData>(
      builder: (context, child, data){
        return Scaffold(
          body: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/room_bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: top,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            _header(),
                            Expanded(
                              child: _body(data.userInfo['avatar'])
                            ),
                            _footer(),
                          ],
                        ),
                      )
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
    
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: (){
              SocketHelper.matchCancel(context,widget.data, _cancelCallBack);
            },
            child: Container(
              width: 26.0,
              height: 26.0,
              alignment: Alignment.center,
              child: Icon(Icons.arrow_back_ios, size: 17.0, color: Color.fromRGBO(255, 255, 255, 0.7),),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.1),
                borderRadius: BorderRadius.circular(13)
              ),
            ),
          ),
          
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text('速配队友', style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 15.0,
                color: Colors.white
              ),),
            )
          ),
          SizedBox(width: 26.0,)
        ],
      ),
    );
  }

  Widget _body(img) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 30.0,
              right: 30.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  children: <Widget>[
                    SpinKitDualRing(
                      color: Color.fromRGBO(35,243,173,0.6),
                      size: 90.0,),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0, color: Color.fromRGBO(35,243,173,1)),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(img),
                          fit: BoxFit.cover
                        )
                      )
                    ),
                  ],
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          borderRadius: BorderRadius.circular(6)
                        ),
                      ),
                      SizedBox(width: 7.0,),
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.5),
                          borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                      SizedBox(width: 7.0,),
                      Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.3),
                          borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.3),
                    border: Border.all(width: 2.0, color: Color.fromRGBO(35,243,173,1)),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedOpacity(// 使用一个AnimatedOpacity Widget
                    opacity: opacityLevel,
                    duration: Duration(seconds: 1),//过渡时间：1
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        
                        // border: Border.all(width: 2.0, color: Color.fromRGBO(35,243,173,1)),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(otherImg == null ? '' : otherImg),
                          fit: BoxFit.cover
                        )
                      )
                    ),
                  ),
                ),
                
                
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
                  margin: EdgeInsets.only(
                    top: 30.0
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 6.0,
                        height: 6.0,
                        margin: EdgeInsets.only(right: 2.0),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(35,243,173,1),
                            borderRadius: BorderRadius.all(Radius.circular(3.0))
                        ),
                      ),
                      Text('99+人在线',
                        style: TextStyle(
                          decoration:TextDecoration.none,
                          fontSize: 14.0,
                          color: Colors.white,
                        )
                      ),
                    ],
                  ),
                )
              ],
            )
          )
        ],
      ),
    );
  }

  Widget _footer() {
    return InkWell(
      onTap: (){
        SocketHelper.matchCancel(context, widget.data, _cancelCallBack);
      },
      child: Container(
        alignment: Alignment.center,
        width: ScreenUtil().setWidth(156.0),
        height: ScreenUtil().setHeight(44.0),
        margin: EdgeInsets.only(
          bottom: 20.0
        ),
        child: Text('取消速配', style: TextStyle(
          decoration: TextDecoration.none,
          color: Color.fromRGBO(255, 255, 255, 0.8),
          fontSize: 20.0
        ),),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.all(Radius.circular(30.0))
        ),
      )
    );
  }
}