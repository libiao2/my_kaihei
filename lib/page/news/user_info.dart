import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/CustomDialog.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/add_friend_event.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/model/search_user_entity.dart';
import 'package:premades_nn/model/user_info_entity.dart';
import 'package:premades_nn/page/self_center/components/my_bottom_sheet.dart';
import 'package:premades_nn/page/self_center/my_infomation.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/type/AddFriendStatusType.dart';
import 'package:premades_nn/type/FriendFromType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import '../../service/service_url.dart';
import 'chat_screen.dart';
import 'edit_friend_remark_screen.dart';

class UserInfo extends StatefulWidget {
  ///搜索好友页面和频道用户页面查看用户详情接口不一样
  ///一个是通过nnid查询，一个是通过频道用户编号查询
  final int nnid;

  final bool isClose;

  VoidCallback sendClick;

  int friendFrom = 1;

  UserInfo({Key key, this.nnid, this.sendClick, this.isClose, this.friendFrom})
      : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  UserInfoEntity _userInfo;

  bool isMyself = false;

  bool dialogIsDismiss = false; //dialog是否已关闭

  StreamSubscription<AddFriendEvent> _subscription;

  List gameCardData = [];

  @override
  void initState() {
    super.initState();

    _getGameCardList();

    loadUserInfo();

    _subscription = Constants.eventBus.on<AddFriendEvent>().listen((event) {
      if (event.type != null &&
          event.type == FriendInfoUpdateType.updateRemark) {
        setState(() {
          if (_userInfo.friendInfo != null){
            _userInfo.friendInfo.friendRemark = event.remark;
          }
        });
      } else {
        toast("添加好友成功！");
        setState(() {
          _userInfo.isFriend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  ///获取游戏卡片
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

  ///获取用户信息
  void loadUserInfo() {
    if (widget.nnid != null) {
      var data = {"nn_id": widget.nnid};
      request('post', allUrl['userPublicInfo'], data).then((result) {
        if (result["code"] == 0) {
          _userInfo = new UserInfoEntity();
          _userInfo.avatar = result["data"]["user"]["avatar"];
          _userInfo.nnId = result["data"]["user"]["nn_id"];
          _userInfo.specialNnId = result["data"]["user"]["special_nn_id"];
          _userInfo.nickname = result["data"]["user"]["nickname"];
          _userInfo.gender = result["data"]["user"]["gender"];
          _userInfo.intro = result["data"]["user"]["intro"];
          _userInfo.birthday = result["data"]["user"]["birthday"];
          _userInfo.region1 = result["data"]["user"]["region1"];
          _userInfo.region2 = result["data"]["user"]["region2"];
          _userInfo.level = result["data"]["user"]["level"];
          if(result["data"]["user"]["friend_info"] != null){
            _userInfo.remark = result["data"]["user"]["friend_info"]["friend_remark"];
          }
          if (result["data"]["user"]["friend_info"] != null) {
            _userInfo.friendInfo =
                FriendInfo.fromJson(result["data"]["user"]["friend_info"]);
          }
          _userInfo.isFriend = _userInfo.friendInfo != null;
          _userInfo.friendVerificationType =
              result["data"]["user"]["friend_verification_type"];
          if (result["data"]["card"] != null) {
            _userInfo.card = List();
            (result["data"]["card"] as List).forEach((v) {
              _userInfo.card.add(GameCard.fromJson(v));
            });
          }

          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Constants.roomContext = context;
    if (_userInfo == null) {
      return Material(
          child: Column(
        children: <Widget>[
          AppBarWidget(
            isShowBack: true,
            centerText: Strings.userInfo,
          ),
          Expanded(
            child: Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.orange,
            )),
          )
        ],
      ));
    }

    if (_userInfo.nnId == Constants.userInfo.nnId) {
      isMyself = true;
    }

    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              //appBar
              Container(
                margin: EdgeInsets.only(
                    top: MediaQueryData.fromWindow(window).padding.top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setHeight(50),
                        width: ScreenUtil().setHeight(50),
                        child: Image.asset(
                          "images/go_back.png",
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                    //菜单
                    Offstage(
                      offstage: !_userInfo.isFriend && _userInfo.nnId != Constants.userInfo.nnId,
                      child: InkWell(
                          onTap: () {
                            if (_userInfo.nnId == Constants.userInfo.nnId){
                              Navigator.of(context).push(MaterialPageRoute(
                                  settings: RouteSettings(name: "myInformation"),
                                  builder: (context) {
                                    return MyInformationScreen();
                                  }));
                            } else {
                              onClickMenu();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: ScreenUtil().setWidth(50),
                            width: ScreenUtil().setHeight(50),
                            child: Image.asset(
                              "images/icon_more.png",
                              width: 16,
                              height: 16,
                            ),
                          )),
                    ),
                  ],
                ),
              ),

              //用户资料
              Container(
                margin: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(15), 0, ScreenUtil().setWidth(15), 0),
                child: Column(
                  children: <Widget>[
                    //头像-性别-名称-nn-地址-星座
                    Row(
                      children: <Widget>[
                        //头像
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            Container(
                                width: ScreenUtil().setWidth(75),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipOval(
                                    child: Image.network(
                                      _userInfo.avatar,
                                    ),
                                  ),
                                )),
                            Container(
                              margin: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(5)),
                              child: _userInfo.gender == 1
                                  ? Image.asset(
                                      "images/icon_boy.png",
                                      width: ScreenUtil().setWidth(15),
                                      fit: BoxFit.fitWidth,
                                    )
                                  : Image.asset(
                                      "images/icon_girl.png",
                                      width: ScreenUtil().setWidth(15),
                                      fit: BoxFit.fitWidth,
                                    ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //备注
                                Container(
                                  child: Text(
                                    _userInfo.friendInfo != null && _userInfo.friendInfo.friendRemark != null
                                        && _userInfo.friendInfo.friendRemark != ""? _userInfo.friendInfo.friendRemark
                                        : _userInfo.nickname,
                                    style: TextStyle(
                                        color: ColorUtil.black,
                                        fontSize: ScreenUtil().setSp(20),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                //昵称
                                Offstage(
                                  offstage: _userInfo.friendInfo == null || _userInfo.friendInfo.friendRemark == null
                                      || _userInfo.friendInfo.friendRemark == "",
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(4)),
                                    child: Text(
                                      "昵称:${_userInfo.nickname}",
                                      style: TextStyle(
                                          color: ColorUtil.grey,
                                          fontSize: ScreenUtil().setSp(12)),
                                    ),
                                  ),
                                ),
                                //nn
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(4)),
                                  height: ScreenUtil().setHeight(20),
                                  width: ScreenUtil().setWidth(100),
                                  padding: EdgeInsets.fromLTRB(
                                      ScreenUtil().setWidth(5),
                                      0,
                                      ScreenUtil().setWidth(5),
                                      0),
                                  child: Text(
                                    "NN:${_userInfo.nnId}",
                                    style: TextStyle(
                                        color: ColorUtil.nnBlue,
                                        fontSize: ScreenUtil().setSp(12)),
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      border: Border.all(
                                          color: ColorUtil.blue, width: 1)),
                                ),
                                //地址 星座
                                addressAndConstellation(),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),

                    //个性签名
                    Offstage(
                      offstage: _userInfo.intro == "",
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Strings.intro,
                              style: TextStyle(
                                  color: ColorUtil.black,
                                  fontSize: ScreenUtil().setSp(18),
                                  fontWeight: FontWeight.w500),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(10)),
                              child: Text(
                                _userInfo.intro,
                                style: TextStyle(
                                    color: ColorUtil.black,
                                    fontSize: ScreenUtil().setSp(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //游戏卡片标题
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Strings.gameCard,
                              style: TextStyle(
                                  color: ColorUtil.black,
                                  fontSize: ScreenUtil().setSp(18)),
                            ),
                          ),

//                          Offstage(
//                            offstage: _userInfo.nnId != Constants.userInfo.nnId,
//                            child: InkWell(
//                                onTap: () {
//                                  myBottomSheet(
//                                      context, '游戏卡片', gameCardData, null, null);
//                                },
//                                child: Container(
//                                  padding: EdgeInsets.only( top: 6, bottom: 6, left: 10.0, right: 10.0),
//                                  decoration: BoxDecoration(
//                                    gradient: LinearGradient(
//                                        colors: [
//                                          ColorUtil.btnStartColor,
//                                          ColorUtil.btnEndColor,
//                                        ],
//                                        begin: Alignment.topCenter,
//                                        end: Alignment.bottomCenter
//                                    ),
//                                    borderRadius: BorderRadius.all(Radius.circular(20)),
//                                  ),
//                                  child: Row(
//                                    children: <Widget>[
//                                      Text('+',
//                                          style: TextStyle(
//                                              color: Colors.white, fontSize: 12.0)),
//                                      SizedBox(
//                                        width: 4.0,
//                                      ),
//                                      Text('添加卡片',
//                                          style: TextStyle(
//                                              color: Colors.white, fontSize: 12.0)),
//                                    ],
//                                  ),
//                                )),
//                          ),
                        ],
                      ),
                    ),


                    gameCardList(),
                  ],
                ),
              ),
            ],
          ),
          bottomBtns()
        ],
      ),
    );
  }

  ///地址和星座
  Widget addressAndConstellation() {
    String content = "";
    if (_userInfo.region1 != null && _userInfo.region1 != "") {
      content += _userInfo.region1;
    }

    if (_userInfo.region2 != null && _userInfo.region2 != "" && content != "") {
      content += " " + _userInfo.region2;
    }

    if (_userInfo.birthday != null && _userInfo.birthday != "") {
      String constellation = Constants.getConstellation(_userInfo.birthday);
      if (content == "") {
        content = constellation;
      } else {
        content += "丨" + constellation;
      }
    }

    return Offstage(
      offstage: content == "",
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setHeight(4)),
        child: Text(
          content,
          style: TextStyle(
              color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),
        ),
      ),
    );
  }

  ///游戏卡片
  Widget gameCardList() {
    if (_userInfo.card != null && _userInfo.card.length > 0) {
      return Container(
          margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
          height: ScreenUtil().setHeight(110.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _userInfo.card.length,
            itemBuilder: (context, index) {
              return cardItem(index);
            },
          ));
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
        child: Text(
          Strings.noGameCard,
          style: TextStyle(
              color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),
        ),
      );
    }
  }

  ///游戏卡片组件
  Widget cardItem(index) {
    return Container(
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
              image: _userInfo.card[index].logo,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(67),
                  height: ScreenUtil().setWidth(80),
                  child: Image.network(
                    _userInfo.card[index].cover,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setHeight(10),
                      bottom: ScreenUtil().setHeight(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _userInfo.card[index].gameName,
                        style: TextStyle(
                            color: ColorUtil.white,
                            fontSize: ScreenUtil().setSp(14)),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(18),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(
                                  "images/icon_game_item_start.png"),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(10),
                                right: ScreenUtil().setWidth(10)),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "images/icon_game_item_end.png"),
                                  fit: BoxFit.fill),
                            ),
                            child: Text(_userInfo.card[index].levelName,
                                style: TextStyle(
                                    fontSize: 12.0, color: ColorUtil.black)),
                          ),
                        ],
                      ),
                      Container(
                        child: Text(
                          _userInfo.card[index].areaName,
                          style: TextStyle(
                              color: ColorUtil.white,
                              fontSize: ScreenUtil().setSp(12)),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: adeptWidgets(_userInfo.card[index].adept),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///擅长位置列表
  List<Widget> adeptWidgets(List<Adept> adepts) {
    List<Widget> list = List();
    adepts.forEach((adept) {
      list.add(Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(4, 1, 4, 1),
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
        decoration: BoxDecoration(
          color: ColorUtil.nnBlueTran,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Text(
          adept.adeptName,
          style: TextStyle(
              color: ColorUtil.white, fontSize: ScreenUtil().setSp(12)),
        ),
      ));
    });
    return list;
  }

  ///点击用户菜单
  void onClickMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            return Container(
              height: 161,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      jumpFriendRemark();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment(0.0, 0.0),
                      child: Text("设置备注",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      deleteFriend();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment(0.0, 0.0),
                      child: Text("删除好友",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 5, color: Color.fromRGBO(242, 242, 242, 1.0)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop(); //隐藏弹出框
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment(0.0, 0.0),
                      child: Text("取消",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  ///设置好友备注
  void jumpFriendRemark() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditFriendRemarkScreen(
        userInfo: _userInfo,
      );
    }));
  }

  ///删除好友
  void deleteFriend() {
    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: "删除该好友吗？",
          confirmCallback: () {
            SocketHelper.deleteFriend(_userInfo.nnId);

            Fluttertoast.showToast(
                msg: "删除好友成功！",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);

            setState(() {
              _userInfo.isFriend = false;
            });

            DBHelper.deleteFriendsInfo(_userInfo.nnId);

            Constants.eventBus
                .fire(DeleteFriendSuccessEvent(nnID: _userInfo.nnId));
          },
        ));
  }

  ///底部按钮  添加好友---发送消息
  Widget bottomBtns() {
    if (isMyself) {
      return Container();
    }
    if (!_userInfo.isFriend) {
      return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              onTap: () {
                onSendMessage();
              },
              child: Container(
                alignment: Alignment.center,
                height: ScreenUtil().setWidth(45),
                width: ScreenUtil().setWidth(125),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text("发消息",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        color: ColorUtil.white)),
              ),
            ),
            InkWell(
              onTap: () {
                addFriend();
              },
              child: Container(
                alignment: Alignment.center,
                height: ScreenUtil().setWidth(45),
                width: ScreenUtil().setWidth(125),
                decoration: BoxDecoration(
                  color: ColorUtil.greyHint,
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text("加好友",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        color: ColorUtil.black)),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          onSendMessage();
        },
        child: Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(45),
          width: ScreenUtil().setWidth(125),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(width: 1, color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Text("发消息",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(16), color: ColorUtil.white)),
        ),
      ),
    );
  }

  ///点击发送消息
  void onSendMessage() {
    if (widget.sendClick != null) {
      widget.sendClick();
      if (widget.isClose) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ChatScreen(
          nnId: _userInfo.nnId,
          avatar: _userInfo.avatar,
          userName: _userInfo.remark != null && _userInfo.remark != ""?_userInfo.remark:_userInfo.nickname,
          isFriend: _userInfo.isFriend,
        );
      }));
    }
  }

  ///关闭
  void onCloseClick() {
    Navigator.of(context).pop();
  }

  ///添加好友
  Future addFriend() async {
    toast("好友请求已发送！");

    SocketHelper.addFriend(_userInfo.nnId, AddFriendStatusType.addFriend, "",
        FriendFromType.fromSearch);
  }
}
