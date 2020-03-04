import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/page/room/room_screen.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import '../../provide/roomData.dart';

class ShareRoomMessageItem extends StatelessWidget {

  final int roomNo;

  BuildContext _context;

  ShareRoomMessageItem({this.roomNo});

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Ink(
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)), //水波纹圆角
          onTap: (){

            SocketHelper.joinRoom(roomNo, 2, context, _isJoinOk);

//            Navigator.push(context, MaterialPageRoute(builder: (context){
//              return RoomScreen(room_no: roomNo,);
//            }));

          },
          child: Container(
            width: ScreenUtil().setWidth(240),
            height: ScreenUtil().setHeight(180),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(10), right: ScreenUtil().setWidth(10),top: ScreenUtil().setWidth(10)),
                  child: Image.asset(
                    "images/image_share_room_bg.png",
                    width: ScreenUtil().setWidth(220),
                    height: ScreenUtil().setWidth(125),
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: ScreenUtil().setWidth(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(Strings.add_now, style: TextStyle(color: ColorUtil.black, fontSize: ScreenUtil().setSp(14), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _isJoinOk(isOk, msg) {
    if(isOk) {
      // 删除聊天内容
      Provide.value<StoreData>(_context).deleteRoomchat();
      Provide.value<StoreData>(_context).setIsOut(false); // 初始化房间自己没被踢
      Provide.value<StoreData>(_context).saveHomeRoomNo(null); //删除保留的房号
      Provide.value<StoreData>(_context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
      Provide.value<StoreData>(_context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
      Provide.value<StoreData>(_context).saveHomeRoomImg(null);
      Navigator.of(_context).push(
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            room_no: roomNo,
            isOnLine: Provide.value<RoomData>(context).isOnLine,
          ),
        ),
      );
    } else {
      toast(msg);
    }
  }
}
