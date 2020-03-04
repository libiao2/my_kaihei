import 'dart:async';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/model/friend_info_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';

import 'user_info.dart';
import '../../service/service_url.dart';

///好友列表
class ContactListRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactListRouteState();
  }
}

class _ContactListRouteState extends State<ContactListRoute> {
  StreamSubscription<AddFriendSuccessEvent> _subscription;

  StreamSubscription<DeleteFriendSuccessEvent> _deleteFriendSubscription;

  //好友列表

  List<FriendInfoEntity> _friends = new List<FriendInfoEntity>();

  List<FriendInfoEntity> _showFriends = new List<FriendInfoEntity>();

  int _suspensionHeight = 40;
  int _itemHeight = 60;

  //查找好友过滤词
  String filterWord;

  TextEditingController _controller = TextEditingController();

  bool isHideClearIcon = true;

  @override
  void initState() {
    super.initState();
    loadData();

    ///添加好友更新页面
    _subscription =
        Constants.eventBus.on<AddFriendSuccessEvent>().listen((event) {
      loadData();
    });

    _deleteFriendSubscription =
        Constants.eventBus.on<DeleteFriendSuccessEvent>().listen((event) {
      setState(() {
        _friends.removeWhere((item) {
          return item.nnId == event.nnID;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }

    if (_deleteFriendSubscription != null) {
      _deleteFriendSubscription.cancel();
    }
  }

  ///加载联系人列表
  void loadData() async {
    if (Constants.connected) {
      request('post', allUrl['friendList'], null).then((val) {
        if (val['code'] == 0 && val['data'] != null) {
          _friends.clear();
          _showFriends.clear();
          (val['data'] as List).forEach((v) {
            _friends.add(new FriendInfoEntity.fromJson(v));
          });
          DBHelper.insertFriendsInfo(_friends);
          _handleList(_friends);
          setState(() {});
        } else {
          toast(val['msg']);
        }
      });
    } else {
      _friends.clear();
      _showFriends.clear();
      DBHelper.queryContacts().then((list) {
        if (list != null && list.length > 0) {
          setState(() {
            _friends.addAll(list);
          });
        }
      });
    }
  }

  ///排序
  void _handleList(List<FriendInfoEntity> list) {
    if (list == null || list.isEmpty) return;
    SuspensionUtil.sortListBySuspensionTag(_showFriends);
  }

  @override
  Widget build(BuildContext context) {
    //好友过滤逻辑
    _showFriends.clear();
    if (filterWord != null && filterWord != "" && _friends.length > 0) {
      _friends.forEach((fridentInfo) {
        if (Constants.isNNID(filterWord) && fridentInfo.nnId == int.parse(filterWord)){
          _showFriends.add(fridentInfo);
        } else if (fridentInfo.nickname.contains(filterWord) || fridentInfo.remark.contains(filterWord)) {
          _showFriends.add(fridentInfo);
        }
      });
    } else {
      _showFriends.addAll(_friends);
    }

    return Column(
      children: <Widget>[
        _headerSearchBar(),
        Expanded(
          child: AzListView(
            data: _showFriends,
            itemBuilder: (context, model) => _buildListItem(model),
            isUseRealIndex: true,
            itemHeight: _itemHeight,
            suspensionHeight: _suspensionHeight,
            indexBarBuilder: (BuildContext context, List<String> tags,
                IndexBarTouchCallback onTouch) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: IndexBar(
                    data: tags,
                    itemHeight: 20,
                    width: 20,
                    onTouch: (details) {
                      onTouch(details);
                    },
                  ),
                ),
              );
            },
            indexHintBuilder: (context, hint) {
              return Container(
                alignment: Alignment.center,
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.blue[700].withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: Text(hint,
                    style: TextStyle(color: Colors.white, fontSize: 30.0)),
              );
            },
          ),
        ),
      ],
    );
  }

  ///排序首字母组件
  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: _suspensionHeight.toDouble(),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        style:
            TextStyle(fontSize: ScreenUtil().setSp(14), color: ColorUtil.black),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
                color: ColorUtil.greyBG, width: 10, style: BorderStyle.solid)),
      ),
    );
  }

  ///好友列表 item
  Widget _buildListItem(FriendInfoEntity model) {
    String susTag = model.getSuspensionTag();
    return Container(
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: model.isShowSuspension != true,
            child: _buildSusWidget(susTag),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return UserInfo(
                  nnid: model.nnId,
                );
              }));
            },
            child: Container(
              height: _itemHeight.toDouble(),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Container(
                        width: ScreenUtil().setWidth(44),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipOval(
                            child: Image.network(
                              model.avatar,
                            ),
                          ),
                        )
                    ),
                    title: Text(
                      model.remark != null && model.remark != ""
                          ? model.remark
                          : model.nickname,
                      style: TextStyle(
                          color: ColorUtil.black,
                          fontSize: ScreenUtil().setSp(15)),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: ColorUtil.greyBG,
                        width: 1.0,
                        style: BorderStyle.solid)),
              ),
            ),
          ),
        ],
      ),
      color: Colors.white,
    );
  }

  ///查询组件
  Widget _headerSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(ScreenUtil().setHeight(10), 0, ScreenUtil().setHeight(10), 0),
      margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
      height: ScreenUtil().setHeight(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset("images/icon_search.png"),
            ),
            margin: EdgeInsets.only(right: 10.0),
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.text,
              controller: _controller,
              cursorColor: ColorUtil.black,
              autofocus: false,
              maxLines: 1,
              onChanged: (content) {
                setState(() {
                  if (content == "" || content == null) {
                    isHideClearIcon = true;
                    filterWord = "";
                  } else {
                    isHideClearIcon = false;
                    filterWord = content;
                  }
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "输入昵称或NN号进行查找",
                hintStyle: TextStyle(
                  fontSize: ScreenUtil().setSp(12),
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Offstage(
            offstage: isHideClearIcon,
            child: InkWell(
              onTap: () {
                _controller.text = "";
                filterWord = "";
                isHideClearIcon = true;
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(left: 10.0),
                child: Icon(
                  Icons.cancel,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(242, 242, 242, 1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
