import 'dart:async';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/event/group_event.dart';
import 'package:premades_nn/event/update_group_event.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/model/friend_info_entity.dart';
import 'package:premades_nn/model/group_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';

import 'group_chat_screen.dart';
import 'user_info.dart';
import '../../service/service_url.dart';

///好友列表
class GroupListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GroupListScreenState();
}

class GroupListScreenState extends State<GroupListScreen> {
  List<GroupEntity> groups = new List<GroupEntity>();

  //退出群聊
  StreamSubscription<GroupEvent> _subscription;

  //修改群聊名称
  StreamSubscription<UpdateGroupEvent> _updateGroupSubscription;

  @override
  void initState() {
    super.initState();
    loadData();

    _subscription = Constants.eventBus.on<GroupEvent>().listen((event) {
      switch (event.type) {
        case GroupEventType.deleteAndExitGroup:
          setState(() {
            groups.removeWhere((item) {
              return item.groupsNo == event.groupNo;
            });
          });
          break;
      }
    });

    _updateGroupSubscription = Constants.eventBus.on<UpdateGroupEvent>().listen((event){
      if (event.type == UpdateGroupType.updateGroupName){
        groups.forEach((group){
          if (group.groupsNo == event.groupNo){
            setState(() {
              group.groupsName = event.groupName;
            });
          }
        });
      } else if (event.type == UpdateGroupType.addGroup){
        setState(() {
          groups.add(event.groupEntity);
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

    if (_updateGroupSubscription != null) {
      _updateGroupSubscription.cancel();
    }

  }

  ///加载联系人列表
  void loadData() async {
    if (Constants.connected) {
      request('post', allUrl['groups'], null).then((val) {
        if (val['code'] == 0 && val['data'] != null) {
          (val['data'] as List).forEach((v) {
            groups.add(new GroupEntity.fromJson(v));
          });
          DBHelper.insertGroups(groups);
          setState(() {});
        }
      });
    } else {
      DBHelper.queryAllGroups().then((list) {
        if (list != null && list.length > 0) {
          setState(() {
            groups.addAll(list);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          return groupItem(groups[index]);
        },
      ),
    );
  }

  ///群聊列表 item
  Widget groupItem(GroupEntity model) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GroupChatScreen(
            groupNo: model.groupsNo,
            groupName: model.groupsName,
            avatar: model.avatar,
          );
        }));
      },
      child: Container(
        decoration: BoxDecoration(
            color: ColorUtil.white,
            border: Border(top: BorderSide(color: ColorUtil.greyBG, width: 1))),
        child: ListTile(
          leading: Container(
              width: ScreenUtil().setWidth(44),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
                  child: Image.network(
                    model.avatar,
                  ),
                ),
              )),
          title: Text(
            model.groupsName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: ColorUtil.black, fontSize: ScreenUtil().setSp(15)),
          ),
        ),
      ),
    );
  }
}
