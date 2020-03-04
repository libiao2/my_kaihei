
import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/FriendCheckItem.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/group_setting_event.dart';
import 'package:premades_nn/model/friend_info_entity.dart';
import 'package:premades_nn/model/group_member_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';

import 'group_chat_screen.dart';

/// 创建群聊
class GroupMemberOperationScreen extends StatefulWidget{

  final List<GroupMemberEntity> groupMembers;

  final int type;// 0:创建群聊  1:群聊加人  2:群聊踢人

  final int groupNo;//群号

  GroupMemberOperationScreen({this.type, this.groupMembers, this.groupNo});

  @override
  _GroupMemberOperationScreenState createState() => _GroupMemberOperationScreenState();

}

class _GroupMemberOperationScreenState extends State<GroupMemberOperationScreen>{

  //好友列表
  List<FriendInfoEntity> _friends = new List<FriendInfoEntity>();
  //展示好友
  List<FriendInfoEntity> _showFriends = new List<FriendInfoEntity>();


  int _suspensionHeight = 40;
  int _itemHeight = 60;

  //查找好友过滤词
  String filterWord;

  TextEditingController _controller = TextEditingController();

  bool isHideClearIcon = true;

  List<int> chooseIds = List();

  String title;

  String rightText;

  @override
  void initState() {
    super.initState();

    if (widget.type == 0){
      title = Strings.createGroupChat;
      rightText = Strings.sure;
      loadData();
      chooseIds.add(Constants.userInfo.nnId);

    } else if(widget.type == 1){
      title = Strings.chooseContact;
      rightText = Strings.sure;
      loadData();
    } else if (widget.type == 2){
      title = Strings.chatMembers + "(${widget.groupMembers.length})";
      rightText = Strings.delete;
      if (widget.groupMembers != null && widget.groupMembers.length > 0){
        widget.groupMembers.forEach((item){
          if (item.nnId != Constants.userInfo.nnId){
            _friends.add(FriendInfoEntity(avatar: item.avatar, nickname: item.nickname, nnId: item.nnId));
          }
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///加载联系人列表
  void loadData() async {
    _friends.clear();

    if (Constants.connected) {
      request('post', allUrl['friendList'], null).then((val) {
        if (val['code'] == 0 && val['data'] != null) {
          (val['data'] as List).forEach((v) {
            _friends.add(new FriendInfoEntity.fromJson(v));
          });
          _handleList(_friends);
          setState(() {});
        }
      });
    } else {
      DBHelper.queryContacts().then((list) {
        if (list != null && list.length > 0) {
          _friends.addAll(list);
          _handleList(_friends);
          setState(() {

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
      _friends.forEach((friendInfo) {
        if (friendInfo.nickname.contains(filterWord)) {
          _showFriends.add(friendInfo);
        }
      });
    } else {
      _showFriends.addAll(_friends);
    }

    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true, centerText: title,rightText: rightText,callback: (){
            if (widget.type == 0){
              if (chooseIds != null && chooseIds.length < 3){
                toast(Strings.peopleNumError);
              } else {
                NetLoadingDialog.showLoadingDialog(context, Strings.createGroup);
                var formData = {
                  "nn_id":chooseIds
                };
                request("post", allUrl["addGroup"], formData).then((value){
                  Navigator.pop(context);
                  if (value["code"] == 0){

                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return GroupChatScreen(
                        groupNo: value["data"]["groups_no"],
                        groupName: value["data"]["groups_name"],
                        avatar: value["data"]["avatar"],
                      );
                    }));
                  }
                });
              }
            } else if(widget.type == 1){
              SocketHelper.addGroupMembers(widget.groupNo, chooseIds);
              Navigator.pop(context);
              Constants.eventBus.fire(GroupSettingEvent(type: GroupSettingEventType.reloadData));
            } else if (widget.type == 2){
              SocketHelper.removeGroupMembers(widget.groupNo, chooseIds);
              Navigator.pop(context);
              Constants.eventBus.fire(GroupSettingEvent(type: GroupSettingEventType.reloadData));
            }

          },),
          _headerSearchBar(),

          widget.type == 2?
              Expanded(
                child: ListView.builder(
                    itemCount: _showFriends.length,
                    itemBuilder: (context, index){
                      return FriendCheckItem(model: _showFriends[index], enable: true
                          ,callback: (){
                            bool isHave = false;
                            chooseIds.removeWhere((item){
                              if (item == _showFriends[index].nnId){
                                isHave = true;
                              }
                              return item == _showFriends[index].nnId;
                            });

                            if (!isHave){
                              chooseIds.add(_showFriends[index].nnId);
                            }
                            setState(() {
                              if (chooseIds.length > 0){
                                rightText = "${Strings.delete}(${chooseIds.length})";
                              } else {
                                rightText = Strings.delete;
                              }
                            });
                            print("chooseIds = $chooseIds");
                          }
                      );
                    }),
              )
          :
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
      ),
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
        style: TextStyle(fontSize: ScreenUtil().setSp(14), color: ColorUtil.black),
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

    bool enable = true;

    if (widget.groupMembers != null && widget.groupMembers.length > 0){
      widget.groupMembers.forEach((item){
        if (item.nnId == model.nnId){
          enable = false;
        }
      });
    }

    return Container(
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: model.isShowSuspension != true,
            child: _buildSusWidget(susTag),
          ),

            FriendCheckItem(model: model, enable: enable
                ,callback: (){
                  bool isHave = false;
                  chooseIds.removeWhere((item){
                    if (item == model.nnId){
                      isHave = true;
                    }
                    return item == model.nnId;
                  });

                  if (!isHave){
                    chooseIds.add(model.nnId);
                  }

                  int count;
                  setState(() {
                    if (widget.type == 0){
                      count = chooseIds.length - 1;
                    } else if (widget.type == 1){
                      count = chooseIds.length;
                    }
                    if (count> 0){
                      rightText = "${Strings.sure}($count)";
                    } else {
                      rightText = Strings.sure;
                    }
                  });
                  print("chooseIds = $chooseIds");
            }
            ),
        ],
      ),
      color: Colors.white,
    );
  }

  ///查询组件
  Widget _headerSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Icon(
              Icons.search,
              color: Colors.grey,
              size: 25,
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
                  if (content == "" || content == null){
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
                  fontSize: 14,
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