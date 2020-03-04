import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/model/user_info_entity.dart';
import 'package:premades_nn/page/room/components/share_sheet.dart';
import 'package:premades_nn/page/self_center/security_screen.dart';
import 'package:premades_nn/page/self_center/setting_screen.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';
import '../../components/topAreaWidget.dart';
import '../../service/service.dart';
import '../../service/service_url.dart';
import './components/my_bottom_sheet.dart';
import './components/header.dart';
import '../../components/CustomDialog.dart';
import '../../components/toast.dart';
import 'online_service_screen.dart';

class SelfCenterScreen extends StatefulWidget {
  _SelfCenterScreenState createState() => _SelfCenterScreenState();
}

class _SelfCenterScreenState extends State<SelfCenterScreen> {
  List _cards = ['1', '2'];
  List setList = [
    {'title': '设置中心', 'img': 'images/icon_set.png', 'noBorder': false},
    {'title': '安全中心', 'img': 'images/icon_safe.png', 'noBorder': false},
    {'title': '分享APP', 'img': 'images/icon_share.png', 'noBorder': false},
    {'title': 'NN客服', 'img': 'images/icon_service.png', 'noBorder': true},
  ];
  List gameCardData = [];
  List myCardList;
  List<GameCard> cardList = List();

  bool isEmpty = false;

  void _getGameCardList() {
    var data = {'card': 0};
    request('post', allUrl['gameCardList'], data).then((val) {
      if (val['code'] == 0) {
        setState(() {
          gameCardData = val['data']['list'];
        });
      }
    });
  }

  void _getUserCard() {
    isEmpty = false;

    if (cardList.length > 0) {
      cardList.clear();
    }

    var data = {"page": 1, "limit": 100};
    request('post', allUrl['userCard'], data).then((val) {
      if (val['code'] == 0 &&
          val['data'] != null &&
          val['data']['list'] != null) {
        myCardList = val['data']['list'];

        (val['data']['list'] as List).forEach((item) {
          cardList.add(GameCard.fromJson(item));
        });
        if (cardList.length == 0) {
          isEmpty = true;
        }
        setState(() {});
      }
    });
  }

  void myCallback() {
    _getUserCard();
  }

  @override
  void initState() {
    super.initState();
    _getGameCardList();
    _getUserCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TopAreaWidget(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Header(),
            _gameCard(),

            Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return SettingScreen();
                    }));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.transparent,
                    height: ScreenUtil().setHeight(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "images/icon_set.png",
                              width: ScreenUtil().setWidth(28),
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10)),
                              child: Text("设置中心",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black)),
                            ),
                          ],
                        ),
                        Image.asset(
                          "images/icon_arrow.png",
                          width: ScreenUtil().setWidth(8),
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Color.fromRGBO(242, 242, 242, 1),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        settings: RouteSettings(name: "securityCenter"),
                        builder: (context) {
                          return SecurityScreen();
                        }));
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.transparent,
                    height: ScreenUtil().setHeight(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "images/icon_safe.png",
                              width: ScreenUtil().setWidth(28),
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10)),
                              child: Text("安全中心",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black)),
                            ),
                          ],
                        ),
                        Image.asset(
                          "images/icon_arrow.png",
                          width: ScreenUtil().setWidth(8),
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Color.fromRGBO(242, 242, 242, 1),
                ),
                InkWell(
                  onTap: () {
//                  userWeChatShare(context);
                    shareSheet(context);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.transparent,
                    height: ScreenUtil().setHeight(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "images/icon_share.png",
                              width: ScreenUtil().setWidth(28),
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10)),
                              child: Text("分享APP",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black)),
                            ),
                          ],
                        ),
                        Image.asset(
                          "images/icon_arrow.png",
                          width: ScreenUtil().setWidth(8),
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Color.fromRGBO(242, 242, 242, 1),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return OnlineServerScreen();
                    }));
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.transparent,
                    height: ScreenUtil().setHeight(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "images/icon_service.png",
                              width: ScreenUtil().setWidth(28),
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10)),
                              child: Text("在线客服",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black)),
                            ),
                          ],
                        ),
                        Image.asset(
                          "images/icon_arrow.png",
                          width: ScreenUtil().setWidth(8),
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Color.fromRGBO(242, 242, 242, 1),
                ),
              ],
            ),
//              _setList()
          ],
        ),
      ),
    ));
  }

  Widget _gameCard() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setHeight(20.0),
      ),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(15.0),
                right: ScreenUtil().setWidth(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('游戏卡片',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      )),
                  InkWell(
                      onTap: () {
                        myBottomSheet(
                            context, '游戏卡片', gameCardData, null, myCallback);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 6, bottom: 6, left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                ColorUtil.btnStartColor,
                                ColorUtil.btnEndColor,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text('+',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0)),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text('添加卡片',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0)),
                          ],
                        ),
                      ))
                ],
              )),
          isEmpty
              ? Container(
                  margin: EdgeInsets.all(ScreenUtil().setWidth(15)),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Strings.myNoGameCard,
                    style: TextStyle(
                        color: ColorUtil.grey,
                        fontSize: ScreenUtil().setSp(12)),
                  ),
                )
              : Container(
                  height: ScreenUtil().setHeight(110.0),
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(15.0)),
                  margin: EdgeInsets.only(
                    top: ScreenUtil().setHeight(20.0),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cardList.length,
                    itemBuilder: (context, index) {
                      return _cardItem(index);
                    },
                  )),
        ],
      ),
    );
  }

  Widget _cardItem(index) {
    return InkWell(
        onTap: () {
          myBottomSheet(
              context, '游戏卡片', gameCardData, myCardList[index], myCallback);
        },
        onLongPress: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return MyDialog(
                    title: '提示',
                    content: '是否要删除该卡片？',
                    confirmCallback: () {
                      print('点击了确定$gameCardData');
                      var data = {'card_id': cardList[index].cardId};
                      request('post', allUrl['deleteCard'], data).then((val) {
                        if (val['code'] == 0) {
                          toast('卡片删除成功！');
                          cardList.removeWhere((item) {
                            return item.cardId == cardList[index].cardId;
                          });
                          setState(() {
                            if (cardList.length == 0) {
                              isEmpty = true;
                            }
                          });
                        }
                      });
                    });
              });
        },
        child: Container(
          width: ScreenUtil().setWidth(270),
          height: ScreenUtil().setHeight(110),
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(15.0)),
          child: Stack(
            children: <Widget>[
              Container(
                child: FadeInImage.assetNetwork(
                  placeholder: "images/image_default.png",
                  fadeOutDuration: Duration(milliseconds: 1),
                  alignment: Alignment.center,
                  image: cardList[index].logo,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5)
                ),
              ),

              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(5.0),
                  right: ScreenUtil().setWidth(15.0),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(67.0),
                      height: ScreenUtil().setHeight(80.0),
                      child: Image.network(cardList[index].cover),
                    ),

                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(10),
                            bottom: ScreenUtil().setHeight(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(cardList[index].gameName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                )),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: ScreenUtil().setWidth(18),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.asset("images/icon_game_item_start.png"),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(10),right: ScreenUtil().setWidth(10)),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: AssetImage("images/icon_game_item_end.png"),
                                        fit: BoxFit.fill),
                                  ),
                                  child: Text(cardList[index].levelName,
                                      style: TextStyle(
                                          fontSize: 12.0, color: ColorUtil.black)),
                                ),
                              ],
                            ),

                            Text(cardList[index].areaName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                )),
                            Container(
                                height: ScreenUtil().setHeight(20.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: cardList[index].adept.length,
                                  itemBuilder: (context, i) {
                                    return _adeptItem(
                                        cardList[index].adept[i].adeptName);
                                  },
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _adeptItem(name) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(4, 1, 4, 1),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
      decoration: BoxDecoration(
        color: ColorUtil.nnBlueTran,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        name,
        style: TextStyle(
            color: ColorUtil.white, fontSize: ScreenUtil().setSp(12)),
      ),
    );
  }
}
