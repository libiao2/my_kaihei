import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../../../provide/storeData.dart';

class RoomHeader extends StatelessWidget{
  final roomContext;
  final headerCallBack;
  final changeNameBack;
  RoomHeader({ this.roomContext, this.headerCallBack, this.changeNameBack });

  @override
  Widget build(BuildContext context) {
    return Provide<StoreData>(
      builder: (context, child, data){
        bool isAdmin = false;
        for(int i = 0; i < data.room_user_list.length; i += 1) {
          if(data.userInfo['nn_id'] == data.room_user_list[i]['nn_id']) {
            if(data.room_user_list[i]['is_admin']) {
              isAdmin = true;
            }
            
          }
        }
        return Container(
          width: ScreenUtil().setWidth(375.0),
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(10.0),
            bottom: ScreenUtil().setHeight(10.0),
            left: ScreenUtil().setWidth(15.0),
            right: ScreenUtil().setWidth(15.0)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Provide.value<StoreData>(context).changeRefresh(true);
                    print('AAAAAAAAAAAAAAAAAAAAAAAAAAAA');
                  this.headerCallBack();
                },
                child: Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 18.0,
                        height: 18.0,
                        child: Image.asset('images/room_left.png', fit: BoxFit.cover,)
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){
                    if(isAdmin) {
                      this.changeNameBack();
                    }
                    
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(data.room_info['room_name'], style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          )),
                          SizedBox(
                            width: 4.0,
                          ),
                          Offstage(
                            offstage: !isAdmin,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 18.0,
                                    height: 18.0,
                                    child: Image.asset('images/chang_room_name.png', fit: BoxFit.cover,)
                                  )
                                ],
                              )
                          )
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(4.0),),
                      Text('「${data.room_info['game_name']}」', style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.5),
                          fontSize: 12.0
                        )
                      )
                    ],
                  )
                )
              ),
              InkWell(
                onTap: (){
                  Provide.value<StoreData>(context).changeRefresh(true);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 18.0,
                        height: 18.0,
                        child: Image.asset('images/room_right.png', fit: BoxFit.cover,)
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}