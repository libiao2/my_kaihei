import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:provide/provide.dart';
import './messageItem.dart';

class RoomChat extends StatelessWidget{
  final room_no;
  ScrollController _scrollController;

  RoomChat({ this.room_no });

  void _jumpBottom(){//滚动到底部
    _scrollController.animateTo(99999,curve: Curves.easeOut, duration: Duration(milliseconds: 200));
  }

  @override
  void initState() {
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Provide<StoreData>(
      builder: (context, child, data){
        if(data.chatList.length == 0) {
          return Container();
        }
        return Container(
          alignment: Alignment.topLeft,
          width: ScreenUtil().setWidth(375.0),
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(10.0),
            bottom: ScreenUtil().setHeight(20.0),
          ),
          margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(25.0), right: ScreenUtil().setWidth(25.0)
          ),
          child: ListView.builder(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return messageItem(data.chatList[index], this.room_no, context, _jumpBottom);
            },
            itemCount: data.chatList.length,
          )
        );
      }
    );
  }
}