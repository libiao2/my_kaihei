import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import '../../../provide/storeData.dart';
import './power_sheet.dart';

class RoomOwner extends StatefulWidget{
  final room_no;
  RoomOwner({ this.room_no });
  @override
  _RoomOwnerState createState() => _RoomOwnerState();
}

class _RoomOwnerState extends State<RoomOwner>{
  @override
  Widget build(BuildContext context) {
    return Provide<StoreData>(
      builder: (context, child, data){
        bool isOwner = false; // 判断自己是不是房主
        Map owner = null;
        for(int i = 0; i < data.room_user_list.length; i += 1){
          if(data.room_user_list[i]['is_admin']) {
            owner = data.room_user_list[i];
          }
        }
        if(owner == null) {
          return Container();
        }
        if(data.userInfo['nn_id'] == owner['nn_id']) {
          isOwner = true;
        }
        return Container(
          margin: EdgeInsets.only(
            top: ScreenUtil().setHeight(15.0),
            bottom: ScreenUtil().setHeight(24.0),
          ),
          child: Stack(
            alignment: FractionalOffset(0, 0.8),
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(375.0),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        powerSheet(context, owner['nn_id'], widget.room_no);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2.0, color: Color.fromRGBO(35,243,173,1)),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(owner['avatar'] == null ? '' : owner['avatar']),
                            fit: BoxFit.cover
                          )
                        )
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10.0),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: ScreenUtil().setWidth(30.0),
                          height: ScreenUtil().setHeight(16.0),
                          alignment: Alignment.center,
                          child: Text('房主', style: TextStyle(
                            color: Colors.black,
                            fontSize: 8.0,
                          )),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(35,243,173,1),
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(4.0),),
                        Text(owner['nickname'], style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0
                        ))
                      ],
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    SocketHelper.matchOnOff(widget.room_no, !data.roomIsOpen, context);
                  });
                },
                child: Offstage(
                  offstage: !isOwner,
                  child: Container(
                    width: ScreenUtil().setWidth(88.0),
                    height: ScreenUtil().setHeight(30.0),
                    alignment: Alignment.center,
                    child: Text(data.roomIsOpen ? '取消匹配' : '开始匹配', style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    )),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(68,68,252,1),
                          Color.fromRGBO(142,121,254,1),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(20.0)
                      ),
                    ),
                  )
                )
              )
            ],
          ),
        );
      }
    );
  }
}