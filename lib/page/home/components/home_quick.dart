import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:provide/provide.dart';
import 'package:flutter/services.dart';
import '../../../components/bottom_sheet.dart';
import './home_bottom_sheet.dart';
import '../../../provide/storeData.dart';
import '../../../components/CustomDialog.dart';
import '../../../utils/SocketHelper.dart';
import '../../../utils/Constants.dart';


class HomeQuick extends StatelessWidget {
  final typeChoose;
  final gameList;
  HomeQuick({
    this.typeChoose,
    this.gameList
  });

  void dd(){}

  @override
  Widget build(BuildContext context) {
    var myList = [];
  
    if(this.gameList != null) {
      this.gameList.forEach((res){
        myList.add(res);
      });
    }
    // if(Provide.value<StoreData>(context).isMatchErr) {
    //   bottomSheet(context, '速配队友', this.typeChoose, dd);
    // }
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(
            top: ScreenUtil().setHeight(10.0),
            bottom: ScreenUtil().setHeight(10.0)),
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(15.0),
            right: ScreenUtil().setWidth(15.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: (){
                  if(Provide.value<StoreData>(context).homeRoomNo != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return MyDialog(
                          title: '提示',
                          content: '您已在房间内，是否确认退出房间并进行匹配/组队?',
                          confirmCallback: (){
                            SocketHelper.goOutRoom(Provide.value<StoreData>(context).homeRoomNo, context); // 退出房间
                            Provide.value<StoreData>(context).deleteRoomchat();
                            Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
                            Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
                            Provide.value<StoreData>(context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
                            Provide.value<StoreData>(context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
                            Provide.value<StoreData>(context).saveHomeRoomImg(null);


                            AgoraRtcEngine.leaveChannel();

//                            try {
//                              Constants.agoraPlatform.invokeMethod("exitChannel"); //分析2
//                            } on PlatformException catch (e) {
//                              print(e.toString());
//                            }

                            bottomSheet(context, '速配队友', this.typeChoose, dd);
                          }
                        );
                      }
                    );
                  } else {
                    bottomSheet(context, '速配队友', this.typeChoose, dd);
                  }
                  
                },
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(75.0),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(
                                'images/pipei.png'),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(75.0),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('快速匹配',
                              style: TextStyle(
                                  color: Colors.white,
                                  decoration:
                                      TextDecoration.none,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700)),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 255, 255, 0.2),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                  ),
                                  child: Row(
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
                                            fontSize: 10.0,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Stack(
                                    alignment: FractionalOffset(1, 1),
                                    children: <Widget>[
                                      Container(
                                        width: 50.0,
                                        height: 20.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Stack(
                                              alignment: FractionalOffset(0.8, 0),
                                              children: <Widget>[
                                                Container(
                                                  width: 40.0,
                                                  height: 20.0,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Offstage(
                                                        offstage: myList.length == 0,
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(width: 1.0, color: Colors.white),
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                              image: NetworkImage(
                                                                myList.length == 0 ? '' : myList[0]['avatar'] == null ? '' : myList[0]['avatar']
                                                              ),
                                                              fit: BoxFit.cover
                                                            )
                                                          )
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Offstage(
                                                  offstage: myList.length <= 1,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(width: 1.0, color: Colors.white),
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: NetworkImage(myList.length > 1 ? myList[1]['avatar'] : ''),
                                                        fit: BoxFit.cover
                                                      )
                                                    )
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ),
                                      Offstage(
                                        offstage: myList.length <= 2,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1.0, color: Colors.white),
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(myList.length > 2 ? myList[2]['avatar'] : ''),
                                              fit: BoxFit.cover
                                            )
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              )
            ),
            SizedBox(
              width: ScreenUtil().setWidth(10.0),
            ),
            Expanded(
              child: InkWell(
                onTap: (){
                  if(Provide.value<StoreData>(context).homeRoomNo != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return MyDialog(
                          title: '提示',
                          content: '您已在房间内，是否确认退出房间并进行匹配/组队?',
                          confirmCallback: (){
                            SocketHelper.goOutRoom(Provide.value<StoreData>(context).homeRoomNo, context); // 退出房间
                            Provide.value<StoreData>(context).deleteRoomchat();
                            Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
                            Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
                            Provide.value<StoreData>(context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
                            Provide.value<StoreData>(context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
                            Provide.value<StoreData>(context).saveHomeRoomImg(null);

                            AgoraRtcEngine.leaveChannel();


                            request('post', allUrl['getRoomName'], null).then((val) {
                              if (val['code'] == 0) {
                                createRoombottomSheet(context, '开房组队', this.typeChoose, val['data']['room_name']);
                              }
                            });
                          }
                        );
                      }
                    );
                  } else {
                    request('post', allUrl['getRoomName'], null).then((val) {
                      if (val['code'] == 0) {
                        createRoombottomSheet(context, '开房组队', this.typeChoose, val['data']['room_name']);
                      }
                    });
                  }
                  
                },
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(75.0),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(
                                'images/zudui.png'),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(75.0),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('开房组队',
                              style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700)),
                          Container(
                            width: ScreenUtil().setWidth(65.0),
                            height: ScreenUtil().setHeight(22.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.2),
                                  border: Border.all(width: 1.0, color: Colors.white),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('马上加入', style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.white, fontSize: 10.0)),
                                    Container(
                                      margin: EdgeInsets.only(top: 3.0),
                                      child: Icon(Icons.chevron_right, size: 14.0, color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}