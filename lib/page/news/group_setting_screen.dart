import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/CustomDialog.dart';
import 'package:premades_nn/event/group_event.dart';
import 'package:premades_nn/event/group_setting_event.dart';
import 'package:premades_nn/model/group_member_entity.dart';
import 'package:premades_nn/page/news/edit_group_name_screen.dart';
import 'package:premades_nn/page/news/user_info.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/GroupMemberOperationType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';

import 'edit_friend_remark_screen.dart';
import 'group_member_operation_screen.dart';

///群设置页面
class GroupSettingScreen extends StatefulWidget {
  final int groupNo;
  final String groupName;
  final bool isGroupOwner;

  GroupSettingScreen({this.groupNo, this.groupName, this.isGroupOwner});

  @override
  _GroupSettingScreenState createState() => _GroupSettingScreenState();
}

class _GroupSettingScreenState extends State<GroupSettingScreen> {
  List<GroupMemberEntity> groupMembers = List();

  int adminNnId;

  StreamSubscription<GroupSettingEvent> _subscription;

  @override
  void initState() {
    super.initState();
    initData();

    _subscription = Constants.eventBus.on<GroupSettingEvent>().listen((event) {
      switch (event.type) {
        case GroupSettingEventType.reloadData:
          initData();
          break;
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorUtil.greyBG,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBarWidget(isShowBack: true, centerText: Strings.groupSetting),
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
              padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
              constraints: BoxConstraints(
                minHeight: ScreenUtil().setHeight(60),
              ),
              width: double.infinity,
              color: ColorUtil.white,
              child: Wrap(
                spacing: ScreenUtil().setWidth(10), //主轴上子控件的间距
                runSpacing: ScreenUtil().setWidth(10), //交叉轴上子控件之间的间距
                children: groupMemberWidgets(), //要显示的子控件集合
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return EditGroupNameScreen(groupNo: widget.groupNo, groupName: widget.groupName,);
                }));
              },
              child: Container(
                color: ColorUtil.white,
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setHeight(10),
                    right: ScreenUtil().setHeight(10)),
                height: ScreenUtil().setHeight(52),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.editGroupName,
                      style: TextStyle(
                          color: ColorUtil.black,
                          fontSize: ScreenUtil().setSp(15)),
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
            InkWell(
              onTap: () {
                clearChatRecord();
              },
              child: Container(
                color: ColorUtil.white,
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setHeight(10),
                    right: ScreenUtil().setHeight(10)),
                height: ScreenUtil().setHeight(52),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.clearChatRecord,
                      style: TextStyle(
                          color: ColorUtil.black,
                          fontSize: ScreenUtil().setSp(15)),
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
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
            ),
            InkWell(
              onTap: () {
                deleteAndExit();
              },
              child: Container(
                color: ColorUtil.white,
                alignment: Alignment.center,
                height: ScreenUtil().setHeight(50),
                width: double.infinity,
                child: Text(
                  Strings.deleteAndQuit,
                  style: TextStyle(
                      color: ColorUtil.red,
                      fontSize: ScreenUtil().setSp(15),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///数据加载
  void initData() {
    if (groupMembers != null && groupMembers.length > 0) {
      groupMembers.clear();
    }
    var formData = {"groups_no": widget.groupNo};
    request("post", allUrl["groupMember"], formData).then((value) {
      if (value["code"] == 0 && value["data"] != null) {
        (value["data"] as List).forEach((item) {
          groupMembers.add(GroupMemberEntity.fromJson(item));
          if (item["is_admin"] == 1) {
            adminNnId = item["nn_id"];
          }
        });
        setState(() {});
      }
    });
  }

  List<Widget> groupMemberWidgets() {
    List<Widget> datas = new List();
    groupMembers.forEach((item) {
      datas.add(InkWell(onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return UserInfo(
            nnid: item.nnId,
          );
        }));
      },
      child: Container(
        width: ScreenUtil().setWidth(40),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipOval(
            child: Image.network(
              item.avatar,
            ),
          ),
        ),
      ),)

      );
    });

    datas.add(InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GroupMemberOperationScreen(
            groupNo: widget.groupNo,
            type: GroupMemberOperationType.groupAddMember,
            groupMembers: groupMembers,
          );
        }));
      },
      child: Container(
          width: ScreenUtil().setWidth(40),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: Image.asset(
                "images/icon_member_add.png",
              ),
            ),
          )),
    ));

    if (Constants.userInfo.nnId == adminNnId) {
      datas.add(InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return GroupMemberOperationScreen(
              groupNo: widget.groupNo,
              type: GroupMemberOperationType.groupRemoveMember,
              groupMembers: groupMembers,
            );
          }));
        },
        child: Container(
          width: ScreenUtil().setWidth(40),
          child: ClipOval(
            child: Image.asset(
              "images/icon_member_remove.png",
              width: ScreenUtil().setWidth(40),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ));
    }

    return datas;
  }

  ///清空群聊历史记录
  void clearChatRecord() {
    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: Strings.clearChatRecord,
          confirmCallback: () {
            var formData = {"groups_no": widget.groupNo};
            request("post", allUrl["clearGroupClear"], formData).then((value) {
              if (value["code"] == 0) {
                DBHelper.deleteGroupMessages(widget.groupNo);
                Constants.eventBus.fire(GroupEvent(groupNo: widget.groupNo, type: GroupEventType.clearGroupChat));
              }
            });
          },
        ));
  }

  ///删除并退出
  void deleteAndExit() {
    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: Strings.exitGroupHint,
          confirmCallback: () {
            Fluttertoast.showToast(
                msg: Strings.exitGroupSuccess,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);

            SocketHelper.deleteAndExit(widget.groupNo);

            DBHelper.deleteGroupByGroupNo(widget.groupNo);

            Navigator.popUntil(context, ModalRoute.withName("home"));

            Constants.eventBus.fire(GroupEvent(
                groupNo: widget.groupNo,
                type: GroupEventType.deleteAndExitGroup));
          },
        ));
  }
}
