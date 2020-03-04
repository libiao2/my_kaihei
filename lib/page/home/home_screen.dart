import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_wechat/flutter_wechat.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:provide/provide.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../components/topAreaWidget.dart';
import './components/type_list.dart';
import './components/card_list.dart';
import '../../service/service.dart';
import '../../service/service_url.dart';
import '../../components/float_action_button.dart';
import './components/home_quick.dart';
import '../room/room_screen.dart';
import '../../provide/roomData.dart';
import '../../event/last_one_leav_room.dart';
import '../../event/room_has_phone.dart';
import '../../event/room_no_phone.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EasyRefreshController _controller = EasyRefreshController();
  int _clickIndex = null;
  List gameList = null;
  List typeChoose = null;  // 游戏种类
  List typeList = [];
  List _bannerList = [
    {
      'icon': 'https://static.nn.com/image/2019/12/26/11/50/28/3341232d3247ffe878f9f1d6153288e6.png',
      'url': 'www.baidu.com'
    },
    {
      'icon': 'https://static.nn.com/image/2019/12/26/11/50/45/bf77ed918506ed41947559af7b728088.png',
      'url': 'www.baidu.com'
    }
  ];
  var threePeople;
  Map parmars = {
    "game_id": null,
    "area_id": null,
    "level_id": null,
    "mode_id": null,
    "page": 1,
    "limit": 15
  };
  ScrollController _scrollController = ScrollController();

  Map lastOne = null; /// 如果用户在某一房间内是最后一个人然后退出房间回到首页，这个时候首页不能出现该本应该消失的房间

  void _getBanner() {
    var data = {
      'page': 1,
      'limit': 3,
      'system': 1
    };
    request('post', allUrl['bannerList'], data).then((val) {
      if (val['code'] == 0) {
        setState(() {
          _bannerList = val['data']['list'];
        });
      }
    });
  }

  void _getData() {
    request('post', allUrl['gameList'], parmars).then((val) {
      Provide.value<StoreData>(context).saveHomeGameId(parmars['game_id']);
      if (val['code'] == 0) {
        var newList = [];
        newList.addAll(val['data']['list']);
        if(gameList == null) {
          print('77777777777777777777777777777777$lastOne');
          if(lastOne != null) {  /// 此处要过滤从房间退回首页，本应该被系统收回的房间依然被获取到了，这个要过滤
            if(lastOne['isLast']) {
              for(int i = 0; i < newList.length; i += 1) {
                if(newList[i]['room_no'] == lastOne['room_no']) {
                  newList.removeAt(i);
                }
              }
              print('88888888888888888888888888888888$newList');
            }
          }
          setState(() {
            gameList = newList;
            threePeople = newList;
            Provide.value<StoreData>(context).saveHomeCardList(gameList);
          });
          Provide.value<RoomData>(context).changeIsLastOne(null);
        } else {
          setState(() {
            for(int i = 0; i < val['data']['list'].length; i +=1) {
              gameList.add(val['data']['list'][i]);
            }
            Provide.value<StoreData>(context).saveHomeCardList(gameList);
          });
        }
        
      }
    });
  }

  void _changeSearch(data) {
    
    setState(() {
      gameList = null;
      parmars = data;
    });
    _getData();
  }

  void refreshChange() {   //// 刷新页面
    setState(() {
      gameList = null;
      parmars = {
        "game_id": typeList[0]['game_id'],
        "area_id": null,
        "level_id": null,
        "mode_id": null,
        "page": 1,
        "limit": 15
      };
    });
    _getTypeList(null);
    _getUserInfo();
    _getBanner();
    
  }
  void changeClick(data) {  // 每次點擊遊戲類型的時候的回調
    setState(() {
      parmars = {
        "game_id": data,
        "area_id": null,
        "level_id": null,
        "mode_id": null,
        "page": 1,
        "limit": 15
      };
    });
  }

  void _getTypeList(id) {
    request('post', allUrl['getGameInfo'], null).then((val) {
      if (val['code'] == 0) {
        typeChoose = val['data'];
        typeList = [];
        var chooseId;
        if(id == null) {
          chooseId = typeChoose[0]['game_id'];
        } else {
          chooseId = id;
        }
        setState(() {
          _clickIndex = null;
          for(int i = 0; i < typeChoose.length; i += 1) {
            typeList.add({
              'game_name': typeChoose[i]['game_name'],
              'game_id': typeChoose[i]['game_id'],
            });
          }
          parmars['game_id'] = chooseId;
          
        });
        Provide.value<StoreData>(context).saveHomeGameId(chooseId);
        Provide.value<StoreData>(context).changeTypeIndex(chooseId);
        _getData();
      }
    });
  }

  void _getUserInfo() {
    request('post', allUrl['userInfo'], null).then((val) {
      if (val['code'] == 0) {
        Provide.value<StoreData>(context).setUserInfo(val['data']);
      }
    });
  }

  void _goOther(url) async {
    print('gfgfgfgfgfgfgfg');
    if(url is int) {
      /// 进入房间，后面添加！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
    } else {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }


  @override
  void initState() {
    super.initState();

    // 最后一个人离开房间回到首页这个时候首页要把本应该消失的房间屏蔽
    Constants.eventBus.on<LastOneLeavRoom>().listen((event) {
      var data = {};
      data['room_no'] = event.roomNo;
      data['isLast'] = event.isLast;
      setState(() {
        lastOne = data;
        if(gameList != null) {
          for(int i = 0; i < gameList.length; i += 1) {
            if(gameList[i]['room_no'] == data['room_no']) {
              gameList.removeAt(i);
            }
          }
        }
      });
    });

    Constants.eventBus.on<RoomHasPhone>().listen((event) {
      if(event.isHave) {
        print('556666667777778888889999999');
        if(Provide.value<StoreData>(context).homeRoomNo != null) {
          AgoraRtcEngine.leaveChannel();
          AgoraRtcEngine.create(Constants.APP_ID);
          AgoraRtcEngine.enableAudio(); /// 启用音频模块

          /// 加入房间
          AgoraRtcEngine.joinChannel(null, '10000', null, Constants.userInfo.nnId);
        }
      }
    });
    // 房间内挂断电话
    Constants.eventBus.on<RoomNoPhone>().listen((event) {
      if(event.isClose) {
        if(Provide.value<StoreData>(context).homeRoomNo != null) {
          AgoraRtcEngine.leaveChannel();
          AgoraRtcEngine.create(Constants.APP_ID);
          AgoraRtcEngine.enableAudio(); /// 启用音频模块
          /// 加入房间
          AgoraRtcEngine.joinChannel(null, Provide.value<StoreData>(context).homeRoomNo.toString(), null, Constants.userInfo.nnId);
        }
        
      }
    });
    _getTypeList(null);
    _getUserInfo();
    _getBanner();
    
    
    
  }

  

  @override
  Widget build(BuildContext context) {
    Constants.roomContext = context;

    Future.delayed(Duration(milliseconds: 200)).then((e) {
      if(Provide.value<StoreData>(context).isRefresh) {
        refreshChange();
        Provide.value<StoreData>(context).changeRefresh(false);
      }
    });
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Material(
        child:Scaffold(
          floatingActionButtonLocation: GuideUserActionLocation.getInstance(),
          floatingActionButton: _rightFloatBtn(),
          backgroundColor: Color.fromRGBO(245, 245, 245, 1),
          body: TopAreaWidget(
            color: Colors.red,
            child: EasyRefresh.custom(
              // header: MaterialHeader(),
              // footer: MaterialFooter(),
              controller: _controller,
              slivers: <Widget>[
                // 轮播
                _swiperWidget(_bannerList),
                // // 快速匹配
                HomeQuick(
                  typeChoose: typeChoose,
                  gameList: threePeople
                ),
                // 类型选择
                TypeList(
                  typeChoose: typeChoose,
                  typeList: typeList,
                  firstClick: _clickIndex,
                  typeChangeCallBack: changeClick,
                  callBack: _changeSearch),
                // card
                CardList(gameList: gameList)
              ],
              onRefresh: (){
                setState(() {
                  // _clickIndex = 0;
                  gameList = null;
                  parmars = {
                    "game_id": Provide.value<StoreData>(context).homeGameId,
                    "area_id": null,
                    "level_id": null,
                    "mode_id": null,
                    "page": 1,
                    "limit": 15
                  };
                  _getTypeList(Provide.value<StoreData>(context).homeGameId);
                  _getUserInfo();
                  _getBanner();
                });
                
              },
              onLoad: () async {
                setState(() {
                  parmars['page'] = parmars['page'] + 1;
                  _getData();
                });
              },
            ),
          )
        ),
      ),
    );
    
  }


  Widget _rightFloatBtn() {
    return Provide<StoreData>(
      builder: (context, child, storeData){
        return Offstage(
          offstage: storeData.homeRoomNo == null,
          child: InkWell(
            onTap: (){
              Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
              var a = storeData.homeRoomNo;
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
            },
            child: Container(
              child: Stack(
                alignment: FractionalOffset(1, 1),
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4.0, color: Colors.white),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(Provide.value<StoreData>(context).roomImg == null ? '' : Provide.value<StoreData>(context).roomImg),
                        fit: BoxFit.cover
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),//阴影颜色
                          blurRadius: 5.0,//阴影大小
                        ),
                      ]
                    )
                  ),
                ],
              )
            )
          )
        );
      }
    );
  }

  Widget _swiperWidget (List swiperList) {
    return SliverToBoxAdapter(
      child: Container(
        width: ScreenUtil().setWidth(345.0),
        height: ScreenUtil().setHeight(95.0),
        margin: EdgeInsets.only(
          top: ScreenUtil().setWidth(14.0),
          left: ScreenUtil().setWidth(15.0),
          right: ScreenUtil().setWidth(15.0)),
        child: Swiper(
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            child: Image.network(swiperList[index]['icon'], fit:BoxFit.cover),
          ),
          itemCount: swiperList.length,
          pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              color: Color.fromRGBO(220, 220, 220, 0.8),
              activeColor: Color.fromRGBO(35, 243, 173, 1.0),
              activeSize: 6.0,
              size: 6.0,
            ),
          ),
          // control:SwiperControl(), // 这个是点击的左右箭头，长得贼恶心
          scrollDirection: Axis.horizontal,
          autoplay: true,
          
          onTap: (index) => _goOther(swiperList[index]['url']),
        ))
    );
  }

}


