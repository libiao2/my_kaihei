import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/CustomDialog.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/search_box.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/add_friend_event.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/model/search_user_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/AddFriendStatusType.dart';
import 'package:premades_nn/type/FriendFromType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'user_info.dart';

class GoodFriendAdd extends StatefulWidget {
  @override
  _GoodFriendAddState createState() => _GoodFriendAddState();
}

class _GoodFriendAddState extends State<GoodFriendAdd> {
  List<SearchUser> searchList = new List();

  String keyword;

  var _curPage = 1;

  StreamSubscription<AddFriendEvent> _subscription;


  bool isNoData = false;

  @override
  void initState() {
    super.initState();

    _subscription = Constants.eventBus.on<AddFriendEvent>().listen((event) {
      Fluttertoast.showToast(
          msg: "添加好友成功！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);

      Constants.eventBus.fire(AddFriendSuccessEvent());
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(
            isShowBack: true,
            centerText: Strings.addFriend,
          ),
          Expanded(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: SearchBox(
                      onSearchBtnClick: _onSearchBtnClick,
                      inputType: TextInputType.number,
                      hintText: "请输入用户NN号",
                      formatter: [
                        WhitelistingTextInputFormatter(RegExp("[0-9]"))
                      ],
                    ),
                    padding: EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: Color.fromRGBO(242, 242, 242, 1),
                                width: 1.0,
                                style: BorderStyle.solid))),
                  ),
                  !isNoData
                      ? Expanded(
                    child: EasyRefresh(
                      child: ListView.separated(
                        //列表滑动到边界时，显示iOS的弹出效果
                        physics: BouncingScrollPhysics(),
                        itemCount: searchList.length,
                        itemBuilder: (context, index) {
                          return searchUserItem(searchList[index]);
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: Color.fromRGBO(170, 170, 170, 1),
                            height: 2,
                            indent: 10,
                            endIndent: 10,
                          );
                        },
                      ),
                    ),
                  )
                      :
                  //无数据
                  Column(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(100),
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setWidth(20)),
                        height: 100,
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                              image: AssetImage("images/no_list.png")),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          "未搜索到相关用户",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(14),
                              color: ColorUtil.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ///查询用户item
  Widget searchUserItem(SearchUser searchUser) {
    return Container(
        color: ColorUtil.white,
        child: ListTile(
          leading: Container(
              width: ScreenUtil().setWidth(44),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
                  child: Image.network(
                    searchUser.avatar,
                  ),
                ),
              )),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    searchUser.nickname,
                    style: TextStyle(
                        color: ColorUtil.black,
                        fontSize: ScreenUtil().setSp(15)),
                  ),
                ),
              ),

              //通过名称搜索 ，搜索关键字红色---改成通过nnid搜索，只搜索一个
//          RichText(
//            maxLines: 1,
//            overflow: TextOverflow.ellipsis,
//            text: TextSpan(
//              text: searchUser.nickname,
//              style: TextStyle(fontSize: 16, color: Colors.black),
//            ),

//            TextSpan(
//              text: searchUser.nickname
//                  .substring(0, searchUser.nickname.indexOf(keyword)),
//              style: TextStyle(fontSize: 16, color: Colors.black),
//              children: <TextSpan>[
//                TextSpan(
//                  text: keyword,
//                  style: TextStyle(fontSize: 16, color: Colors.red),
//                ),
//                TextSpan(
//                    text: searchUser.nickname.substring(
//                        searchUser.nickname.indexOf(keyword) + keyword.length,
//                        searchUser.nickname.length)),
//              ],
//            ),
//          ),
              showWidget(searchUser)
            ],
          ),
          onTap: () {
            userItemClick(searchUser);
          },
        ));
  }

  ///添加好友
  Future addFriend(SearchUser item) async {
    if (item.friendVerificationType == 3){
      toast("对方拒绝任何人添加好友");
    } else {
      toast("好友请求已发送！");
      SocketHelper.addFriend(item.nnId, AddFriendStatusType.addFriend, "",
          FriendFromType.fromSearch);
    }
  }

  ///查询好友
  void _onSearchBtnClick(val) {
//    _curPage = 1;
    keyword = val.toString();
    if (keyword.length < 5 || keyword.length > 9) {
      toast(Strings.nnIDError);
      return;
    }
    setState(() {
      searchList.clear();
    });
    loadData();
  }

  ///查询好友列表item点击
  Future userItemClick(SearchUser searchUser) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return UserInfo(
        nnid: searchUser.nnId,
      );
    }));
  }

  ///加载数据
  void loadData() {
    var data = {"keyword": keyword, "limit": 10, "page": _curPage};
    request("post", allUrl["search_user"], data).then((result) {
      if (result["code"] == 0) {
        SearchUserEntity searchUserEntity = SearchUserEntity.fromJson(result);
        if (searchUserEntity != null &&
            searchUserEntity.data != null &&
            searchUserEntity.data.searchUserList != null &&
            searchUserEntity.data.searchUserList.length > 0) {
          setState(() {
            isNoData = false;
            searchList.addAll(searchUserEntity.data.searchUserList);
          });
        } else {
          setState(() {
            isNoData = true;
          });
        }
      } else {
        setState(() {
          isNoData = true;
        });
      }
    });
  }

  ///添加  已添加  显示控制
  Widget showWidget(SearchUser searchUser) {
    if (searchUser.friendInfo == null &&
        searchUser.nnId != Constants.userInfo.nnId) {
      return InkWell(
        onTap: () {
          addFriend(searchUser);
        },
        child: Container(
          alignment: Alignment.center,
          width: ScreenUtil().setWidth(70),
          height: ScreenUtil().setWidth(30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(colors: [
                ColorUtil.btnStartColor,
                ColorUtil.btnEndColor,
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Text(
            "添加",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(12), color: ColorUtil.white),
          ),
        ),
      );
    } else if (searchUser.nnId != Constants.userInfo.nnId) {
      return Text(
        "已添加",
        style:
        TextStyle(fontSize: ScreenUtil().setSp(12), color: ColorUtil.grey),
      );
    } else {
      return Text("", style: TextStyle(fontSize: 14, color: Colors.grey));
    }
  }
}
