import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/event/add_room.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:provide/provide.dart';
import '../../room/room_screen.dart';
import '../../../components/toast.dart';
import '../../../utils/SocketHelper.dart';
import '../../../provide/roomData.dart';

class CardList extends StatefulWidget{
  final gameList;
  CardList({this.gameList});
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList>{
  ScrollController _scrollController = ScrollController();
  final _listKey = GlobalKey<AnimatedListState>();
  Tween<Offset> myTween = Tween<Offset>(
    begin: Offset(1, 0),
    end: Offset(0, 0),
  );
  var joinRoom;
  List cardList = null;

  Map newRoom = null;

  _isJoinOk(isOk, msg) {
    if(isOk) {
      // 删除聊天内容
      Provide.value<StoreData>(context).deleteRoomchat();
      Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
      Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
      Provide.value<StoreData>(context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
      Provide.value<StoreData>(context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
      Provide.value<StoreData>(context).saveHomeRoomImg(null);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            room_no: joinRoom,
            isOnLine: Provide.value<RoomData>(context).isOnLine,
          ),
        ),
      );
    } else {
      toast(msg);
    }
  }


  @override
  void initState() {
    super.initState();

    Constants.eventBus.on<AddNewRoom>().listen((event) {
      print('wwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
      var data = {};
      data['room_no'] = event.room_no;
      data['name'] = event.name;
      data['game_name'] = event.game_name;
      data['game_id'] = event.game_id;
      data['area_name'] = event.area_name;
      data['online_number'] = event.online_number;
      data['avatar'] = event.avatar;
      data['is_match'] = event.is_match;
      data['is_full'] = event.is_full;
      data['level_name'] = event.level_name;
      setState(() {
        newRoom = data;
      });
      
    });


  }


  @override
  void dispose() {
    setState(() {
      joinRoom = null;
    });
    _scrollController.dispose();//监听器不用了要横着放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    Constants.cardListContext = context;
    setState(() {
      cardList = widget.gameList;
    });
    if(Provide.value<StoreData>(context).isRefresh) {
        setState(() {
          newRoom = null;
        });
    }
    if(newRoom != null) { /// 有新房间创建
      print("??????????????????????????????");
      // 添加新房间之前要先比对当前新加的房间游戏类型，和当前点击的游戏类型是否一致
      if(Provide.value<StoreData>(context).homeGameId == newRoom['game_id']) {
        var isHaveNewRoom = false;
        cardList.forEach((res){
          if(res['room_no'] == newRoom['room_no']) {
            isHaveNewRoom = true;
          }
        });
        if(!isHaveNewRoom) {  /// 要判断当前房间列表是否包含这个新增的房间
          if(cardList == null || cardList.length == 0) {
            cardList.add(newRoom);
          } else {
            cardList.insert(0, newRoom);
          }
          _listKey.currentState.insertItem(0);
        }
        setState(() {
          newRoom = null;
        });
        
      }
    }

    if(cardList == null) {
      return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: 80.0),
            alignment: Alignment.center,
            width: ScreenUtil().setWidth(100.0),
            height: ScreenUtil().setHeight(100.0),
            child: Image.asset('images/no_list.png'),
          ),
        );
    }
    return SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            Offstage(
              offstage: cardList.length == 0,
              child: Container(
                width: ScreenUtil().setWidth(375.0),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0),
                child: AnimatedList(
                  physics: NeverScrollableScrollPhysics(),
                  key: _listKey,
                  itemBuilder: (context, index, animation) => _item(cardList[index], animation),
                  initialItemCount: cardList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0)
                )
              ),
            ),
            Offstage(
              offstage: cardList.length != 0 && newRoom == null,
              child: Container(
                margin: EdgeInsets.only(top: 80.0),
                alignment: Alignment.center,
                width: ScreenUtil().setWidth(100.0),
                height: ScreenUtil().setHeight(100.0),
                child: Image.asset('images/no_list.png'),
              ),
            ),
          ],
        )
      );
    
  }

  Widget _item(item, Animation animation) {
    return SlideTransition(
      position: animation.drive(myTween),
      child: Provide<StoreData>(
        builder: (context, child, data){
          
          return _card(item);
        }
      )
    );
  }

  Widget _card(item) {
    print('555555555555555555555$item');
    return InkWell(
      onTap: () {
        setState(() {
          joinRoom = item['room_no'];
        });
        print('11111111111111');
        if(Provide.value<StoreData>(context).homeRoomNo != null) { /// 假如从首页进去的房间是自己没有退出的房间（浮窗），就直接进房间
          if(Provide.value<StoreData>(context).homeRoomNo == item['room_no']) {
            Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
            var a = item['room_no'];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RoomScreen(
                  room_no: a,
                  isOnLine: Provide.value<RoomData>(context).isOnLine,
                ),
              ),
            );
            Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
            Provide.value<StoreData>(context).saveHomeRoomImg(null);
          } else {
            SocketHelper.joinRoom(item['room_no'], 0, context, _isJoinOk);
          }
        } else {
          SocketHelper.joinRoom(item['room_no'], 0, context, _isJoinOk);
        }
        
      },
      child: Container(
        height: ScreenUtil().setHeight(80.0),
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),//阴影颜色
              blurRadius: 3.0,//阴影大小
            ),
          ]
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(item['avatar'])
                      )
                    )
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10.0)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(item['name'], style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600
                      )),
                      SizedBox(height: 5.0,),
                      Text('${item['game_name']}-${item['level_name'] == null ? '不限' : item['level_name']}-${item['area_name']}', style: TextStyle(
                        color: Color.fromRGBO(153, 153, 153, 1.0),
                        fontSize: 12.0,
                      ))
                    ],
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  // Icon(Icons.account_circle, size: 26.0, color: Color.fromRGBO(200, 200, 200, 1.0)),
                  Container(
                    width: 25.0,
                    height: 25.0,
                    child: Image.asset('images/people_icon.png'),
                  ),
                  SizedBox(width: 8.0,),
                  Text('${item['online_number']}人', style: TextStyle(fontSize: 14, color: Colors.black))
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}